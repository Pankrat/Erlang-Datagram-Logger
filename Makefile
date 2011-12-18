ERLC ?= erlc
ERLFLAGS ?=

modules := logservice_udp logservice_tcp logservice_app logservice_sup tcp_sup
modules := $(addsuffix .beam,$(modules))
modules := $(addprefix ebin/,$(modules))

all: $(modules)

debug: ERLFLAGS += +debug_module
debug: all

ebin/%.beam: src/%.erl
	$(ERLC) $(ERLFLAGS) -o ebin $<

clean:
	rm -f $(modules)
