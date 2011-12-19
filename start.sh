#!/bin/bash

make
erl -pa ebin -eval "application:start(slogserver)."
