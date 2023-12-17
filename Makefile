TESTS_INIT=tests/minimal_init.lua
TESTS_DIR=tests/
# 30 mins
TIMEOUT_MINS=30*60*1000 

.PHONY: test

test:
	@nvim \
		--headless \
		--noplugin \
		-u ${TESTS_INIT} \
		-c "PlenaryBustedDirectory ${TESTS_DIR} { minimal_init = '${TESTS_INIT}', timeout = ${TIMEOUT_MINS} }"

