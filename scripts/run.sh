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
#   1. $CLIPOCR_BIN env var pointing to a clipocr executable
#   2. $CLIPOCR_PYTHON env var pointing to a Python that has clipocr installed
#   3. `clipocr` on PATH (e.g. `pipx install clipocr` puts it in ~/.local/bin)
#   4. ~/.local/bin/clipocr (pipx default, even if PATH is not refreshed yet)
#   5. <skill-dir>/.venv (skill-local venv)
#   6. system python3 -m clipocr (if pip-installed globally)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"

# Strategy 1-4: find a `clipocr` executable to call directly
find_clipocr_bin() {
    local candidates=(
        "${CLIPOCR_BIN:-}"
        "$(command -v clipocr 2>/dev/null || true)"
        "$HOME/.local/bin/clipocr"
    )
    for bin in "${candidates[@]}"; do
        if [[ -n "$bin" && -x "$bin" ]]; then
            echo "$bin"
            return 0
        fi
    done
    return 1
}

# Strategy 5-6: find a Python that has clipocr importable
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

# Parse args first so we can build the final command line
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

build_args() {
    if [[ "$TEXT_ONLY" -eq 1 ]]; then
        if [[ "$TARGET" == "--clip" ]]; then
            echo "--clip"
        else
            echo "$TARGET"
        fi
    else
        if [[ "$TARGET" == "--clip" ]]; then
            echo "--clip --json"
        else
            echo "$TARGET --json"
        fi
    fi
}

# Try executable first (preferred — works with pipx without env hacks)
if BIN="$(find_clipocr_bin)"; then
    # shellcheck disable=SC2046
    exec "$BIN" $(build_args)
fi

# Fall back to a Python with clipocr importable
if PY="$(find_python)"; then
    # shellcheck disable=SC2046
    exec "$PY" -m clipocr.cli $(build_args)
fi

cat >&2 <<EOF
[clipocr skill] clipocr is not installed.

Install it with one of:
    pipx install clipocr      # recommended for CLI tools
    pip install clipocr       # global install

Or point one of these env vars at an existing install:
    export CLIPOCR_BIN=/path/to/clipocr
    export CLIPOCR_PYTHON=/path/to/venv/bin/python

Then re-run this command.
EOF
exit 127
