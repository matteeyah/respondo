---
layout: page
title: Documentation - External Ticket Format
ignore: true
---

# External ticket format

The response URL is stored in ticket metadata. Respondo sends a POST request to
the response URL and expects a response with the same schema that's used for
creating tickets.

[Zapier webhooks](https://zapier.com/apps/webhook/help) could be used to
implement this.

## Inbound

All requests are sent to the `Brands::TicketsController#create_external`
endpoint in JSON format.

### Schema

```jsonschema
{
  "type": "object",
  "required": [
    "external_uid",
    "content",
    "response_url",
    "author",
    "created_at",
    "personal_access_token"
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
    }
  },
  "additionalProperties": false
}
```

### Examples

```json
{
  "external_uid": "123hello321world",
  "content": "This is content from the external ticket example.",
  "parent_uid": "external_ticket_parent_external_uid",
  "author": {
    "external_uid": "external_ticket_author_external_uid",
    "username": "best_username"
  },
  "created_at": "2019-01-01 23:35:27.632879 UTC",
  "token": {
    "name": "token_name",
    "token": "123TOKEN321"
  }
}
```

```json
{
  "external_uid": "123hello321world",
  "content": "This is content from the external ticket example.",
  "response_url": "https://response_url.com",
  "custom_provider": "hacker_news",
  "author": {
    "external_uid": "external_ticket_author_external_uid",
    "username": "best_username"
  },
  "created_at": "2019-01-01 23:35:27.632879 UTC",
  "token": {
    "name": "token_name",
    "token": "123TOKEN321"
  }
}
```

## Reply

All replies are sent as POST requests to the `Ticket#response_url` endpoint in
JSON format. A response is expected.

### Reply schema

```jsonschema
{
  "type": "object",
  "required": [
    "response_text",
    "author",
    "parent_id"
  ],
  "properties": {
    "response_text": {
      "type": "string",
      "examples": [
        "This is content from an example external ticket reply."
      ]
    },
    "author": {
      "type": "object",
      "examples": [
        {
          "external_uid": "author_uid_1",
          "username": "author_username"
        }
      ],
      "required": [
        "external_uid",
        "username"
      ],
      "properties": {
        "external_uid": {
          "type": "string",
          "examples": [
            "author_uid_1"
          ]
        },
        "username": {
          "type": "string",
          "examples": [
            "author_username"
          ]
        }
      }
    },
    "parent_id": {
      "type": "string",
      "examples": [
        "external_ticket_uid_1"
      ]
    }
  }
}
```

#### Reply Example

```json
{
  "response_text": "This is content from an example external ticket reply.",
  "author": {
    "external_uid": "author_uid_1",
    "username": "author_username"
  },
  "parent_id": "external_ticket_uid_1"
}
```

### Response schema

```jsonschema
{
  "type": "object",
  "required": [
    "external_uid",
    "author",
    "parent_uid",
    "content",
    "created_at"
  ],
  "properties": {
    "external_uid": {
      "type": "string",
      "examples": [
        "external_ticket_uid_2"
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
            "author_uid_1"
          ]
        },
        "username": {
          "type": "string",
          "examples": [
            "author_username"
          ]
        }
      }
    },
    "parent_uid": {
      "type": "string",
      "examples": [
        "parent_uid_1"
      ]
    },
    "content": {
      "type": "string",
      "examples": [
        "This is content from an example external ticket reply."
      ]
    },
    "created_at": {
      "type": "string",
      "examples": [
        "2020-04-04 23:35:27.632879 UTC"
      ]
    }
  }
}
```

#### Response Example

```json
{
  "external_uid": "external_ticket_uid_2",
  "author": {
    "external_uid": "author_uid_1",
    "username": "author_username"
  },
  "parent_uid":"parent_uid_1",
  "content": "This is content from an example external ticket reply.",
  "created_at": "2019-01-01 23:35:27.632879 UTC",
}
```
