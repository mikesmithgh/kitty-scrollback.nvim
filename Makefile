TESTS_INIT=tests/minimal_init.lua
TESTS_DIR=tests/
TIMEOUT_MINS=30*60*100

.PHONY: test

test:
	@nvim \
		--headless \
		--noplugin \
		-u ${TESTS_INIT} \
		-c "PlenaryBustedDirectory ${TESTS_DIR} { minimal_init = '${TESTS_INIT}', timeout = ${TIMEOUT_MINS} }"

