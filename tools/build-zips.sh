#!/usr/bin/env bash
# build-zips.sh -- package each skill as dist/<skill>.zip for upload to
# Claude Desktop / claude.ai (Settings > Capabilities > Skills).
#
# Each zip holds the skill's own directory at its root (<skill>/SKILL.md,
# <skill>/scripts/...), which is the layout the upload expects.
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
dist="$root/dist"
rm -rf "$dist"
mkdir -p "$dist"

for skill_md in "$root"/plugins/*/skills/*/SKILL.md; do
	skill_dir=$(dirname "$skill_md")
	skill=$(basename "$skill_dir")
	(cd "$(dirname "$skill_dir")" && zip -qr "$dist/$skill.zip" "$skill")
	echo "$dist/$skill.zip"
done
