FROM ruby:3.0.3-slim-bullseye

ENV TZ Europe/London

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install all the requirements
RUN apt-get update && \
    apt-get install -y --no-install-recommends npm git build-essential libpq-dev shared-mime-info && \
    npm install -g yarn

WORKDIR /src

RUN git clone https://github.com/openfoodfoundation/openfoodnetwork --depth 1 -b v4.1.18 --single-branch

WORKDIR /

RUN mkdir -p apps/openfoodnetwork && \
    cp src/openfoodnetwork/package.json apps/openfoodnetwork/package.json

WORKDIR /apps/openfoodnetwork

RUN yarn install

WORKDIR /

RUN cp src/openfoodnetwork/Gemfile apps/openfoodnetwork/Gemfile && \
    cp -r src/openfoodnetwork/engines apps/openfoodnetwork/engines

WORKDIR /apps/openfoodnetwork

RUN bundle config without development test staging production && \
    bundle config set path 'vendor/cache' && \
    bundle install --jobs=4





