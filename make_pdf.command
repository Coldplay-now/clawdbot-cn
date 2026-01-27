#!/bin/bash
# Clawdbot使用指南PDF创建脚本
# 双击此文件运行（需要先安装必要工具）

echo "========================================"
echo "Clawdbot使用指南 PDF 创建工具"
echo "========================================"
echo ""

# 检查当前目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "当前目录: $SCRIPT_DIR"
echo ""

# 检查输入文件
INPUT_FILE="Clawdbot使用指南.md"
if [ ! -f "$INPUT_FILE" ]; then
    echo "错误: 找不到输入文件: $INPUT_FILE"
    echo "请确保此脚本与Markdown文件在同一目录"
    exit 1
fi

echo "找到输入文件: $INPUT_FILE"
echo ""

# 检查工具
echo "检查必要的工具..."
echo ""

# 检查pandoc
if command -v pandoc &> /dev/null; then
    echo "✓ Pandoc 已安装"
    PANDOC_AVAILABLE=true
else
    echo "✗ Pandoc 未安装"
    PANDOC_AVAILABLE=false
fi

# 检查PDF引擎
PDF_ENGINE=""
if command -v wkhtmltopdf &> /dev/null; then
    echo "✓ wkhtmltopdf 已安装"
    PDF_ENGINE="wkhtmltopdf"
elif command -v xelatex &> /dev/null; then
    echo "✓ xelatex 已安装"
    PDF_ENGINE="xelatex"
elif command -v pdflatex &> /dev/null; then
    echo "✓ pdflatex 已安装"
    PDF_ENGINE="pdflatex"
else
    echo "✗ 未找到PDF转换引擎"
    PDF_ENGINE=""
fi

echo ""

# 提供选项
echo "请选择操作:"
echo "1. 尝试创建PDF（如果工具已安装）"
echo "2. 显示安装指南"
echo "3. 创建HTML版本（无需额外工具）"
echo "4. 退出"
echo ""
read -p "请输入选项 (1-4): " choice

case $choice in
    1)
        if [ "$PANDOC_AVAILABLE" = true ] && [ -n "$PDF_ENGINE" ]; then
            echo "正在使用 $PDF_ENGINE 创建PDF..."
            OUTPUT_FILE="$HOME/Desktop/Clawdbot使用指南.pdf"
            pandoc "$INPUT_FILE" -o "$OUTPUT_FILE" --pdf-engine="$PDF_ENGINE"
            
            if [ $? -eq 0 ]; then
                echo ""
                echo "✓ PDF创建成功!"
                echo "文件位置: $OUTPUT_FILE"
                echo "文件大小: $(du -h "$OUTPUT_FILE" | cut -f1)"
                echo ""
                echo "是否要打开PDF文件？(y/n)"
                read -p "选择: " open_choice
                if [[ "$open_choice" =~ ^[Yy]$ ]]; then
                    open "$OUTPUT_FILE"
                fi
            else
                echo ""
                echo "✗ PDF创建失败"
                echo "请尝试其他方法或安装必要的工具"
            fi
        else
            echo ""
            echo "无法创建PDF，缺少必要的工具"
            echo "请先安装必要的工具"
        fi
        ;;
    
    2)
        echo ""
        echo "=== 安装指南 ==="
        echo ""
        echo "推荐安装方法:"
        echo ""
        echo "1. 安装Homebrew（如果尚未安装）:"
        echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        echo ""
        echo "2. 安装Pandoc:"
        echo "   brew install pandoc"
        echo ""
        echo "3. 安装PDF引擎（任选其一）:"
        echo "   a) wkhtmltopdf（推荐）:"
        echo "      brew install wkhtmltopdf"
        echo "   b) MacTeX（较大，但功能全面）:"
        echo "      brew install --cask mactex"
        echo ""
        echo "安装完成后，重新运行此脚本选择选项1"
        ;;
    
    3)
        echo "正在创建HTML版本..."
        OUTPUT_FILE="$HOME/Desktop/Clawdbot使用指南.html"
        pandoc "$INPUT_FILE" -o "$OUTPUT_FILE" --standalone --css=https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/5.1.0/github-markdown.min.css
        
        if [ $? -eq 0 ]; then
            echo ""
            echo "✓ HTML创建成功!"
            echo "文件位置: $OUTPUT_FILE"
            echo ""
            echo "是否要打开HTML文件？(y/n)"
            read -p "选择: " open_choice
            if [[ "$open_choice" =~ ^[Yy]$ ]]; then
                open "$OUTPUT_FILE"
            fi
            echo ""
            echo "提示：在浏览器中打开后，可以使用打印功能(Cmd+P)创建PDF"
        else
            echo ""
            echo "✗ HTML创建失败"
        fi
        ;;
    
    4)
        echo "退出"
        exit 0
        ;;
    
    *)
        echo "无效选项"
        ;;
esac

echo ""
echo "按Enter键退出..."
read