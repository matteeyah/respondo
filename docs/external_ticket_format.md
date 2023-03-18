---
title: External Ticket Format
description: External ticket format for manually submitting tickets via API.
---

# External ticket format

The response URL is stored in ticket metadata. Respondo sends a POST request to
the response URL and expects a response with the same schema that's used for
creating tickets.

[Zapier webhooks](https://zapier.com/apps/webhook/help) could be used to
implement this.

## Inbound

All requests are sent to the
`Organizations::ExternalTicketsController#create_external` endpoint in JSON
format.

<details>
<summary>Schema</summary>

{% highlight json %}
{
  "type": "object",
  "required": [
    "external_uid",
    "content",
    "author",
    "created_at",
    "personal_access_token",
    "ticketable_attributes"
  ],
  "properties": {
    "external_uid": {
      "type": "string",
      "examples": [
        "123hello321world"
      ]
    },
    "content": {
      "type": "string",
      "examples": [
        "This is content from an example external ticket."
      ]
    },
    "parent_uid": {
      "type": "string",
      "examples": [
        "external_ticket_parent_uid"
      ]
    },
    "author": {
      "type": "object",
      "required": [
        "external_uid",
        "username"
      ],
      "properties": {
        "external_uid": {
          "type": "string",
          "examples": [
            "external_ticket_author_id"
          ]
        },
        "username": {
          "type": "string",
          "examples": [
            "best_username_ever"
          ]
        }
      }
    },
    "created_at": {
      "type": "string",
      "examples": [
        "2020-04-04 23:35:27.632879 UTC"
      ]
    },
    "personal_access_token": {
      "type": "object",
      "required": [
        "name",
        "token"
      ],
      "properties": {
        "name": {
          "type": "string",
          "examples": [
            "token_name"
          ]
        },
        "token": {
          "type": "string",
          "examples": [
            "123TOKEN321"
          ]
        }
      }
    },
    "ticketable_attributes": {
      "type": "object",
      "required": ["response_url"],
      "properties": {
        "response_url": {
          "type": "string",
          "examples": [
            "https://response_url.com"
          ]
        },
        "custom_provider": {
          "type": "string",
          "examples": [
            "hacker_news"
          ]
        },
        "additionalProperties": false
      }
    }
  },
  "additionalProperties": false
}
{% endhighlight %}
</pre>

</details>

<details>
<summary>Example</summary>

<pre>
{% highlight json %}
{
  "external_uid": "external_ticket_uid_2",
  "author": {
    "external_uid": "author_uid_1",
    "username": "author_username"
  },
  "parent_uid":"parent_uid_1",
  "content": "This is content from an example external ticket reply.",
  "created_at": "2019-01-01 23:35:27.632879 UTC",
  "ticketable_attributes": {
    "response_url": "https://example.com"
  },
  "personal_access_token": {
    "name": "token_name",
    "token": "1234"
  }
}
{% endhighlight %}
</pre>

</details>
