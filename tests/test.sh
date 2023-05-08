#!/usr/bin/env bash
script_path="$(readlink -f -- "$0")"
script_dir="$(dirname -- $script_path)"

cd "$script_dir"
tests=(
	"test-all-versions.sh"
	"test-only-makes-needed-http-requests.sh"
)

failed_tests=0
for test in "${tests[@]}"
do
	echo "Running $test"
	./$test

	# Check the exit code of the script
	if [ $? -eq 0 ]; then
		echo "Test passed"
	else
		echo "Test failed"
		failed_tests=$((failed_tests+1))
	fi
done

if [[ $failed_tests > 0 ]]; then
	echo "$failed_tests test(s) failed."
	exit 1
fi
