# Flipper ActiveRecord Adapter + New Relic RPM Segfaults Demo

## How to run

You'll require `git`, `docker` and `docker-compose` installed on your system.

You'll also need a New Relic License Key. I obtained mine - for purposes of this
demo - by creating a Heroku app, and adding the New Relic addon free.

```
# Clone the project - sorry for the long repo name:
git clone https://github.com/IcaliaLabs/flipper-and-new-relic-rpm-segfault-demo.git segfault-demo

# Change into the project directory:
cd segfault-demo

# Use your license here:
echo DEMO_NEW_RELIC_LICENSE_KEY=XXXXXXXXXXXX > .env

# Run the demo:
docker-compose run demo
```

This will build an image, launch a container with the code and run the
`rails db:setup` command, which will cause a segfault when New Relic gathers the
environment report.