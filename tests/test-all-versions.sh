#!/usr/bin/env bash
set -e
set -o pipefail

input_toc="snapshots/test-all-versions-input.toc"
expected_output_toc="snapshots/test-all-versions-output.toc"
output_toc="test-all-versions.toc"

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

cp "$input_toc" "$output_toc"

shopt -s expand_aliases
alias curl="mock_curl"
source ../script.sh "$output_toc" "wow"

# Strip file name suffix
expected_hash="$(sha256sum "$expected_output_toc" | awk '{ print $1 }')"
actual_hash="$(sha256sum "$output_toc" | awk '{ print $1 }')"

if [[ "$expected_hash" = "$actual_hash" ]]; then
	echo Test passed
	rm "$output_toc"
else
	echo Test failed
	exit 1
fi
