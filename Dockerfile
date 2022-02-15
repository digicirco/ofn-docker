FROM ruby:3.0.3-slim-bullseye

# Set up timezone
ENV TZ Europe/London
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install git, yarn and additionnal libraries for OFN
RUN apt-get update && \
    apt-get install -y --no-install-recommends npm git build-essential libpq-dev shared-mime-info && \
    npm install -g yarn

# Clone OFN
WORKDIR /src
RUN git clone https://github.com/openfoodfoundation/openfoodnetwork --depth 1 -b v4.1.18 --single-branch

# yarn install
WORKDIR /
RUN mkdir -p apps/openfoodnetwork && \
    cp src/openfoodnetwork/package.json apps/openfoodnetwork/package.json
WORKDIR /apps/openfoodnetwork
RUN yarn install

# minimum bundle install (with rails engines)
WORKDIR /
RUN cp src/openfoodnetwork/Gemfile apps/openfoodnetwork/Gemfile && \
    cp -r src/openfoodnetwork/engines apps/openfoodnetwork/engines
WORKDIR /apps/openfoodnetwork
RUN bundle config without development test staging production && \
    bundle config set path 'vendor/cache' && \
    bundle install --jobs=4

# copy the rest of the ofn app
WORKDIR /
RUN cp -r src/openfoodnetwork/* apps/openfoodnetwork

# setup production environment
WORKDIR /apps/openfoodnetwork
RUN bundle config set --locale with production && bundle install






