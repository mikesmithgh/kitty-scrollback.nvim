TESTS_INIT = tests/minimal_init.lua
# 30 mins
TIMEOUT_MINS := $(shell echo $$((30 * 60 * 1000)))


.PHONY: test
.PHONY: test-sequential
.PHONY: test-all
.PHONY: test-all-sequential

test:
	@nvim \
		--headless \
		--noplugin \
		-u ${TESTS_INIT} \
		-c "lua require([[plenary.test_harness]]).test_directory([[tests ! -regex .*_config.*_spec.*]], { minimal_init = '"${TESTS_INIT}"', timeout = "${TIMEOUT_MINS}", })"

test-sequential:
	@nvim \
		--headless \
		--noplugin \
		-u ${TESTS_INIT} \
		-c "lua require([[plenary.test_harness]]).test_directory([[tests ! -regex .*_config.*_spec.*]], { minimal_init = '"${TESTS_INIT}"', timeout = "${TIMEOUT_MINS}", sequential = true, })"

test-all:
	@nvim \
		--headless \
		--noplugin \
		-u ${TESTS_INIT} \
		-c "lua require([[plenary.test_harness]]).test_directory([[tests]], { minimal_init = '"${TESTS_INIT}"', timeout = "${TIMEOUT_MINS}", })"

test-all-sequential:
	@nvim \
		--headless \
		--noplugin \
		-u ${TESTS_INIT} \
		-c "lua require([[plenary.test_harness]]).test_directory([[tests]], { minimal_init = '"${TESTS_INIT}"', timeout = "${TIMEOUT_MINS}", sequential = true, })"

