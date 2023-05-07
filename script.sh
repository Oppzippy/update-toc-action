#!/usr/bin/env bash
set -e
set -o pipefail

toc_file_path="$1"
default_product="$2"
region="us"

# See https://wowdev.wiki/TACT for list of products
# Usage: get_game_version PRODUCT
#   PRODUCT - wow, wow_classic, wow_classic_era, etc.
function get_version_tact() {
	local product="$1"
	curl -s "http://us.patch.battle.net:1119/$product/versions"
}

# Usage: get_game_version TACT REGION
#   TACT - contents of version TACT
#   REGION - us, eu, cn, kr, tw, sg, or xx
function get_game_version() {
	local tact="$1"
	local region="$2"
	printf "%s" "$tact" | awk -F "|" "\$1 ~ /^$region/{print \$6}"
}

# Usage: game_version_to_toc_version GAME_VERSION
#   GAME_VERSION - Game version string such as 10.1.0
# Returns the toc version, such as 100100
function game_version_to_toc_version() {
	local game_version="$1"
	echo "$game_version" | awk -F "." '{ printf "%d%02d%02d", $1, $2, $3 }'
}

# Usage: update_toc_version TOC_FILE SUFFIX VERSION
#   TOC_FILE - path to the toc file
#   SUFFIX - the suffix to use for the version (e.g. "-Classic")
#   VERSION - the replacement version number
function update_toc_version() {
	local toc_file="$1"
	local suffix="$2"
	local version="$3"
	sed -i -E "s/(## Version$suffix: )[0-9]+/\1$version/g" "$toc_file"
}

products=(wow wow_classic_era wow_classic)

declare -A version_suffixes
version_suffixes["wow_classic_era"]="-Classic"
version_suffixes["wow_classic"]="-Wrath"

for product in "${products[@]}"; do
	tact=$(get_version_tact "$product")
	game_version=$(get_game_version "$tact" "$region")
	toc_version=$(game_version_to_toc_version "$game_version")

	suffix="${version_suffixes[$product]}"
	if [[ -n "$suffix" ]]; then
		update_toc_version "$toc_file_path" "$suffix" "$toc_version"
	fi
	if [[ "$product" = "$default_product" ]]; then
		update_toc_version "$toc_file_path" "" "$toc_version"
	fi
done

