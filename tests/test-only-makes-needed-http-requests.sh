#!/usr/bin/env bash
set -e
set -o pipefail

input_toc="snapshots/test-only-makes-needed-http-requests-input.toc"
expected_output_toc="snapshots/test-only-makes-needed-http-requests-output.toc"
output_toc="test-only-makes-needed-http-requests.toc"

num_requests=0
function mock_curl() {
	local url="$2"
	if [[ "$url" = "http://us.patch.battle.net:1119/wow/versions" ]]; then
		echo http request made for product wow >&2
		exit 1
	elif [[ "$url" = "http://us.patch.battle.net:1119/wow_classic/versions" ]]; then
		cat "snapshots/versions_wow_classic"
	elif [[ "$url" = "http://us.patch.battle.net:1119/wow_classic_era/versions" ]]; then
		echo http request made for product wow_classic_era >&2
		exit 1
	fi
}

cp "$input_toc" "$output_toc"

shopt -s expand_aliases
alias curl="mock_curl"
source ../script.sh "$output_toc" "wow_classic"

# Strip file name suffix
expected_hash="$(sha256sum "$expected_output_toc" | awk '{ print $1 }')"
actual_hash="$(sha256sum "$output_toc" | awk '{ print $1 }')"

if [[ "$expected_hash" = "$actual_hash" ]]; then
	rm "$output_toc"
else
	echo Output does not match expected snapshot >&2
	exit 1
fi
