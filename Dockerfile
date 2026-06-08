FROM public.ecr.aws/docker/library/ruby:4.0.2-slim-bookworm as builder
WORKDIR /app

RUN apt-get update \
    && apt-get install -y curl git libpq-dev build-essential imagemagick libyaml-dev \
    && curl -sL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock .ruby-version /app/
RUN bundle config set deployment true \
	&& bundle config set without test \
	&& bundle config set path vendor/bundle
RUN bundle install
COPY package.json yarn.lock /app/
RUN npm install -g yarn \
    && yarn install --frozen-lockfile
COPY . /app/
RUN RAILS_ENV=production SECRET_KEY_BASE=sample bin/rails assets:precompile

LABEL service="cfp-app"

ENV PORT 3000
ENTRYPOINT ["bin/docker-entrypoint"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
