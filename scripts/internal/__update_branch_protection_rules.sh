#!/usr/bin/env bash
# dev script
# update branch protection rules via the github API
# the test matrix can get complex, this offers a convenient way to update the branch protection rules instead of clicking
# each individual action in the UI

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
gh api /repos/mikesmithgh/kitty-scrollback.nvim/branches/main/protection --method PUT --input "$script_dir/__branch-protection-rules.json"
