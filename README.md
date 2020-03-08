# README

![](https://github.com/matteeyah/respondo/workflows/CI/badge.svg)

## Limitations

### Disqus

- Brand Disqus account has to be owner of the Disqus forum

### External Tickets

The response URL is stored in ticket metadata. Respondo will send a POST request
to the response URL and expects a response with the same schema that's used for
creating tickets.

[Zapier webhooks](https://zapier.com/apps/webhook/help) could be used to
implement this.

#### Inbound Format

All requests are sent to the `Brands::TicketsController#create_external`
endpoint in JSON format.

##### Schema

```jsonschema
{
  "type": "object",
  "required": [
    "external_uid",
    "content",
    "author"
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
    "metadata": {
      "type": "object",
      "required": [
        "response_url",
      ],
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
        }
      }
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
    }
  },
  "additionalProperties": false
}
```

##### Examples

```json
{
  "external_uid": "123hello321world",
  "content": "This is content from the external ticket example.",
  "parent_uid": "external_ticket_parent_external_uid",
  "author": {
    "external_uid": "external_ticket_author_external_uid",
    "username": "best_username"
  }
}
```

```json
{
  "external_uid": "123hello321world",
  "content": "This is content from the external ticket example.",
  "metadata": {
    "response_url": "https://response_url.com",
    "custom_provider": "hacker_news"
  },
  "author": {
    "external_uid": "external_ticket_author_external_uid",
    "username": "best_username"
  }
}
```

#### Reply Format

All replies are sent as POST requests to the `Ticket.metadata[:response_url]`
endpoint in JSON format. A response is expected.

##### Reply Schema

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

###### Reply Example

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

##### Response Schema

```jsonschema
{
  "type": "object",
  "required": [
    "external_uid",
    "author",
    "parent_uid",
    "content"
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
    }
  }
}
```

###### Response Example

```json
{
  "external_uid": "external_ticket_uid_2",
  "author": {
    "external_uid": "author_uid_1",
    "username": "author_username"
  },
  "parent_uid":"parent_uid_1",
  "content": "This is content from an example external ticket reply."
}
```

## Development

### Environment variables

Environment variables required to run the application should be stored in an
`.env` file in `DEVELOPMENT` and `TEST` environments.

- Rails
  - `RAILS_MASTER_KEY`
    - DEVELOPMENT
    - TEST
    - PRODUCTION
  - `NEW_RELIC_APP_NAME`
    - PRODUCTION
  - `NEW_RELIC_LICENSE_KEY`
    - PRODUCTION
  - `NEW_RELIC_LOG`
    - PRODUCTION

- Google OAuth
  - `GOOGLE_CLIENT_ID`
    - DEVELOPMENT
    - PRODUCTION
  - `GOOGLE_CLIENT_SECRET`
    - DEVELOPMENT
    - PRODUCTION

- Twitter OAuth
  - `TWITTER_API_KEY`
    - DEVELOPMENT
    - PRODUCTION
  - `TWITTER_API_SECRET`
    - DEVELOPMENT
    - PRODUCTION

- Disqus OAuth
  - `DISQUS_PUBLIC_KEY`
    - DEVELOPMENT
    - PRODUCTION
  - `DISQUS_SECRET_KEY`
    - DEVELOPMENT
    - PRODUCTION

### Integrating Providers

- Integrate provider OAuth
- Create provider client
- Integrate client with account model
- Implement replying to tickets from provider

### Heroku

#### Reset the database

After changing the schema in a way that's not migratable from the previous
state you need to reset the database.

- `heroku pg:reset DATABASE_URL`
- `heroku run rails db:migrate`
- `heroku restart`

### Docker

#### Build

To build the respondo image run

```
docker build . --tag respondo
```

#### Develop

To standup an instance of respondo for development purposes run

```
docker run -p 3000:3000 respondo
```

#### Test

To run tests inside the docker container run

```
docker run respondo rspec --require rails_helper.rb
```

#### CI

To update the CI docker image run:

- `docker build . --file Dockerfile.CI --tag matteeyah/respondo-ci:latest`
- `docker push matteeyah/respondo-ci:latest`

This is required when bumping the ruby version.
