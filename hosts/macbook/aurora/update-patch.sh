#!/usr/bin/env bash
# Regenerates aurora.patch.xz: the omacom/linux-aurora changes rebased onto the
# AsahiLinux/linux tag that nixos-apple-silicon builds.
#
#   ./update-patch.sh <aurora commit> <aurora's asahi base tag> <nixos-apple-silicon's asahi tag>
#
# The aurora commit is the "Kernel source" in the release notes, its base tag is
# the asahi tag it is a descendant of, and the target tag is `src.tag` in
# nixos-apple-silicon's apple-silicon-support/packages/linux-asahi/default.nix.
set -euo pipefail

aurora=${1:-5ec1028c81526e1ed31db2b97e47edf8663e83cb}
base=${2:-asahi-7.1.12-1}
target=${3:-asahi-7.1.13-3}

out=$(cd "$(dirname "$0")" && pwd)/aurora.patch.xz
repo=${XDG_CACHE_HOME:-$HOME/.cache}/aurora-kernel-git
since=2026-07-01 # older than both asahi tags, keeps the fetch small

if [ ! -d "$repo" ]; then
  git init -q --bare "$repo"
  git -C "$repo" remote add aurora https://github.com/omacom/linux-aurora
  git -C "$repo" remote add asahi https://github.com/AsahiLinux/linux
fi
g() { git -C "$repo" "$@"; }

g fetch -q --filter=blob:none --shallow-since=$since aurora "$aurora:refs/heads/aurora"
g fetch -q --filter=blob:none --shallow-since=$since asahi \
  "refs/tags/$base:refs/tags/$base" "refs/tags/$target:refs/tags/$target"

# aurora's changes on top of $base, replayed onto $target
merged=$(g merge-tree --write-tree --no-messages --merge-base="$base" "$target" aurora | head -1) || true
conflicts=$(g merge-tree --write-tree --name-only --no-messages --merge-base="$base" "$target" aurora | tail -n +2 | grep . || true)

# Paths taken whole from aurora. The AVD driver was reworked on both sides, and
# the changes on each side stay inside its directory.
theirs=(drivers/media/platform/apple/avd)
# Paths kept as in $target: aurora's installer, tooling, docs and the Omarchy boot logo
ours=(tools/aurora-sep tools/aurora-tb tools/aurora-m3 tools/asahi .github Documentation
  CONTRIBUTING.md drivers/video/logo)

for f in $conflicts; do
  case $f in
    drivers/media/platform/apple/avd/*) ;;
    # aurora adds the panel node next to asahi's jack interrupt fix, which it carries too
    arch/arm64/boot/dts/apple/t6030-j51[46]s.dts) theirs+=("$f") ;;
    *) echo "unhandled conflict: $f" >&2; exit 1 ;;
  esac
done

index=$(mktemp)
trap 'rm -f "$index"' EXIT
export GIT_INDEX_FILE=$index
g read-tree "$merged"
g rm -r -q --cached --ignore-unmatch -- "${theirs[@]}" "${ours[@]}"
g ls-tree -r aurora -- "${theirs[@]}" | g update-index --index-info
g ls-tree -r "$target" -- "${ours[@]}" | g update-index --index-info
tree=$(g write-tree)

g diff --no-renames "$target" "$tree" | xz -9e -T0 > "$out"
echo "$out: $(g diff --shortstat "$target" "$tree")"
