#!/usr/bin/env python3
"""
将HTML文件转换为PDF的简单脚本
需要安装：pip install weasyprint
"""

import sys
import os
from pathlib import Path

def check_dependencies():
    """检查必要的依赖"""
    try:
        from weasyprint import HTML
        return True
    except ImportError:
        print("错误: 需要安装 weasyprint")
        print("请运行: pip install weasyprint")
        return False

def convert_html_to_pdf(html_path, pdf_path):
    """将HTML文件转换为PDF"""
    try:
        from weasyprint import HTML
        
        print(f"正在转换: {html_path} -> {pdf_path}")
        
        # 读取HTML内容
        with open(html_path, 'r', encoding='utf-8') as f:
            html_content = f.read()
        
        # 转换为PDF
        HTML(string=html_content).write_pdf(pdf_path)
        
        print(f"✓ PDF创建成功: {pdf_path}")
        print(f"文件大小: {os.path.getsize(pdf_path) / 1024:.1f} KB")
        
        return True
        
    except Exception as e:
        print(f"✗ 转换失败: {e}")
        return False

def main():
    if len(sys.argv) != 3:
        print("用法: python html_to_pdf.py <输入.html> <输出.pdf>")
        sys.exit(1)
    
    html_file = sys.argv[1]
    pdf_file = sys.argv[2]
    
    # 检查输入文件
    if not os.path.exists(html_file):
        print(f"错误: 输入文件不存在: {html_file}")
        sys.exit(1)
    
    # 检查依赖
    if not check_dependencies():
        sys.exit(1)
    
    # 转换文件
    if convert_html_to_pdf(html_file, pdf_file):
        sys.exit(0)
    else:
        sys.exit(1)

if __name__ == "__main__":
    main()