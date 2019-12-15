# README

![](https://github.com/matteeyah/respondo/workflows/CI/badge.svg)

## Limitations

### Disqus

- Brand Disqus account has to be owner of the Disqus forum

### External Tickets

#### Format

All requests are sent to the `Brands::TicketsController#create_external`
endpoint in JSON format.

The response URL is stored in ticket metadata. Respondo will send a POST request
to the response URL and expects a response with the same schema that's used for
creating tickets.

[Zapier webhooks](https://zapier.com/apps/webhook/help) could be used to
implement this.

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
      "type": "string",
      "examples": [
        "https://response_url.com"
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
    }
  },
  "additionalProperties": false
}
```

##### Example

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
  "metadata": "https://response_url.com",
  "author": {
    "external_uid": "external_ticket_author_external_uid",
    "username": "best_username"
  }
}
```

## Development

### Environment variables

- Rails
    - `RAILS_MASTER_KEY`
        - TEST
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

#### Development

To standup an instance of respondo for development purposes run

```
docker run -p 3000:3000 respondo
```

#### Tests

To run tests inside the docker container run

```
docker run respondo rspec --require rails_helper.rb
```

#### CI

To update the CI docker image run:

- `docker build . --file Dockerfile.CI --tag matteeyah/respondo-ci:latest`
- `docker push matteeyah/respondo-ci:latest`
