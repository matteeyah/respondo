# README

![](https://github.com/matteeyah/respondo/workflows/CI/badge.svg)

## External Tickets

### Format

All requests are sent to the `Brands::TicketsController#create_external`
endpoint in JSON format.

#### Schema

```jsonschema
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "create_external.json",
  "type": "object",
  "title": "External Ticket Schema",
  "required": [
    "external_uid",
    "content",
    "author"
  ],
  "properties": {
    "external_uid": {
      "$id": "#/properties/external_uid",
      "type": "string",
      "title": "The external ticket external_uid",
      "default": "",
      "examples": [
        "123hello321world"
      ],
      "pattern": "^(.*)$"
    },
    "content": {
      "$id": "#/properties/content",
      "type": "string",
      "title": "The external ticket content",
      "default": "",
      "examples": [
        "This is content from an example external ticket."
      ],
      "pattern": "^(.*)$"
    },
    "parent_uid": {
      "$id": "#/properties/parent_uid",
      "type": "string",
      "title": "The external ticket parent_uid",
      "default": "",
      "examples": [
        "external_ticket_parent_uid"
      ],
      "pattern": "^(.*)$"
    },
    "author": {
      "$id": "#/properties/author",
      "type": "object",
      "title": "The external ticket Author Schema",
      "required": [
        "external_uid",
        "username"
      ],
      "properties": {
        "external_uid": {
          "$id": "#/properties/author/properties/external_uid",
          "type": "string",
          "title": "The external ticket author external_uid",
          "default": "",
          "examples": [
            "external_ticket_author_id"
          ],
          "pattern": "^(.*)$"
        },
        "username": {
          "$id": "#/properties/author/properties/username",
          "type": "string",
          "title": "The external ticket author username",
          "default": "",
          "examples": [
            "best_username_ever"
          ],
          "pattern": "^(.*)$"
        }
      }
    }
  }
}
```

#### Example

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
