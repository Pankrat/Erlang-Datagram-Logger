-module(amqp_consumer). 
-export([start_link/0, init/1]). 

-include_lib("amqp_client/include/amqp_client.hrl"). 
-define(QUEUE_NAME, <<"rmqtest01">>).

start_link() -> 
    proc_lib:start_link(?MODULE, init, [self()]). 

init(Parent) -> 
    {ok, Connection} = amqp_connection:start(#amqp_params_network{}), 
    {ok, Channel} = amqp_connection:open_channel(Connection),
    QDeclare = #'queue.declare'{queue = ?QUEUE_NAME},
    #'queue.declare_ok'{queue = Queue} = amqp_channel:call(Channel, QDeclare),
    amqp_channel:subscribe(Channel, #'basic.consume'{queue = Queue}, self()), 
    receive 
        #'basic.consume_ok'{} -> ok 
    end, 
    proc_lib:init_ack(Parent, {ok, Connection}), 
    loop(Channel). 

loop(Channel) -> 
    receive 
        {#'basic.deliver'{delivery_tag = Tag}, #amqp_msg{payload = Payload}} -> 
            io:format("DEBUG: ~p~n", [Payload]), 
            amqp_channel:cast(Channel, #'basic.ack'{delivery_tag = Tag}), 
            loop(Channel) 
    end.
