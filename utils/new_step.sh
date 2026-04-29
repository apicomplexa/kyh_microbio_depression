#!/usr/bin/env bash
set -euo pipefail

STEPS_DIR="workflow/steps"

usage() {
  echo "Usage: $0 <step_name>"
  echo "Example: $0 alignment"
  exit 1
}

# --- args ---
[[ $# -ne 1 ]] && usage
RAW_NAME="$1"

# нормализация: lowercase, пробелы -> _, убрать недопустимые символы
STEP_NAME="$(echo "$RAW_NAME" \
  | tr '[:upper:]' '[:lower:]' \
  | tr ' ' '_' \
  | sed 's/[^a-z0-9_]/_/g' \
  | sed 's/__*/_/g' \
  | sed 's/^_//; s/_$//')"

[[ -z "$STEP_NAME" ]] && {
  echo "Error: invalid step name after normalization"
  exit 1
}

# --- ensure base dir ---
mkdir -p "$STEPS_DIR"

# --- find next index ---
LAST_NUM=0
shopt -s nullglob
for d in "$STEPS_DIR"/*/; do
  base="$(basename "$d")"
  if [[ "$base" =~ ^([0-9]{2})_ ]]; then
    num="${BASH_REMATCH[1]}"
    (( num > LAST_NUM )) && LAST_NUM=$num
  fi
done
shopt -u nullglob

NEXT_NUM=$((LAST_NUM + 1))
PREFIX=$(printf "%02d" "$NEXT_NUM")

STEP_DIR="${STEPS_DIR}/${PREFIX}_${STEP_NAME}"

# --- guard ---
if [[ -e "$STEP_DIR" ]]; then
  echo "Error: step already exists: $STEP_DIR"
  exit 1
fi

# --- create structure ---
mkdir -p \
  "$STEP_DIR/scripts" \
  "$STEP_DIR/notebooks"

# --- files ---
cat > "$STEP_DIR/Snakefile" << 'EOF'
# Snakefile for step
# Define rules local to this module

rule all:
    input:
        # define final targets for this step
        []
EOF

cat > "$STEP_DIR/conda.env.yaml" << EOF
name: ${PREFIX}_${STEP_NAME}
channels:
  - conda-forge
  - bioconda
  - nodefaults
dependencies:
  - python=3.13
EOF

cat > "$STEP_DIR/README.md" << EOF
# ${PREFIX}_${STEP_NAME}

## Description
Short description of the step.

## Inputs
- ...

## Outputs
- ...

## Notes
- Implementation details
EOF

echo "Created: $STEP_DIR"