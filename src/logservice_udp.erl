-module(logservice_udp).
-behaviour(gen_server).

-export([start_link/1, stop/0, log/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, code_change/3, terminate/2]).

-define(SERVER, ?MODULE).

-record(state, {port, socket, file}).

start_link(Port) -> 
    gen_server:start_link({local, ?SERVER}, ?MODULE, [Port], []).

stop() -> 
    gen_server:cast(?SERVER, stop).

log(Message) ->
    gen_server:call(?SERVER, Message).

init([Port]) -> 
    {ok, Sock} = gen_udp:open(Port, [list, inet]),
    {ok, File} = disk_log:open([{name, test}, {file, "disk_log.log"}, {format, external}]),
    {ok, #state{port = Port, socket = Sock, file = File}}.

% Log message and return logged message
handle_call(Message, _From, State) ->
    write_log(Message, State#state.file),
    {reply, Message, State}.

% Stop server upon request
handle_cast(stop, State) ->
    {stop, normal, State}.

% Log raw data packets arriving at the UDP socket
handle_info({udp, _Socket, _ClientIP, _ClientPort, RawData}, State) ->
    Message = RawData ++ "\n",
    write_log(Message, State#state.file),
    {noreply, State}.

terminate(Reason, State) -> 
    disk_log:close(State#state.file),
    io:format("Log file closed. Terminate ~p~n", [Reason]),
    ok.

code_change(_PreviousVersion, State, _Extra) -> 
    {ok, State}.

write_log(Message, File) ->
    disk_log:blog(File, Message).
