# yarn install
FROM node:17-bullseye-slim AS yarn-builder

RUN apt-get update

WORKDIR /usr/src/app
COPY package.json yarn.lock ./

RUN yarn install --immutable --immutable-cache --check-cache

# minimum bundler install (with rails engines)
FROM ruby:3.0.3-slim-bullseye AS bundler-builder

RUN apt-get update \
 && apt-get install -y --no-install-recommends git build-essential libpq-dev shared-mime-info \
 && rm -rf /var/lib/apt/lists/* 

WORKDIR /usr/src/app
COPY --from=yarn-builder /usr/src/app ./
COPY Gemfile Gemfile.lock ./
COPY engines ./engines

 RUN bundle config without development test staging production \
  && bundle install --jobs=4

# production builder
FROM bundler-builder AS production-bundler-builder

WORKDIR /usr/src/app

# WARNING should environment be set to production from the beginning ... ? 
# WARNING Does it change something for ruby. Like ruby deployment flag ?
RUN bundle config without development test \ 
 && bundle install --jobs=4

# webpack production runner
FROM ruby:3.0.3-slim-bullseye AS production-runner

# webpack works without libpq-dev shared-mime-info
RUN apt-get update && \
    apt-get install -y --no-install-recommends npm libpq-dev shared-mime-info && \
    npm install -g yarn

WORKDIR /usr/src/app

COPY --from=production-bundler-builder /usr/src/app ./
COPY --from=production-bundler-builder /usr/local/bundle/ /usr/local/bundle/
COPY openfoodnetwork ./

WORKDIR /

# TODO set a group for engines bundles so I can seperate it in the build and have a better base image

#RUN bundle config without development test \ 
# && bundle install --jobs=4 \ 


# TODO multistage building https://ledermann.dev/blog/2018/04/19/dockerize-rails-the-lean-way/
# TODO https://ledermann.dev/blog/2020/01/29/building-docker-images-the-performant-way/
# TODO how to use cache from https://www.reddit.com/r/docker/comments/ffybys/understanding_cache_from_in_compose/
# TODO group dependencies for webpack mail jobs and main app https://bundler.io/guides/groups.html
# TODO should I use buildkit https://github.com/moby/buildkit
# best pratices
# security best practices https://snyk.io/blog/10-best-practices-to-containerize-nodejs-web-applications-with-docker/




