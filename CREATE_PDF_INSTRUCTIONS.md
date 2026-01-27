# 如何创建PDF版本

由于您的系统缺少PDF转换工具，以下是几种创建PDF版本的方法：

## 方法1：安装必要的工具（推荐）

### 安装wkhtmltopdf
```bash
brew install wkhtmltopdf
```

### 安装MacTeX（包含pdflatex）
```bash
brew install --cask mactex
```

安装后，运行：
```bash
cd /Users/lxt/Code/clawdbot
pandoc "Clawdbot使用指南.md" -o ~/Desktop/"Clawdbot使用指南.pdf"
```

## 方法2：使用在线转换工具

1. 打开在线Markdown转PDF工具，如：
   - https://www.markdowntopdf.com/
   - https://md2pdf.netlify.app/

2. 复制 `Clawdbot使用指南.md` 的内容到在线工具
3. 下载生成的PDF文件

## 方法3：使用浏览器打印功能

1. 打开HTML版本：
   ```bash
   open ~/Desktop/Clawdbot使用指南.html
   ```

2. 在浏览器中按 `Cmd + P` (Mac) 或 `Ctrl + P` (Windows/Linux)
3. 选择"另存为PDF"或"打印到PDF"
4. 保存到桌面

## 方法4：使用文本编辑器

1. 用文本编辑器打开 `Clawdbot使用指南.md`
2. 复制所有内容
3. 打开Pages、Word或Google Docs
4. 粘贴内容并格式化为适合打印的样式
5. 导出为PDF

## 已创建的文件

在桌面上，您已经有以下文件：

1. **`Clawdbot使用指南.md`** - Markdown源文件（包含Mermaid流程图）
2. **`Clawdbot使用指南.html`** - HTML版本（可直接在浏览器中查看）
3. **`Clawdbot使用指南.txt`** - 纯文本版本

## 文档更新说明

我已为文档添加了三个Mermaid流程图：

### 1. 完整使用流程图
位于"快速开始"部分之后，展示了从安装到日常使用的完整流程。

### 2. 技能创建流程图
位于"技能系统"部分，详细展示了创建自定义技能的步骤。

### 3. 故障排除流程图
位于"故障排除"部分，提供了系统化的问题诊断流程。

这些流程图在Markdown和HTML版本中都能正常显示，但在纯文本版本中会显示为代码块。

## 快速创建PDF的脚本

如果您安装了必要的工具，可以使用以下脚本：

```bash
#!/bin/bash
# 安装所需工具
brew install wkhtmltopdf
brew install pandoc

# 创建PDF
cd /Users/lxt/Code/clawdbot
pandoc "Clawdbot使用指南.md" -o ~/Desktop/"Clawdbot使用指南.pdf" --pdf-engine=wkhtmltopdf
```

或者，如果您想使用浏览器打印功能，这里有一个自动化脚本：

```bash
#!/bin/bash
# 使用浏览器打印创建PDF（需要Chrome）
cd /Users/lxt/Code/clawdbot

# 先创建HTML
pandoc "Clawdbot使用指南.md" -o "temp.html" --standalone

# 使用Chrome打印（如果已安装）
if command -v google-chrome &> /dev/null; then
    google-chrome --headless --disable-gpu --print-to-pdf="~/Desktop/Clawdbot使用指南.pdf" "temp.html"
elif command -v chromium &> /dev/null; then
    chromium --headless --disable-gpu --print-to-pdf="~/Desktop/Clawdbot使用指南.pdf" "temp.html"
fi

# 清理
rm -f temp.html
```

## 手动转换步骤总结

1. **确保有查看工具**：HTML版本可以在任何浏览器中查看
2. **选择转换方法**：根据您的工具选择最方便的方法
3. **验证内容**：确保PDF中包含所有流程图和格式
4. **分享使用**：PDF版本更适合打印和分享

如果您需要进一步帮助创建PDF版本，请告诉我！