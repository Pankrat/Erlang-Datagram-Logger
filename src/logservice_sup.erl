-module(logservice_sup).
-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
    Server = {logservice_udp, 
              {logservice_udp, start_link, [1056]},
              permanent,
              2000,
              worker,
              [logservice_udp]},
   Children = [Server],
   % Restart with a maximum frequency of once per minute. Should the logger
   % crash more often, the application terminates.
   RestartStrategy = {one_for_one, 1, 60},
   {ok, {RestartStrategy, Children}}.

