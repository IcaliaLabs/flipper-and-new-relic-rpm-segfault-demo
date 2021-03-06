#! /bin/sh

# The Docker App Container's development entrypoint.
# This is a script used by the project's Docker development environment to
# setup the app containers and databases upon runnning.
set -e

: ${APP_PATH:="/usr/src"}
: ${APP_TEMP_PATH:="$APP_PATH/tmp"}
: ${APP_SETUP_LOCK:="$APP_TEMP_PATH/setup.lock"}
: ${APP_SETUP_WAIT:="5"}

# 1: Define the functions lock and unlock our app containers setup processes:
lock_setup() { mkdir -p $APP_TEMP_PATH && touch $APP_SETUP_LOCK; }
unlock_setup() { rm -rf $APP_SETUP_LOCK; }
wait_setup() { echo "Waiting for app setup to finish..."; sleep $APP_SETUP_WAIT; }

# 2: 'Unlock' the setup process if the script exits prematurely:
trap unlock_setup HUP INT QUIT KILL TERM EXIT

# 3: Specify a default command, in case it wasn't issued:
if [ -z "$1" ]; then set -- rails server -p 3000 -b 0.0.0.0 "$@"; fi

if [ "$1" = "rails" ] || [ "$1" = "webpack-dev-server" ]
then

# 4: Wait until the setup 'lock' file no longer exists:
while [ -f $APP_SETUP_LOCK ]; do wait_setup; done

# 5: 'Lock' the setup process, to prevent a race condition when the project's
# app containers will try to install gems and setup the database concurrently:
lock_setup

# 6: Check if the gem dependencies are met, or install
bundle check || bundle install

# 7: Check yarn dependencies, or install:
check-dependencies || yarn install

# 7: Check if the database exists, or setup the database if it doesn't, as it is
# the case when the project runs for the first time.
#
# We'll use a custom script `checkdb` (inside our app's `bin` folder), instead
# of running `rails db:version` to avoid loading the entire rails app for this
# simple check - we'll be skipping this step on the webpack container:
if [ "$1" != "webpack-dev-server" ]; then
  dockerize -wait tcp://postgres:5432 -timeout 30s
fi

# 8: 'Unlock' the setup process:
unlock_setup

# 9: If the command to execute is 'rails server', then force it to write the
# pid file into a non-shared container directory. Suddenly killing and removing
# app containers without this would leave a pidfile in the project's tmp dir,
# preventing the app container from starting up on further attempts:
if [ "$2" = "s" ] || [ "$2" = "server" ]; then rm -rf /usr/src/tmp/pids/server.pid; fi
fi

# 10: Setup test coverage for codeclimate build
# if set|grep '^CC_TEST_REPORTER_ID=' >/dev/null; then
#   curl -L https://codeclimate.com/downloads/test-reporter/test-reporter-latest-linux-amd64 > ./cc-test-reporter
#   chmod +x ./cc-test-reporter
#   ./cc-test-reporter before-build
# fi

# 11: Execute the given or default command:
exec "$@"
