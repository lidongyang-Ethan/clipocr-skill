#!/usr/bin/env bash
# clipocr OpenClaw skill runner
#
# Usage:
#   run.sh <image-path>            # OCR a file, output JSON
#   run.sh --clip                  # OCR clipboard, output JSON
#   run.sh <image-path> --text-only # OCR a file, output plain text
#   run.sh --clip --text-only       # OCR clipboard, output plain text
#
# Resolves clipocr in this order:
#   1. Local dev install at ~/codeLife/clipocr/.venv (preferred during development)
#   2. ~/.openclaw/plugin-skills/clipocr/.venv (skill-local venv)
#   3. System python (whatever `python3 -m clipocr` resolves to)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"

# Pick the first python with clipocr available
find_python() {
    local candidates=(
        "$HOME/codeLife/clipocr/.venv/bin/python"
        "$SKILL_DIR/.venv/bin/python"
        "$(command -v python3 || true)"
    )
    for py in "${candidates[@]}"; do
        if [[ -x "$py" ]] && "$py" -c "import clipocr" >/dev/null 2>&1; then
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

Install it with:
    pip install clipocr

Or, for local development:
    pip install -e ~/codeLife/clipocr

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
