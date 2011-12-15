Erlang Datagram Logger
======================

A simple logging service that receives data from a UDP socket and serializes
these messages into a file. The primary reason I write this service is to learn
Erlang and get familiar with OTP. Eventually, it might grow into something
useful but at the moment you're better of using syslog or other logging
services.

Pros
----

    * Very simple implementation
    * Connection-less: single logging server can handle multiple clients
      logging to the same file

Cons
----

    * Packets might be silently dropped if the logging frequency is very high
      or the log service consumes data slower than clients produce it
    * Large messages will be truncated if the message size exceeds the size of
      the receive buffer (by default ~8k bytes)
