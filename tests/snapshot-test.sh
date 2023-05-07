#!/usr/bin/env bash
set -e
set -o pipefail

function mock_curl() {
	local url="$2"
	if [[ "$url" = "http://us.patch.battle.net:1119/wow/versions" ]]; then
		cat "snapshots/versions_wow"
	elif [[ "$url" = "http://us.patch.battle.net:1119/wow_classic/versions" ]]; then
		cat "snapshots/versions_wow_classic"
	elif [[ "$url" = "http://us.patch.battle.net:1119/wow_classic_era/versions" ]]; then
		cat "snapshots/versions_wow_classic_era"
	fi
}

cp "snapshots/Input.toc" "Test.toc"

shopt -s expand_aliases
alias curl="mock_curl"
source ../script.sh "Test.toc" "wow"

# Strip file name suffix
expected_hash="$(sha256sum snapshots/Output.toc | awk '{ print $1 }')"
actual_hash="$(sha256sum Test.toc | awk '{ print $1 }')"

if [[ "$expected_hash" = "$actual_hash" ]]; then
	echo Test passed
	rm Test.toc
else
	echo Test failed
	exit 1
fi
