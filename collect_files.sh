#!/usr/bin/env bash

set -euo pipefail

if (( $# < 2 )); then
  echo "Usage: $0 /path/to/input_dir /path/to/output_dir [--max_depth N]" >&2
  exit 1
fi

INPUT_DIR="$1"
OUTPUT_DIR="$2"
shift 2

MAX_DEPTH=""

if [[ "${1-}" == "--max_depth" ]]; then
  if [[ -z "${2-}" || ! "$2" =~ ^[0-9]+$ ]]; then
    echo "Ошибка: неправильно указан --max_depth ." >&2
    exit 1
  fi
  MAX_DEPTH="$2"
fi

if [[ ! -d "$INPUT_DIR" ]]; then
  echo "Ошибка: входная директория '$INPUT_DIR' не существует." >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

if [[ -n "$MAX_DEPTH" ]]; then
  FIND_CMD=(find "$INPUT_DIR" -maxdepth "$MAX_DEPTH" -type f -print0)
else
  FIND_CMD=(find "$INPUT_DIR" -type f -print0)
fi

"${FIND_CMD[@]}" | while IFS= read -r -d '' file; do
  filename="$(basename "$file")"
  name="${filename%.*}"
  ext="${filename##*.}"
  if [[ "$ext" != "$filename" ]]; then
    ext=".$ext"
  else
    ext=""
  fi

  dest="$OUTPUT_DIR/$filename"
  if [[ -e "$dest" ]]; then
    i=1
    while [[ -e "$OUTPUT_DIR/${name}${i}${ext}" ]]; do
      ((i++))
    done
    dest="$OUTPUT_DIR/${name}${i}${ext}"
  fi

  cp -- "$file" "$dest"
done
