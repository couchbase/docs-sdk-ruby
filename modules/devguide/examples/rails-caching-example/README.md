# README

This project demonstrate usage of Couchbase as a caching provider for Rails
project.

Install all dependencies and configure the project:

    ./bin/setup

Enable caching for development environment (find more details at
`config/environments/development.rb`)

    bundle exec rails dev:cache

Configure Couchbase cluster and export environment variables as it is configured
in `config/environments/development.rb`:

    export COUCHBASE_CONNECTION_STRING=couchbase://192.168.107.128

Start the server:

    bundle exec rails server

Navigate to http://localhost:3000
