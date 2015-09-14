HelloTestServer [![Build Status](https://travis-ci.org/travelping/hello_test_server.svg)](https://travis-ci.org/travelping/hello_test_server) [![Coverage Status](https://coveralls.io/repos/travelping/hello_test_server/badge.svg?branch=master&service=github)](https://coveralls.io/github/travelping/hello_test_server?branch=master)
=============

A test service using [hello](https://github.com/travelping/hello):
You can use it to mock a server which normally use hello for testing and benchmarking your client application.

There are 3 answers type:

1. "pong" on a "ping".
2. Replies json from `PATH`/METHOD/\* (round-robin)
   For example `PATH/foo.bar/reply1.json`
3. You can write you own method handler. For method `foo.bar` it will be `PATH/foo.bar.ex` and look like:
```elixir
case params do
  %{"key" => 1} -> "response"
  %{"key" => 2} -> "response2"
  _ -> %{"error": "unknown"}
end
``` 

## Running

There are two ways of running the HelloTestServer.
At first you are able to run it as a mix task, which works really well for prototyping.
After building the test-server (see below) just run

    $> mix hellotest --listen  zmq-tcp://127.0.0.1:26000 --path PATH

The parameters for the URL can be shown by

    $> mix hellotest -h

The second way is to use [exrm](https://github.com/bitwalker/exrm) releases by typing

    $> mix release

For more information, please look on the page of the [exrm](https://github.com/bitwalker/exrm) project.

[quote]
#Notice
HelloTestServer expects you to run an instance of Graphite Carbon on port 2003.
You can either use it for analysing the logs, for example with the following [vagrant image](https://github.com/pellepelster/graphite-grafana-vagrant-box),
ignore the connection error when starting the application or following the output in another window running `nc -l 2003`
[/quote]

## Building

Minimal requirements are:

* erlang >= 17 (better 17.5)
* elixir >= 1.0 (1.1.0-dev)
* Apple Bonjour or a compatible API such as Avahi with it's compatibility layer along with the appropriate development files:
    * OS X - bundled
    * Windows - Bonjour SDK
    * BSD/Linux - search for Avahi in your operating systems software manager

If you install erlang on Ubuntu, install aditionally:

* erlang-parsetools
* erlang-eunit

And then:

    $> mix do deps.get, compile


There are a little bit tests:

    $> mix test
