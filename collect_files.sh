#!/usr/bin/env bash
set -euo pipefail

INPUT_DIR="$1"
OUTPUT_DIR="$2"
shift 2

MAX_DEPTH=""
if [[ "${1-}" == "--max_depth" ]]; then
  shift
  MAX_DEPTH="$1"
  shift
fi

mkdir -p "$OUTPUT_DIR"

join_by_slash() {
  local IFS='/'
  echo "$*"
}

while IFS= read -r -d '' file; do
  rel="${file#$INPUT_DIR/}"
  IFS='/' read -ra parts <<< "$rel"
  len=${#parts[@]}

  if [[ -n "$MAX_DEPTH" && $len -gt $MAX_DEPTH ]]; then
    offset=$(( len - MAX_DEPTH ))
    parts=("${parts[@]:offset:MAX_DEPTH}")
  fi

  new_rel=$(join_by_slash "${parts[@]}")
  dest="$OUTPUT_DIR/$new_rel"
  dest_dir=$(dirname "$dest")

  mkdir -p "$dest_dir"

  if [[ -e "$dest" ]]; then
    base="${parts[-1]}"
    name="${base%.*}"
    ext="${base##*.}"
    if [[ "$ext" != "$base" ]]; then
      ext=".$ext"
    else
      ext=""
    fi

    i=1
    while [[ -e "$dest_dir/$name$i$ext" ]]; do
      ((i++))
    done
    dest="$dest_dir/$name$i$ext"
  fi

  cp -- "$file" "$dest"
done < <(find "$INPUT_DIR" -type f -print0)
