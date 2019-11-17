# I: Runtime Stage: ============================================================
# This is the stage where we build the runtime base image, which is used as the
# common ancestor by the rest of the stages, and contains the minimal runtime
# dependencies required for the application to run:

# Step 1: Use the official Ruby 2.6.1 Alpine image as base:
FROM ruby:2.6.1-stretch

# Step 2: We'll set '/usr/src' path as the working directory:
# NOTE: This is a Linux "standard" practice - see:
# - http://www.pathname.com/fhs/2.2/
# - http://www.pathname.com/fhs/2.2/fhs-4.1.html
# - http://www.pathname.com/fhs/2.2/fhs-4.12.html
WORKDIR /usr/src

# Step 3: We'll set the working dir as HOME and add the app's binaries path to
# $PATH:
ENV HOME=/usr/src PATH=/usr/src/bin:$PATH

# Step 9: Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash - && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    nodejs apt-transport-https software-properties-common && \
  rm -rf /var/lib/apt/lists/*

# Step 21: Copy the project's Gemfile + lock:
COPY Gemfile* /usr/src/

# Step 22: Install the current project gems - they can be safely changed later
# during development via `bundle install` or `bundle update`:
RUN bundle install --jobs=4 --retry=3

# Step 28: Copy the rest of the application code
COPY . /usr/src

# Step 34: Remove files not used on release image - we won't remove the
# node_modules folder, as non-development dependencies are considered to be
# 'runtime' dependencies (i.e. pupeteer). Dependencies for the asset pipeline
# are also considered 'runtime' dependencies, as in some comfigurations assets
# may be compiled on "production" mode... see:
# - https://github.com/rails/webpacker/issues/117
# - https://github.com/rails/webpacker/issues/160
# - https://github.com/rails/webpacker/issues/165
RUN rm -rf \
    bin/setup \
    bin/spring \
    bin/update \
    config/spring.rb \
    tmp/*

