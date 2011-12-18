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
    {ok, Socket} = gen_tcp:listen(Port, [{active, true}]),
    Server = {logservice_tcp, 
              {logservice_tcp, start_link, [Socket]},
              temporary,
              brutal_kill,
              worker,
              [logservice_tcp]},
   Children = [Server],
   % Restart with a maximum frequency of once per minute. Should the logger
   % crash more often, the application terminates.
   RestartStrategy = {one_for_one, 1, 60},
   {ok, {RestartStrategy, Children}}.

