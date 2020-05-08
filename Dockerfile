FROM ruby:2.7.1-slim

WORKDIR /usr/src/app

RUN apt update && apt install --assume-yes curl gnupg && apt remove --assume-yes cmdtest && \
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt update && apt install --assume-yes build-essential zlib1g-dev liblzma-dev libpq-dev libsqlite3-dev tzdata nodejs yarn

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

RUN yarn install

RUN rails db:migrate

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
