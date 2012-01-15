-module(amqp_consumer).
-behavior(gen_server).
-export([start_link/1, stop/1]). 
-export([init/1, terminate/2, code_change/3, handle_call/3, handle_cast/2, handle_info/2]).

-include_lib("amqp_client/include/amqp_client.hrl"). 

-record(consumer_state, {connection, channel}).

% API

start_link(QueueName) -> 
    gen_server:start_link({local, ?MODULE}, ?MODULE, [QueueName], []).

stop(Pid) ->
    gen_server:call(Pid, stop).

% gen_server

init([QueueName]) -> 
    {ok, Connection} = amqp_connection:start(#amqp_params_network{}), 
    {ok, Channel} = amqp_connection:open_channel(Connection),
    QDeclare = #'queue.declare'{queue = QueueName},
    #'queue.declare_ok'{queue = Queue} = amqp_channel:call(Channel, QDeclare),
    amqp_channel:subscribe(Channel, #'basic.consume'{queue = Queue}, self()), 
    {ok, #consumer_state{connection = Connection, channel = Channel}}.

handle_info(shutdown, State) ->
    {stop, normal, State};

handle_info(#'basic.consume_ok'{}, State) ->
    {noreply, State};

handle_info(#'basic.cancel_ok'{}, State) ->
    {stop, normal, State};

handle_info({#'basic.deliver'{delivery_tag = Tag}, #amqp_msg{payload = Payload}},
            State = #consumer_state{channel = Channel}) -> 
    io:format("DEBUG: ~p~n", [Payload]), 
    Message = binary_to_list(Payload) ++ "\n",
    log_udp_server:log(Message),
    amqp_channel:cast(Channel, #'basic.ack'{delivery_tag = Tag}), 
    {noreply, State}.

handle_call(stop, _From, State) ->
    {stop, normal, ok, State}.

handle_cast(_Message, State) ->
    {noreply, State}.

terminate(_Reason, #consumer_state{connection = Connection, channel = Channel}) ->
    amqp_channel:close(Channel),
    amqp_connection:close(Connection),
    ok.

code_change(_OldVsn, State, _Extra) ->
    State.
