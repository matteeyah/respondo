module Clients
  class Linkedin < Clients::ProviderClient
    RESTLI_V2 = { 'X-Restli-Protocol-Version' => '2.0.0' }.freeze

    def initialize(client_id, client_secret, token, organization_account)
      super()

      @client_id = client_id
      @client_secret = client_secret
      @token = token
      @organization_account = organization_account
    end

    def new_mentions(last_ticket_id) # rubocop:disable Metrics/MethodLength, Metric/AbcSize
      unix_timestamp_id = formatted_timestamp(last_ticket_id)
      organizations = admin_organizations
      # get urns for fetching notifications
      admin_organizations_urns = organizations['elements'].pluck('organizationalTarget')
      # since linkedin api startRange is inclusive (greater or equals), add +1 to exclude fetching last existing mention
      basic_org_data = organization_notifications(admin_organizations_urns,
                                                  unix_timestamp_id.nil? ? nil : unix_timestamp_id.to_i)
      elements = basic_org_data['elements'] || []
      return elements unless elements.length.positive?

      # find all activities URNs
      activities_urns = elements.pluck('generatedActivity')
      fetched_posts = posts_with_content(activities_urns)
      # go through all fetched mentions and find URNs of all authors
      author_urns = fetched_posts.pluck('author')
      authors = author_by_urn(author_urns)
      # parse all fetched posts to tickets
      fetched_posts.map do |mention|
        mention_author = authors.find do |author|
          mention['author'].include? author['id']
        end
        mentions_to_tickets(mention, mention_author)
      end
    end

    def reply(_response_text, external_uid)
      organizations = admin_organizations
      # get urns for fetching notifications
      admin_organizations_urns = organizations['elements'].pluck('organizationalTarget')

      url = "https://api.linkedin.com/rest/socialActions/#{external_uid}/comments"
    end

    def delete(urn)
      http_delete(urn)
    end

    def permalink(urn)
      "https://www.linkedin.com/feed/update/#{urn}"
    end

    private

    def http_get(url, headers = nil)
      if headers
        JSON.parse(Net::HTTP.get(URI(url),
                                 'Authorization' => "Bearer #{@token}",
                                 'Linkedin-Version' => Time.zone.today.strftime('%Y%m').to_s,
                                 **headers))
      else
        JSON.parse(Net::HTTP.get(URI(url),
                                 'Authorization' => "Bearer #{@token}",
                                 'Linkedin-Version' => Time.zone.today.strftime('%Y%m').to_s))
      end
    end

    def http_post(url, body)
      Net::HTTP.post(URI(url), body.to_json, {
                       'Authorization' => "Bearer #{@token}",
                       'Linkedin-Version' => Time.zone.today.strftime('%Y%m').to_s,
                       **RESTLI_V2
                     })
    end

    def http_delete(url) # rubocop:disable Metrics/MethodLength
      uri = URI(url)
      hostname = uri.hostname # => "example.com"
      req = Net::HTTP::Delete.new(uri, {
                                    'Authorization' => "Bearer #{@token}",
                                    'Linkedin-Version' => Time.zone.today.strftime('%Y%m').to_s,
                                    'X-RestLi-Method' => 'DELETE',
                                    **RESTLI_V2
                                  }) # => #<Net::HTTP::Delete DELETE>
      Net::HTTP.start(hostname, uri.port, use_ssl: true) do |http|
        http.request(req)
      end
    end

    # find all organizations where user is admin
    def admin_organizations
      http_get('https://api.linkedin.com/v2/organizationalEntityAcls?q=roleAssignee&role=ADMINISTRATOR&projection=(elements*(organizationalTarget~(id)))')
    end

    # get basic organizations data
    def organization_notifications(admin_org_urns, time_range_start)
      url = if time_range_start
              "https://api.linkedin.com/rest/organizationalEntityNotifications?q=criteria&actions=List(SHARE_MENTION)&organizationalEntity=#{URI.encode_www_form(admin_org_urns)}&timeRange=(start:#{time_range_start},end:#{Time.new.to_i}000)"
            else
              "https://api.linkedin.com/rest/organizationalEntityNotifications?q=criteria&actions=List(SHARE_MENTION)&organizationalEntity=#{URI.encode_www_form(admin_org_urns)}"
            end
      http_get(url, RESTLI_V2)
    end

    # fetch posts with full content based on URNs
    def posts_with_content(activities_urns)
      # linkedin's Get Posts by URN API does not accept list of 1 items, so it has to be manually checked
      if activities_urns.length == 1
        [http_get("https://api.linkedin.com/rest/posts/#{activities_urns[0]}")]
      else
        http_get("https://api.linkedin.com/rest/posts?ids=List(#{activities_urns.join(',')})")
      end
    end

    # convert a post to a ticket
    def mentions_to_tickets(post_from_api, author)
      # cuts off the urn part: @[Test 1337](urn:li:organization:100702332)
      regex = /@\[(.*)\]\(.*\)/
      organization_name = post_from_api['commentary'].match(regex)[1] # "Test 1337"
      parsed_content =  post_from_api['commentary'].gsub(regex, "@#{organization_name}")
      {
        external_uid: post_from_api['id'], content: parsed_content,
        created_at: DateTime.strptime((post_from_api['lastModifiedAt']).to_s, '%Q'),
        author: { external_uid: author['id'], username: author['vanityName'] }
      }
    end

    # get author by URN
    def author_by_urn(author_urns) # rubocop:disable Metrics/MethodLength
      if author_urns.length == 1
        author_id = author_urns[0].split(':').last
        [http_get("https://api.linkedin.com/v2/people/(id:#{author_id})", RESTLI_V2)]
      else
        author_ids_hash = author_urns.map do |urn|
          urn.split(':').last
        end
        url = 'https://api.linkedin.com/v2/people?ids=List('
        author_ids_hash.each do |id|
          url += "(id: #{id})"
        end
        url += ')'
        http_get(url, RESTLI_V2)
      end
    end

    # get time stamp in linkedin format with 1 second added
    def formatted_timestamp(datetime) # rubocop:disable Metrics/Metric/AbcSize
      return nil if datetime.nil?

      split_date = datetime.to_s.split
      date = split_date[0].split('-')
      time = split_date[1].split(':')
      zone = split_date[2]
      adjusted_timestamp = Time.new(date[0], date[1], date[2], time[0], time[1], time[2], zone).to_i + 1.second
      date ? "#{adjusted_timestamp}000" : nil
    end
  end
end
