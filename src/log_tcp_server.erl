% Connection-based logging via TCP socket. Whenever a client connects another
% listener is started. The logging is done by another process that serializes
% the incoming logs from all processes.

-module(log_tcp_server).
-behaviour(gen_server).

-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, code_change/3, terminate/2]).

-record(state, {socket}).

start_link(Socket) -> 
    gen_server:start_link(?MODULE, [Socket], []).

init([Socket]) ->
    {ok, #state{socket = Socket}, 0}.

% Simple echo for now
handle_call(Message, _From, State) ->
    {reply, Message, State}.

% Stop server upon request
handle_cast(stop, State) ->
    {stop, normal, State}.

% Dispatch raw data packets arriving at the TCP socket
handle_info({tcp, _Socket, RawData}, State) ->
    Message = RawData ++ "\n",
    log_udp_server:log(Message),
    {noreply, State};
handle_info({tcp_closed, _Socket}, State) ->
    io:format("Client disconnected from TCP socket. Stop listener.~n"),
    {stop, normal, State};
handle_info(timeout, #state{socket = Socket} = State) ->
    {ok, _Socket} = gen_tcp:accept(Socket),
    io:format("Client connected to TCP socket. Starting new listener.~n"),
    log_tcp_sup:start_child(),
    {noreply, State}.

terminate(_Reason, _State) -> 
    ok.

code_change(_PreviousVersion, State, _Extra) -> 
    {ok, State}.
