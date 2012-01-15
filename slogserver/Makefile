ERLC ?= erlc
ERLFLAGS ?=

modules := log_app log_sup log_udp_server log_tcp_sup log_tcp_server amqp_consumer
modules := $(addsuffix .beam,$(modules))
modules := $(addprefix ebin/,$(modules))

all: $(modules)

debug: ERLFLAGS += +debug_module
debug: all

ebin/%.beam: src/%.erl
	$(ERLC) $(ERLFLAGS) -o ebin $<

clean:
	rm -f $(modules)
