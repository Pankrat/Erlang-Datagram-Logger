{application, 
 logservice,
 [
  {description, "Datagram-based logging server (my first OTP app)"},
  {vsn, "0.1.0"},
  {modules, [logservice_app,
             logservice_sup,
             logservice_udp,
             logservice_tcp,
             tcp_sup]},
  {registered, [logservice_sup]},
  {applications, [kernel, stdlib]},
  {mod, {logservice_app, []}}
 ]
}.
