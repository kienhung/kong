# KONG - The API Layer

[![Build Status][travis-badge]][travis-url]
[![Coverage Status][coveralls-badge]][coveralls-url]
[![Gitter][gitter-badge]][gitter-url]

Kong is a scalable, lightweight open source API Layer *(also known as a API Gateway, or API Middleware)*, built on top of NGINX with focus on high performance and reliability. 

## Table of Contents

1. [Installation](#installation)
2. [Documentation](#documentation)
3. [Usage](#usage)
4. [Development](#development)
  1. [Makefile Operations](#makefile-operations)

## Installation

1. Download: [http://getkong.org/download](http://getkong.org/download)
2. Run `kong start`

**Note:** Kong requires [Cassandra 2.1.3](http://archive.apache.org/dist/cassandra/2.1.3/)

## Documentation

Visit [getkong.org](http://getkong.org/docs/) for the official Kong documentation.

## Usage

Use Kong through the `kong` CLI:

```bash
$ kong --help
```

**Note** If you installed Kong via one of the [available methods](http://getkong.org/download/), then `kong` should already be in your `$PATH`.

## Development

1. Clone the repository and make it your working directory.
2. Run `[sudo] make install`
  
  This will build and install the `kong` luarock globally.

3. Run `make dev`
   
  This will install development dependencies and create your environment configuration files:

  - `kong_TESTS.yml`
  - `kong_DEVELOPMENT.yml`

4. Run the tests:
  
  ```bash
  make test-all
  ```
  
5. Run Kong with the development configuration file:
   
   ```bash
   $ kong start -c kong_DEVELOPMENT.yml
   ```

#### Makefile Operations

When developing, use the `Makefile` for doing the following operations:

| Name          | Description                                                                                         |
| ------------- | --------------------------------------------------------------------------------------------------- |
| `install`     | Install the Kong luarock globally                                                                   |
| `dev`         | Setup your development environment                                                                  |
| `run`         | Run the `DEVELOPMENT` environment (`kong_DEVELOPMENT.yml`)                                          |
| `seed`        | Seed the `DEVELOPMENT` environment (`kong_DEVELOPMENT.yml`)                                         |
| `drop`        | Drop the `DEVELOPMENT` environment (`kong_DEVELOPMENT.yml`)                                         |
| `lint`        | Lint Lua files in `kong/`                                                                            |
| `coverage`    | Run unit tests + coverage report (only unit-tested modules)                                         |
| `test`        | Run the unit tests                                                                                  |
| `test-proxy`  | Run the proxy integration tests                                                                     |
| `test-server` | Run the server integration tests                                                                    |
| `test-api`    | Run the api integration tests                                                                       |
| `test-all`    | Run all unit + integration tests at once                                                            |

[travis-url]: https://travis-ci.org/Mashape/kong
[travis-badge]: https://img.shields.io/travis/Mashape/kong.svg?style=flat
[coveralls-url]: https://coveralls.io/r/Mashape/kong?branch=master
[coveralls-badge]: https://coveralls.io/repos/Mashape/kong/badge.svg?branch=master
[gitter-url]: https://gitter.im/Mashape/kong?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge
[gitter-badge]: https://badges.gitter.im/Join%20Chat.svg
