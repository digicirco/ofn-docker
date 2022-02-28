FROM ruby:3.0.3-slim-bullseye AS builder

RUN apt-get update \
 && apt-get install -y --no-install-recommends git npm build-essential libpq-dev shared-mime-info \
 && rm -rf /var/lib/apt/lists/* \
 && npm install -g yarn

WORKDIR /app

COPY base/Gemfile base/Gemfile.lock ./
COPY base/engines ./engines

RUN bundle config set deployment true
RUN bundle install --jobs=4

COPY base/package.json base/yarn.lock ./
RUN yarn install --check-files

COPY base ./

FROM builder AS static
WORKDIR /app
CMD ["./bin/webpack-dev-server"]

FROM builder AS app
WORKDIR /app

ENTRYPOINT ["bundle", "exec", "rake", "db:migrate"]

CMD ["bundle", "exec", "rails s -b 0.0.0.0"]

#FROM lipanski/docker-static-website:latest AS static-production
#WORKDIR /home/static
#COPY --from=builder /app/public ./

# REDIS info
#RUN bundle exec rake ofn:sample_data

#RUN rm -rf node_modules
#RUN rm -rf tmp/*

# ENV BUNDLER_VERSION=

#ENV RAILS_ENV=production
#ENV SECRET_KEY_BASE mykey
#RUN bundle config --local set deployment TRUE \
# && bundle config --local without development test staging

#ENV SITE_URL="https://staging.openfoodnetwork.be"
#RUN bundle exec rake assets:precompile

# webpack production runner

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
# use profiles https://docs.docker.com/compose/profiles/



