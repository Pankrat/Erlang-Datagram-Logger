-module(tcp_sup).
-behaviour(supervisor).

-export([start_link/1, start_child/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link(Port) ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, [Port]).

start_child() ->
    supervisor:start_child(?SERVER, []).

init([Port]) ->
    {ok, ListenSocket} = gen_tcp:listen(Port, [{active, true}]),
    Server = {logservice_tcp, 
              {logservice_tcp, start_link, [ListenSocket]},
              temporary,
              brutal_kill,
              worker,
              [logservice_tcp]},
   Children = [Server],
   RestartStrategy = {simple_one_for_one, 1, 60},
   spawn_link(fun start_listeners/0),
   {ok, {RestartStrategy, Children}}.


% Create two workers (waiting for clients). The clients themselves spawn new
% listeners whenever a client connects. Thus, there should always be two idle
% workers.
start_listeners() ->
   supervisor:start_child(?SERVER, []),
   supervisor:start_child(?SERVER, []).
