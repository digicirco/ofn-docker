## NOT MAINTAINED
## NOT WORKING WITH MINI RACER

FROM ruby:3.0.3-alpine

# Set up timezone
ENV TZ Europe/London
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install git, yarn
RUN apk add --update \
  git \
  postgresql-dev \
  tzdata \
  nodejs \
  yarn
  # file ? add build base in here

# Install additionnal libraries for OFN
RUN apk add --update build-base

# TODO copy the rest from slim-bullseye ...






