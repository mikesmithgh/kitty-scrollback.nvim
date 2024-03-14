TESTS_INIT = tests/minimal_init.lua
# 30 mins
TIMEOUT_MINS := $(shell echo $$((30 * 60 * 1000)))


.PHONY: test
.PHONY: test-sequential
.PHONY: test-all
.PHONY: test-all-sequential
.PHONY: test-demo
.PHONY: test-demo-main
.PHONY: test-demo-config
.PHONY: record-demo
.PHONY: record-demo-main

test:
	@nvim \
		--headless \
		--noplugin \
		-u ${TESTS_INIT} \
		-c "lua require([[plenary.test_harness]]).test_directory([[tests ! -regex .*_demo.*_spec.*]], { minimal_init = '"${TESTS_INIT}"', timeout = "${TIMEOUT_MINS}", })"

test-sequential:
	@nvim \
		--headless \
		--noplugin \
		-u ${TESTS_INIT} \
		-c "lua require([[plenary.test_harness]]).test_directory([[tests ! -regex .*_demo.*_spec.*]], { minimal_init = '"${TESTS_INIT}"', timeout = "${TIMEOUT_MINS}", sequential = true, })"

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

test-demo:
	@nvim \
		--headless \
		--noplugin \
		-u ${TESTS_INIT} \
		-c "lua require([[plenary.test_harness]]).test_directory([[tests -regex .*_demo.*_spec.*]], { minimal_init = '"${TESTS_INIT}"', timeout = "${TIMEOUT_MINS}", })"

test-demo-main:
	@nvim \
		--headless \
		--noplugin \
		-u ${TESTS_INIT} \
		-c "lua require([[plenary.test_harness]]).test_directory([[tests -name kitty_scrollback_demo_spec.lua]], { minimal_init = '"${TESTS_INIT}"', timeout = "${TIMEOUT_MINS}", })"

test-demo-config:
	@nvim \
		--headless \
		--noplugin \
		-u ${TESTS_INIT} \
		-c "lua require([[plenary.test_harness]]).test_directory([[tests -regex .*kitty_scrollback_config_demo.*_spec.lua]], { minimal_init = '"${TESTS_INIT}"', timeout = "${TIMEOUT_MINS}", })"

record-demo:
	@nvim \
		--headless \
		--noplugin \
		-u ${TESTS_INIT} \
		-c "lua vim.env.KSB_RECORD_DEMO = 'true' require([[plenary.test_harness]]).test_directory([[tests -regex .*_demo.*_spec.*]], { minimal_init = '"${TESTS_INIT}"', timeout = "${TIMEOUT_MINS}", sequential = true, })"

record-demo-main:
	@nvim \
		--headless \
		--noplugin \
		-u ${TESTS_INIT} \
		-c "lua vim.env.KSB_RECORD_DEMO = 'true' require([[plenary.test_harness]]).test_directory([[tests -name kitty_scrollback_demo_spec.lua]], { minimal_init = '"${TESTS_INIT}"', timeout = "${TIMEOUT_MINS}", sequential = true, })"
