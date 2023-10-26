RESTLI_V2 = { 'X-Restli-Protocol-Version' => '2.0.0' }.freeze

module Clients
  class Linkedin < Clients::ProviderClient
    def initialize(client_id, client_secret, token, organization_account)
      super()

      @client_id = client_id
      @client_secret = client_secret
      @token = token
      @organization_account = organization_account
    end

    # TODO: add logic for last ticket identifier to avoid fetching tickets that were already fetched
    def new_mentions(last_ticket_identifier)
      organizations = admin_organizations(last_ticket_identifier)
      # get urns for fetching notifications
      admin_organizations_urns = organizations['elements'].pluck('organizationalTarget')
      basic_org_data = organization_notifications(admin_organizations_urns)
      # find all activities URNs
      activities_urns = basic_org_data['elements'].pluck('generatedActivity')
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

    # find all organizations where user is admin
    def admin_organizations(time_range_start)
      http_get("https://api.linkedin.com/v2/organizationalEntityAcls?q=roleAssignee&role=ADMINISTRATOR&projection=(elements*(organizationalTarget~(id)))&timeRange.start=#{time_range_start}")
    end

    # get basic organizations data
    def organization_notifications(admin_org_urns)
      http_get(
        "https://api.linkedin.com/rest/organizationalEntityNotifications?q=criteria&actions=List(SHARE_MENTION)&organizationalEntity=#{URI.encode_www_form(admin_org_urns)}",
        RESTLI_V2
      )
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
        external_uid: post_from_api['id'], content: parsed_content, created_at: post_from_api['createdAt'],
        author: { external_uid: author['id'], username: author['vanityName'] }
      }
    end

    # get author by URN
    def author_by_urn(author_urns)
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
  end
end
