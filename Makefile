ebin/%.beam: src/%.erl
	erlc -o ebin $<

all: ebin/logservice_udp.beam ebin/logservice_sup.beam ebin/logservice_app.beam
