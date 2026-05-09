#!/usr/bin/env bash

# ============================================
# Usage:
#   read_folder.sh <folder> [exclude1] [exclude2] ...
# ============================================

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <folder> [exclude1] [exclude2] ..."
  exit 1
fi

TARGET=$(cd "$1" && pwd)
shift

OUTPUT="project_dump.txt"

# Store exclusions in array
EXCLUDES=("$@")

# Clear output file
: > "$OUTPUT"

echo "Project structure for: $TARGET" >> "$OUTPUT"
echo "" >> "$OUTPUT"
echo "---" >> "$OUTPUT"
echo "# FOLDER STRUCTURE" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# Helper: check if path should be excluded
should_skip() {
  local path="$1"
  for ex in "${EXCLUDES[@]}"; do
    [[ "$path" == *"$ex"* ]] && return 0
  done
  return 1
}

# ============================================
# TREE STRUCTURE
# ============================================

while IFS= read -r path; do
  if ! should_skip "$path"; then
    rel="${path#$TARGET/}"
    echo "$rel" >> "$OUTPUT"
  fi
done < <(find "$TARGET" -mindepth 1 -print)

echo "" >> "$OUTPUT"
echo "---" >> "$OUTPUT"
echo "# FILE CONTENTS" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# ============================================
# FILE CONTENTS
# ============================================

while IFS= read -r file; do
  if ! should_skip "$file"; then

    rel="${file#$TARGET/}"

    echo "```$rel" >> "$OUTPUT"

    if cat "$file" >> "$OUTPUT" 2>/dev/null; then
      :
    else
      echo "[BINARY OR UNREADABLE FILE]" >> "$OUTPUT"
    fi

    echo "```" >> "$OUTPUT"
    echo "" >> "$OUTPUT"
  fi
done < <(find "$TARGET" -type f)

echo "Output written to $OUTPUT"