# README

![coverage](https://gitlab.com/matteeyah/respondo/badges/master/coverage.svg)

### Environment variables

- Rails
  - RAILS_MASTER_KEY

- Google OAuth
    - GOOGLE_CLIENT_ID
    - GOOGLE_CLIENT_SECRET

- Twitter OAuth
    - TWITTER_API_KEY
    - TWITTER_API_SECRET

### Docker

#### Build

To build the respondo image run

```
docker build . -t respondo
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
