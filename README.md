Erlang Datagram Logger
======================

A simple logging service that receives data via a UDP or TCP socket and
serializes these messages into a file. The primary reason I write this service
is to learn Erlang and get familiar with OTP. Eventually, it might grow into
something useful but at the moment you're better of using syslog or other
logging services.

Pros
----

 * Very simple implementation
 * Connection-less: single logging server can handle multiple clients
   logging to the same file (UDP)

Cons
----

 * Packets might be silently dropped if the logging frequency is very high
   or the log service consumes data slower than clients produce it (UDP)
 * Large messages will be truncated if the message size exceeds the size of
   the receive buffer (by default ~8k bytes)

Installation
------------

`$ erl -env ERL_LIBS .`

```erlang
systools:make_script("slogserver-1.0", [local]).
systools:make_tar("slogserver-1.0", [{erts, "/usr/lib/erlang"}]).
```

Untar the archive in the target directory and run the application:

`$ ./erts-5.8.3/bin/erl -boot releases/1.0.0/start`
