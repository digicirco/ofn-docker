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
RUN rm -rf tmp && rm -rf .git && rm -rf spec 

#&& rm -rf node_modules
#RUN cd vendor/bundle/ruby/3.0.0 && rm -rf cache

# Those two are to provide a null db adapter to run assets precompile without db connection issue
#

#RUN bundle config unset deployment
#RUN echo "gem 'activerecord-nulldb-adapter'\n" >> Gemfile

#RUN bundle update
#RUN bundle add activerecord-nulldb-adapter

#RUN bundle install

# RAILS_ENV=production SITE_URL="http://ofn.localhost" SECRET_KEY_BASE="mykey"

#RUN DATABASE_URL=nulldb://user:pass@127.0.0.1/dbname RAILS_ENV=development bundle exec rake assets:precompile

FROM ruby:3.0.3-slim-bullseye AS app
WORKDIR /app

RUN apt-get update \
 && apt-get install -y --no-install-recommends npm libpq-dev shared-mime-info \
 && rm -rf /var/lib/apt/lists/* \
 && npm install -g yarn

COPY --from=builder /app ./

RUN bundle config set deployment true
RUN bundle install
# strange I have to do this ...

ENTRYPOINT ["bundle", "exec", "rake", "db:migrate"]

CMD ["bundle", "exec", "rails s -b 0.0.0.0"]

#ENV SITE_URL="http://ofn.localhost"
#RUN bundle exec assets:precompile
# config.assets.initialize_on_precompile = false
# bundle exec rake RAILS_ENV=staging DATABASE_URL=nulldb://user:pass@127.0.0.1/dbname assets:precompile

# https://guides.rubyonrails.org/v3.2.13/asset_pipeline.html#precompiling-assets

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



