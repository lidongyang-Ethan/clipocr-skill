---
name: clipocr
description: 用户希望从截图/图片中提取文字时调用。例如"识别这张图里的字"、"OCR 一下"、"看下我截的图说什么"、"把这段代码截图转成文本"、"识别报错截图"等。支持中英文混排，返回文本和坐标框（bbox）。
metadata:
  openclaw:
    emoji: "📷"
    requires: { bins: [] }
---

# clipocr

本地 OCR：把截图 / 剪贴板里的图变成文本（含 bbox 坐标）。
基于 [clipocr](https://github.com/lidongyangLeo/clipocr) Python 包，纯本地推理，不上传任何图。

## 何时触发

✅ 用户给了图片路径 **并且** 想读图里的字
✅ 用户说"OCR 一下"、"识别这张图"、"把图里的字抓出来"
✅ 用户截了图（剪贴板里有图）后说"看下我刚截的图"

❌ 用户只发图片但没说要 OCR → 走默认的 image 工具看图就行
❌ 复杂版面 / 表格还原 / 公式 OCR → 这个 skill 不擅长，建议改用专业服务

## 准备（仅首次）

skill 自动检查 clipocr 是否已装，没装就提示用户：

```bash
pip install clipocr
```

或者用项目自带的 venv：`pip install -e ~/codeLife/clipocr`。

## 用法

### A. 文件路径模式

```bash
~/.openclaw/plugin-skills/clipocr/scripts/run.sh /path/to/image.png
```

输出 JSON：

```json
{
  "text": "识别到的全文，按阅读顺序换行",
  "blocks": [
    {"text": "立即购买", "bbox": [1500, 200, 1700, 240], "confidence": 0.96}
  ],
  "confidence": 0.94,
  "engine": "rapidocr",
  "image_size": [1920, 1080]
}
```

### B. 剪贴板模式

```bash
~/.openclaw/plugin-skills/clipocr/scripts/run.sh --clip
```

直接从系统剪贴板读图。

### C. 仅返回纯文本（不需要坐标）

加 `--text-only`：

```bash
~/.openclaw/plugin-skills/clipocr/scripts/run.sh /path/to/image.png --text-only
```

输出纯文本，不是 JSON，更简洁。

## 流程

1. **判断来源**：用户给了路径 → A 模式；说"刚截的图" → B 模式
2. **跑 OCR**：调 `scripts/run.sh`
3. **理解内容**：
   - 报错截图 → 把 stack trace 当输入分析
   - 代码截图 → 当代码处理（语言识别、补全、修 bug）
   - UI 截图 → 用 bbox 定位用户说的元素
4. **回复**：根据用户原始意图给答案，**不要直接把 OCR 输出 dump 给用户**——要在 OCR 之上回答用户真正想问的事

## 输出建议

不要这样：
> 我识别到了：xxxxx（一大堆文字）

要这样（举例：用户截图问报错怎么办）：
> 这是 `TypeError: cannot read property 'x' of undefined`，第 23 行。
> 通常是 `obj` 没 ready 就访问了，建议加个判空。具体改法：...

## 限制

- 模型是 PP-OCRv4 mobile 版，**手写体识别不靠谱**
- **表格** / 复杂版面：bbox 准但顺序可能错
- **公式 / 化学式**：放弃，去找专门的 LaTeX OCR
- 首次跑要下载 ~15 MB 模型（联网，一次性）

## Related

- [GitHub 仓库](https://github.com/lidongyangLeo/clipocr)
- [PyPI](https://pypi.org/project/clipocr/)
