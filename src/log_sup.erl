-module(log_sup).
-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
    % Supervises the UDP listener process
    Server = {log_udp_server, 
              {log_udp_server, start_link, [1056]},
              permanent,
              2000,
              worker,
              [log_udp_server]},
    % Supervisor of the TCP workers
    Supervisor = {log_tcp_sup, 
                  {log_tcp_sup, start_link, [1057]},
                  permanent,
                  2000,
                  supervisor,
                  [log_tcp_sup]},
   Children = [Server, Supervisor],
   % Restart with a maximum frequency of once per minute. Should the logger
   % crash more often, the application terminates.
   RestartStrategy = {one_for_one, 1, 60},
   {ok, {RestartStrategy, Children}}.

