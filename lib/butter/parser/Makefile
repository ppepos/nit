all: parser test

parser:
	../../../contrib/nitcc/src/nitcc butter.sablecc

test:
	nitc butter_test_parser.nit

butter:
	nitc butter.nit

test_butter:
	./butter test.html
