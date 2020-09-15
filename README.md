# Heroku buildpack: Redis

This is a [Heroku buildpack](http://devcenter.heroku.com/articles/buildpacks) that
allows an application to use an [stunnel](http://stunnel.org) to connect securely to
Heroku Redis.  It is meant to be used in conjunction with other buildpacks.

## Usage

First you need to set this buildpack as your initial buildpack with:

```console
$ heroku buildpacks:set https://github.com/mcity/heroku-buildpack-redis
```

Then you can add other buildpack(s) to compile your code like so:

```console
$ heroku buildpacks:add https://github.com/heroku/heroku-buildpack-ruby.git
```

Choose the correct buildpack(s) for the language(s) used in your application.

For more information on using multiple buildpacks check out [this devcenter article](https://devcenter.heroku.com/articles/using-multiple-buildpacks-for-an-app).

Next, for each process that should connect to Redis securely, you will need to preface the command in
your `Procfile` with `bin/start-stunnel`. In this example, we want the `web` process to use
a secure connection to Heroku Redis.  The `worker` process doesn't interact with Redis, so
`bin/start-stunnel` was not included:

    $ cat Procfile
    web:    bin/start-stunnel bundle exec unicorn -p $PORT -c ./config/unicorn.rb -E $RACK_ENV
    worker: bundle exec rake worker

We're then ready to deploy to Heroku with an encrypted connection between the dynos and Heroku
Redis:

    $ git push heroku master
    ...
    -----> Fetching custom git buildpack... done
    -----> Multipack app detected
    =====> Downloading Buildpack: https://github.com/heroku/heroku-buildpack-redis.git
    =====> Detected Framework: stunnel
           Using stunnel version: 5.02
           Using stack version: cedar
    -----> Fetching and vendoring stunnel into slug
    -----> Moving the configuration generation script into app/bin
    -----> Moving the start-stunnel script into app/bin
    -----> stunnel done
    =====> Downloading Buildpack: https://github.com/heroku/heroku-buildpack-ruby.git
    =====> Detected Framework: Ruby/Rack
    -----> Using Ruby version: ruby-2.2.2
    -----> Installing dependencies using Bundler version 1.7.12
    ...

## Configuration

The buildpack will install and configure stunnel to connect to `REDIS_URL` over a SSL connection. Prepend `bin/start-stunnel`
to any process in the Procfile to run stunnel alongside that process.

### Stunnel settings

Some settings are configurable through app config vars at runtime:

- ``STUNNEL_HOSTPORT``: The host and port for the destination endpoint (Redis).  ie.  cache.mvillage.um.city:6380
- ``REDIS_URL``: Include the username (optional) and password for the destination redis instance.  Point at localhost:6380, which will be the Stunnel endpoint on your Dyno.
ie. redis://:<password>@localhost:6380

### Troubleshooting

#### Redis URLs without a username

This buildpack assumes that every URL is with username and password. As Redis does not support
usernames but only passwords you may encounter a problem here. Just invent a username and put it
in your URL.

    redis://:password@example.com:6379
    => Invent username (here "h")
    redis://h:password@example.com:6379
