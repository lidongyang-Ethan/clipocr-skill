# clipocr-skill

> [OpenClaw](https://github.com/openclaw/openclaw) skill that wraps the [`clipocr`](https://github.com/lidongyang-Ethan/clipocr) Python package: turn screenshots / clipboard images into text + bounding boxes, fully on-device.

[中文说明](#中文说明)

## What it does

When you say things like:

- *"识别这张图里的字"*
- *"OCR 一下我刚截的图"*
- *"把这段报错截图转成文本"*

…OpenClaw triggers this skill, which calls the `clipocr` Python package and returns recognized text (with optional bounding boxes / confidence). No image ever leaves your machine.

## Prerequisites

1. [OpenClaw](https://github.com/openclaw/openclaw) installed
2. The `clipocr` Python package available on `PATH`:
   ```bash
   pipx install clipocr   # recommended for CLI tools
   # or
   pip install clipocr
   ```

The `scripts/run.sh` runner auto-discovers `clipocr` in this order:

1. `$CLIPOCR_PYTHON` env var (override for custom envs)
2. `<skill-dir>/.venv/bin/python` (skill-local venv)
3. system `python3` (if `clipocr` is installed globally)

## Install

Drop this skill into your OpenClaw plugin-skills directory:

```bash
git clone https://github.com/lidongyang-Ethan/clipocr-skill.git \
  ~/.openclaw/plugin-skills/clipocr
```

Restart OpenClaw (or reload skills) and the agent will see `clipocr` in its available skills.

## Usage

Just talk to your OpenClaw agent. Natural language triggers are documented in [`SKILL.md`](SKILL.md). Example:

> 识别一下 `~/Desktop/screenshot.png`

The agent picks the right mode and calls `scripts/run.sh` for you.

You can also call the runner directly:

```bash
# JSON (text + bbox + confidence)
~/.openclaw/plugin-skills/clipocr/scripts/run.sh /path/to/image.png

# Plain text only
~/.openclaw/plugin-skills/clipocr/scripts/run.sh /path/to/image.png --text-only

# Read clipboard
~/.openclaw/plugin-skills/clipocr/scripts/run.sh --clip
~/.openclaw/plugin-skills/clipocr/scripts/run.sh --clip --text-only
```

## Limitations

- Default RapidOCR PP-OCRv4 mobile models — handwriting recognition is unreliable.
- Tables: bbox is correct but reading order may be off for complex layouts.
- Math / chemical formulas: not supported (use a dedicated LaTeX OCR).
- First run downloads ~15 MB of ONNX models (one-time, then cached).

## Related

- 📦 [clipocr on PyPI](https://pypi.org/project/clipocr/) — the underlying Python package
- 🐙 [clipocr on GitHub](https://github.com/lidongyang-Ethan/clipocr) — source for the package
- 🦞 [OpenClaw](https://github.com/openclaw/openclaw) — the agent platform this skill plugs into

## License

MIT — see [LICENSE](LICENSE).

---

## 中文说明

把截图 / 剪贴板里的图变成文本（含 bbox 坐标）的 OpenClaw skill。基于 [`clipocr`](https://github.com/lidongyang-Ethan/clipocr) Python 包，**纯本地推理，图片不上传**。

### 触发条件

跟 OpenClaw agent 说类似的话就行：

- "识别这张图里的字"
- "OCR 一下我刚截的图"
- "把这段报错截图转成文本"
- "看下这张代码截图说啥"

### 安装

先装底层 Python 包：

```bash
pipx install clipocr
# 或
pip install clipocr
```

再 clone 这个 skill 到 OpenClaw 的插件目录：

```bash
git clone https://github.com/lidongyang-Ethan/clipocr-skill.git \
  ~/.openclaw/plugin-skills/clipocr
```

重启 OpenClaw（或重新加载 skill），agent 就能识别这个技能了。

### 直接调脚本

不通过 agent，也可以手动跑：

```bash
~/.openclaw/plugin-skills/clipocr/scripts/run.sh /path/to/image.png
~/.openclaw/plugin-skills/clipocr/scripts/run.sh --clip --text-only
```

### 限制

- 用的是 PP-OCRv4 mobile 模型——**手写体不靠谱**
- 复杂表格 / 多栏版面：bbox 对，但顺序可能错
- 公式 / 化学式：不支持，去找专门的 LaTeX OCR
- 首次运行需联网下 15 MB 模型（一次性）

### 相关链接

- 📦 [PyPI 包：clipocr](https://pypi.org/project/clipocr/)
- 🐙 [GitHub 源码：clipocr](https://github.com/lidongyang-Ethan/clipocr)
- 🦞 [OpenClaw](https://github.com/openclaw/openclaw)
