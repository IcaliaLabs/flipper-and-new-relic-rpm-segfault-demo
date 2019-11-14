# I: Runtime Stage: ============================================================
# This is the stage where we build the runtime base image, which is used as the
# common ancestor by the rest of the stages, and contains the minimal runtime
# dependencies required for the application to run:

# Step 1: Use the official Ruby 2.6.1 Alpine image as base:
FROM ruby:2.6.1-slim-stretch AS runtime

# Step 2: We'll set '/usr/src' path as the working directory:
# NOTE: This is a Linux "standard" practice - see:
# - http://www.pathname.com/fhs/2.2/
# - http://www.pathname.com/fhs/2.2/fhs-4.1.html
# - http://www.pathname.com/fhs/2.2/fhs-4.12.html
WORKDIR /usr/src

# Step 3: We'll set the working dir as HOME and add the app's binaries path to
# $PATH:
ENV HOME=/usr/src PATH=/usr/src/bin:$PATH

# Step 4: Install the common runtime dependencies:
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  ca-certificates libpq5 curl openssl tzdata && \
  rm -rf /var/lib/apt/lists/*

# Step 9: Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash - && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    nodejs apt-transport-https software-properties-common && \
  rm -rf /var/lib/apt/lists/*

# Step 10: Fix npm uid-number error
# - see https://github.com/npm/uid-number/issues/7
RUN npm config set unsafe-perm true

# II: Development Stage: =======================================================
# In this stage we'll build the image used for development, including compilers,
# and development libraries. This is also a first step for building a releasable
# Docker image:

# Step 13: Start off from the "runtime" stage:
FROM runtime AS development

# On steps 14 through 16, we'll replicate the package installation typically
# done on the "stretch" image that are absent from the "slim" image, minus the
# packages we know are not needed.
# - see https://github.com/docker-library/buildpack-deps/blob/master/stretch

# Step 14: Install curl, netbase and wget, as it's done on
# buildpack-deps:*-curl:
RUN apt-get update && apt-get install -y --no-install-recommends \
		netbase \
		wget \
	&& rm -rf /var/lib/apt/lists/*

# Step 15: Conditionally install gnupg and dirmngr:
RUN set -ex; \
        if ! command -v gpg > /dev/null; then \
		            apt-get update; \
		            apt-get install -y --no-install-recommends \
                        gnupg \
                        dirmngr \
		            ; \
		            rm -rf /var/lib/apt/lists/*; \
	      fi

# Step 16: Install source code managers, as it's done on buildpack-deps:*-scm:
RUN apt-get update && apt-get install -y --no-install-recommends \
		git \
		openssh-client \
		\
		procps \
	&& rm -rf /var/lib/apt/lists/*

# Step 17: Install required compilers and development headers:
RUN set -ex; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    bzip2 \
    dpkg-dev \
    file \
    g++ \
    gcc \
    imagemagick \
    libbz2-dev \
    libc6-dev \
    libcurl4-openssl-dev \
    libdb-dev \
    libevent-dev \
    libffi-dev \
    libgdbm-dev \
    libgeoip-dev \
    libglib2.0-dev \
    libgmp-dev \
    libjpeg-dev \
    libkrb5-dev \
    liblzma-dev \
    libmagickcore-dev \
    libmagickwand-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libpng-dev \
    libpq-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libtool \
    libwebp-dev \
    libxml2-dev \
    libxslt-dev \
    libyaml-dev \
    make \
    patch \
    unzip \
    xz-utils \
    zlib1g-dev \
  ; \
  rm -rf /var/lib/apt/lists/*

# Step 18: Install Dockerize:
RUN export DOCKERIZE_VERSION=0.6.1 \
 && wget https://github.com/jwilder/dockerize/releases/download/v0.6.1/dockerize-linux-amd64-v${DOCKERIZE_VERSION}.tar.gz \
 && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-v${DOCKERIZE_VERSION}.tar.gz \
 && rm dockerize-linux-amd64-v${DOCKERIZE_VERSION}.tar.gz

# Step 19: Install yarn:
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  curl -sL https://deb.nodesource.com/setup_11.x | bash - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt-get update && \
  apt-get install -y --no-install-recommends yarn && \
  rm -rf /var/lib/apt/lists/*

# Step 20: Install the 'check-dependencies' node package:
RUN npm install -g check-dependencies

# Step 21: Copy the project's Gemfile + lock:
COPY Gemfile* /usr/src/

# Step 22: Install the current project gems - they can be safely changed later
# during development via `bundle install` or `bundle update`:
RUN bundle install --jobs=4 --retry=3

# # Step 25: Copy the npm package.json and yarn.lock
# COPY package.json yarn.lock /usr/src/

# # Step 26: Install the project's npm libraries running `yarn install`:
# RUN yarn install

# Step 23: Set the default command:
CMD [ "rails", "server", "-b", "0.0.0.0" ]

# III: Builder dependencies stage: =============================================
# In this stage we'll install the rest of the dependencies that could not be
# installed in the development stage, and are required by the testing & builder
# stages:

# Step 27: Start off from the "development" stage:
FROM development AS testing

# Step 28: Copy the rest of the application code
COPY . /usr/src

# Step 29: Precompile assets for the test environment:
RUN export DATABASE_URL=postgres://postgres@example.com:5432/fakedb \
    SECRET_KEY_BASE=10167c7f7654ed02b3557b05b88ece \
    RAILS_ENV=test && \
    rails assets:precompile

# V: Builder stage: ============================================================
# In this stage we'll compile assets coming from the project's source, do some
# tests and cleanup. If the CI/CD that builds this image allows it, we should
# also run the app test suites here:

# Step 30: Start off from the development stage image:
FROM testing AS builder

# Step 31: Precompile assets for production:
RUN export DATABASE_URL=postgres://postgres@example.com:5432/fakedb \
    SECRET_KEY_BASE=10167c7f7654ed02b3557b05b88ece \
    RAILS_ENV=production && \
    rails assets:clobber && \
    rails assets:precompile && \
    rails secret > /dev/null

# Step 32: Remove installed gems that belong to the development & test groups -
# we'll copy the remaining system gems into the deployable image on the next
# stage:
RUN bundle config without development:test

# Step 33: Purge the project's npm packages not required for production:
RUN yarn install --production

# Step 34: Remove files not used on release image - we won't remove the
# node_modules folder, as non-development dependencies are considered to be
# 'runtime' dependencies (i.e. pupeteer). Dependencies for the asset pipeline
# are also considered 'runtime' dependencies, as in some comfigurations assets
# may be compiled on "production" mode... see:
# - https://github.com/rails/webpacker/issues/117
# - https://github.com/rails/webpacker/issues/160
# - https://github.com/rails/webpacker/issues/165
RUN rm -rf \
    .rspec \
    Guardfile \
    bin/rspec \
    bin/checkdb \
    bin/dumpdb \
    bin/restoredb \
    bin/setup \
    bin/spring \
    bin/update \
    bin/dev-entrypoint.sh \
    config/spring.rb \
    public/packs-test \
    tmp/*

# V: Release stage: ============================================================
# In this stage, we build the final, deployable Docker image, which will be
# smaller than the images generated on previous stages:

# Step 35: Start off from the runtime stage image:
FROM runtime AS release

# Step 36: Copy the "Dockerize" command:
COPY --from=builder /usr/local/bin/dockerize /usr/local/bin/dockerize

# Step 37: Copy the remaining installed gems from the "builder" stage:
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Step 38: Copy from app code from the "builder" stage, which at this point
# should have the assets from the asset pipeline already compiled:
COPY --from=builder --chown=nobody:nogroup /usr/src /usr/src

# Step 39: Set the RAILS/RACK_ENV and PORT default values:
ENV RAILS_ENV=production RACK_ENV=production PORT=3000

# Step 40: Generate the temporary directories in case they don't already exist:
RUN for dir in cache pids sockets; do \
      tmp_dir="/usr/src/tmp/${dir}"; \
      mkdir -p ${tmp_dir} && chown -R nobody:nogroup ${tmp_dir}; \
    done

# Step 41: Set the container user to 'nobody':
USER nobody

# Step 42: Set the default command:
CMD [ "puma" ]

# Step 43 thru 47: Add label-schema.org labels to identify the build info:
ARG SOURCE_BRANCH="master"
ARG SOURCE_COMMIT="000000"
ARG BUILD_DATE="2017-09-26T16:13:26Z"
ARG IMAGE_NAME="icalialabs/flipper-and-new-relic-rpm-segfault-demo:latest"

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="Flipper and New Relic RPM Segfault Demo" \
      org.label-schema.description="A demo that replicates the segfault error caused by flipper active_record adapter and New Relic RPM" \
      org.label-schema.vcs-url="https://github.com/IcaliaLabs/flipper-and-new-relic-rpm-segfault-demo.git" \
      org.label-schema.vcs-ref=$SOURCE_COMMIT \
      org.label-schema.schema-version="1.0.0-rc1" \
      build-target="release" \
      build-branch=$SOURCE_BRANCH
