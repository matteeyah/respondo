# README

![](https://github.com/matteeyah/respondo/workflows/CI/badge.svg)

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
