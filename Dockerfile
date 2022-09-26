FROM ruby:3.1.2
WORKDIR /app
RUN apt update -qq && apt install -y \
  build-essential \
  ruby-dev \
  nodejs
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
COPY bin /app/bin
COPY config /app/config
RUN gem install bundler
RUN bundle install
CMD ["bundle", "exec", "rails", "server", "-p", "3000", "-b", "0.0.0.0"]
