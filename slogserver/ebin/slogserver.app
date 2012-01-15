{application, 
 slogserver,
 [
  {description, "Simple socket-based logging server"},
  {vsn, "0.1.0"},
  {modules, [log_app,
             log_sup,
             log_udp_server,
             log_tcp_sup,
             log_tcp_server,
             amqp_consumer]},
  {registered, [log_sup]},
  {applications, [kernel, stdlib]},
  {mod, {log_app, []}}
 ]
}.
