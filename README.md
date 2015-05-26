HelloPingpong
=============

A sample service using [hello][]: It answers "pong" on a "ping".


== Running

    $> iex -S mix

== Building

Install the following external dependencies (the names given are
the ones found on a debian / ubuntu):

* erlang-dev
* erlang-parsetools
* erlang-eunit
* erlang-yecc
* libavahi-compat-libdnssd-dev

And then compile:

    $> mix do deps.get
    $> mix do compile
