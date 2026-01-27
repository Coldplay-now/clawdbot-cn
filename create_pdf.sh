#!/bin/bash
# 创建PDF版本的脚本

INPUT_FILE="Clawdbot使用指南.md"
OUTPUT_PDF="Clawdbot使用指南.pdf"
DESKTOP_PATH="$HOME/Desktop"

echo "正在创建PDF版本..."

# 方法1: 尝试使用pandoc + wkhtmltopdf（如果可用）
if command -v wkhtmltopdf &> /dev/null; then
    echo "使用wkhtmltopdf创建PDF..."
    pandoc "$INPUT_FILE" -o "$DESKTOP_PATH/$OUTPUT_PDF" --pdf-engine=wkhtmltopdf
    if [ $? -eq 0 ]; then
        echo "✓ PDF创建成功: $DESKTOP_PATH/$OUTPUT_PDF"
        exit 0
    fi
fi

# 方法2: 创建HTML然后使用浏览器打印
echo "创建HTML版本..."
pandoc "$INPUT_FILE" -o "$DESKTOP_PATH/Clawdbot使用指南_temp.html" --standalone

# 方法3: 使用textutil（macOS）
echo "尝试使用textutil..."
textutil -convert rtf "$INPUT_FILE" -output "$DESKTOP_PATH/Clawdbot使用指南.rtf"
if [ -f "$DESKTOP_PATH/Clawdbot使用指南.rtf" ]; then
    textutil -convert pdf "$DESKTOP_PATH/Clawdbot使用指南.rtf" -output "$DESKTOP_PATH/$OUTPUT_PDF"
    rm "$DESKTOP_PATH/Clawdbot使用指南.rtf"
    
    if [ -f "$DESKTOP_PATH/$OUTPUT_PDF" ]; then
        echo "✓ PDF创建成功: $DESKTOP_PATH/$OUTPUT_PDF"
        exit 0
    fi
fi

# 方法4: 创建纯文本版本
echo "创建纯文本版本..."
pandoc "$INPUT_FILE" -o "$DESKTOP_PATH/Clawdbot使用指南.txt" -t plain
echo "由于缺少PDF转换工具，已创建文本版本: $DESKTOP_PATH/Clawdbot使用指南.txt"
echo "建议安装: brew install --cask mactex 或 brew install wkhtmltopdf"

exit 1