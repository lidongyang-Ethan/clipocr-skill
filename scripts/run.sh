#!/usr/bin/env bash
# clipocr OpenClaw skill runner
#
# Usage:
#   run.sh <image-path>             # OCR a file, output JSON
#   run.sh --clip                   # OCR clipboard, output JSON
#   run.sh <image-path> --text-only # OCR a file, output plain text
#   run.sh --clip --text-only       # OCR clipboard, output plain text
#
# Resolves clipocr in this order:
#   1. $CLIPOCR_PYTHON env var (override for dev or custom envs)
#   2. <skill-dir>/.venv (skill-local venv)
#   3. system python3 (whatever `python3 -m clipocr` resolves to)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"

find_python() {
    local candidates=(
        "${CLIPOCR_PYTHON:-}"
        "$SKILL_DIR/.venv/bin/python"
        "$(command -v python3 || true)"
    )
    for py in "${candidates[@]}"; do
        if [[ -n "$py" && -x "$py" ]] && "$py" -c "import clipocr" >/dev/null 2>&1; then
            echo "$py"
            return 0
        fi
    done
    return 1
}

PY="$(find_python || true)"
if [[ -z "$PY" ]]; then
    cat >&2 <<EOF
[clipocr skill] clipocr is not installed in any known Python environment.

Install it with one of:
    pipx install clipocr      # recommended for CLI tools
    pip install clipocr       # global install

Or point CLIPOCR_PYTHON at a Python that has clipocr available:
    export CLIPOCR_PYTHON=/path/to/venv/bin/python

Then re-run this command.
EOF
    exit 127
fi

# Parse args: accept either ordering of <path|--clip> and --text-only
TEXT_ONLY=0
TARGET=""

for arg in "$@"; do
    case "$arg" in
        --text-only) TEXT_ONLY=1 ;;
        *) TARGET="$arg" ;;
    esac
done

if [[ -z "$TARGET" ]]; then
    echo "[clipocr skill] usage: run.sh <image-path|--clip> [--text-only]" >&2
    exit 64
fi

if [[ "$TEXT_ONLY" -eq 1 ]]; then
    if [[ "$TARGET" == "--clip" ]]; then
        exec "$PY" -m clipocr.cli --clip
    else
        exec "$PY" -m clipocr.cli "$TARGET"
    fi
else
    if [[ "$TARGET" == "--clip" ]]; then
        exec "$PY" -m clipocr.cli --clip --json
    else
        exec "$PY" -m clipocr.cli "$TARGET" --json
    fi
fi
