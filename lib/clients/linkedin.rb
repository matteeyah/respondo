# frozen_string_literal: true

module Clients
  class Linkedin < Clients::ProviderClient # rubocop:disable Metrics/ClassLength
    RESTLI_V2 = { "X-Restli-Protocol-Version" => "2.0.0" }.freeze
    LI_POST = "https://www.linkedin.com/feed/update"
    LI_USER_AUTHOR = "https://linkedin.com/in"
    LI_COMPANY_AUTHOR = "https://linkedin.com/company"

    def initialize(client_id, client_secret, token, organization_account)
      super()

      @client_id = client_id
      @client_secret = client_secret
      @token = token
      @organization_account = organization_account
    end

    def new_mentions(last_mention_id) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      # unix_timestamp_id = formatted_timestamp(last_mention_id)
      unix_timestamp_id = last_mention_id ? "#{last_mention_id.to_time.to_i + 1.second}000" : nil
      admin_organizations_urns = admin_orgs_urns[0]
      # since linkedin api startRange is inclusive (greater or equals), add +1 to exclude fetching last existing mention
      basic_org_data = organization_notifications(admin_organizations_urns,
                                                  unix_timestamp_id.nil? ? nil : unix_timestamp_id.to_i)
      elements = basic_org_data["elements"]
      return [] unless elements

      activities_urns = elements.map do |element| # rubocop:disable Rails/Pluck
        element["generatedActivity"]
      end
      fetched_posts = posts_with_content(activities_urns)
      author_urns = fetched_posts.pluck("author")
      authors = authors_by_urn(author_urns)
      fetched_posts.map do |mention|
        mention_author = authors.find do |author|
          mention["author"].include? author["id"]
        end
        post_to_mention(mention, mention_author)
      end.reverse
    end

    def reply(response_text, external_uid) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      admin_organizations_urns = admin_orgs_urns[0]
      body = { actor: admin_organizations_urns, object: external_uid, message: { text: response_text } }
      result = http_post("https://api.linkedin.com/v2/socialActions/#{id_to_urn(external_uid, 'share')}/comments",
                         body)
      comment = JSON.parse(result.body)
      organization_id = urn_to_id(comment["actor"])
      organization = organization_by_id(organization_id)
      encoded_comment_urn = URI.encode_uri_component(comment["$URN"])
      {
        external_uid: comment["id"], content: comment["message"]["text"], parent_uid: external_uid,
        created_at: DateTime.strptime((comment["lastModified"]["time"]).to_s, "%Q"),
        author: { external_uid: organization_id, username: organization["vanityName"],
                  external_link: "#{LI_COMPANY_AUTHOR}/#{organization['vanityName']}" },
        external_link: "#{LI_POST}/#{comment['object']}/?commentUrn=#{encoded_comment_urn}"
      }
    end

    def delete(id)
      parent_mention_link = @organization_account.mentions.find_by(external_uid: id).parent[:external_link]
      urn = parent_mention_link.split("/").last
      admin_organizations_urns = admin_orgs_urns[0]
      http_delete("https://api.linkedin.com/v2/socialActions/#{urn}/comments/#{id}?actor=#{admin_organizations_urns}")
    end

    # https://github.com/matteeyah/respondo/issues/386
    def posts(author_id)
      # http_get("https://api.linkedin.com/rest/posts?author=#{URI.encode_uri_component('urn:li:person:')}#{author_id}&q=author&count=10",
      #          { **RESTLI_V2, 'X-RestLi-Method' => 'FINDER' })
      localized_headline = authors_by_urn([ author_id ])[0]["localizedHeadline"]
      [ { "text" => localized_headline } ]
    end

    private

    def authorization_headers
      { "Authorization" => "Bearer #{@token}",
        "LinkedIn-Version" => (Integer(Time.zone.today.strftime("%Y%m")) - 1).to_s }
    end

    def http_get(url, headers = nil)
      request_headers = headers ? { **authorization_headers, **headers } : authorization_headers
      JSON.parse(Net::HTTP.get(URI(url), request_headers))
    end

    def http_post(url, body, headers = nil)
      default_headers = { **authorization_headers, "Content-Type" => "application/json" }
      request_headers = headers ? { **default_headers, **headers } : default_headers
      Net::HTTP.post(URI(url), body.to_json, request_headers)
    end

    def http_delete(url, headers = nil)
      uri = URI(url)
      default_headers = { **authorization_headers, "X-RestLi-Method" => "DELETE" }
      request_headers = headers ? { **default_headers, **headers } : default_headers
      req = Net::HTTP::Delete.new(uri, request_headers)
      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        http.request req
      end
    end

    # find all organizations where user is admin
    def admin_organizations
      http_get("https://api.linkedin.com/v2/organizationalEntityAcls?q=roleAssignee&role=ADMINISTRATOR&projection=(elements*(organizationalTarget~(id)))")
    end

    # get urns for fetching notifications
    def admin_orgs_urns
      organizations = admin_organizations
      return if organizations.nil?

      organizations["elements"].map do |element| # rubocop:disable Rails/Pluck
        element["organizationalTarget"]
      end
    end

    # get basic organizations data
    def organization_notifications(admin_org_urns, time_range_start = nil)
      url = if time_range_start
              "https://api.linkedin.com/v2/organizationalEntityNotifications?q=criteria&actions=List(SHARE_MENTION)&organizationalEntity=#{URI.encode_uri_component(admin_org_urns)}&timeRange=(start:#{time_range_start},end:#{Time.new.to_i}000)"
      else
              "https://api.linkedin.com/v2/organizationalEntityNotifications?q=criteria&actions=List(SHARE_MENTION)&organizationalEntity=#{URI.encode_uri_component(admin_org_urns)}"
      end
      http_get(url, RESTLI_V2)
    end

    def organization_by_id(id)
      http_get("https://api.linkedin.com/v2/organizations/#{id}", RESTLI_V2)
    end

    # fetch posts with full content based on URNs
    def posts_with_content(activities_urns)
      # linkedin's Get Posts by URN API does not accept list of 1 items, so it has to be manually checked
      if activities_urns.length == 1
        [ http_get("https://api.linkedin.com/v2/posts/#{activities_urns[0]}") ]
      else
        http_get("https://api.linkedin.com/v2/posts?ids=List(#{activities_urns.join(',')})")
      end
    end

    # convert a post to a mention
    def post_to_mention(post_from_api, author, parent_uid = nil)
      # cuts off the urn part: @[Test 1337](urn:li:organization:100702332)
      regex = /@\[(.*)\]\(.*\)/
      organization_name = post_from_api["commentary"].match(regex)[1] # "Test 1337"
      parsed_content =  post_from_api["commentary"].gsub(regex, "@#{organization_name}")
      {
        external_uid: urn_to_id(post_from_api["id"]), content: parsed_content, parent_uid:,
        created_at: DateTime.strptime((post_from_api["lastModifiedAt"]).to_s, "%Q"),
        author: { external_uid: author["id"], username: author["vanityName"],
                  external_link: "#{LI_USER_AUTHOR}/#{author['vanityName']}" },
        external_link: "#{LI_POST}/#{post_from_api['id']}"
      }
    end

    def urn_to_id(urn)
      urn.split(":").last
    end

    def id_to_urn(id, type)
      "urn:li:#{type}:#{id}"
    end

    # get author by URN
    def authors_by_urn(author_urns)
      if author_urns.length == 1
        author_id = urn_to_id(author_urns[0])
        [ http_get("https://api.linkedin.com/v2/people/(id:#{author_id})", RESTLI_V2) ]
      else
        url = author_urns_to_list(author_urns)
        http_get(url, RESTLI_V2)
      end
    end

    def author_urns_to_list(author_urns)
      author_ids_hash = author_urns.map do |urn|
        urn_to_id(urn)
      end
      url = "https://api.linkedin.com/v2/people?ids=List("
      author_ids_hash.each do |id|
        url += "(id: #{id})"
      end
      "#{url})"
    end
  end
end
