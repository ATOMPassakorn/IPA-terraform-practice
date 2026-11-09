#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)/.terraform-cache"

# รองรับทั้ง Linux และ Windows (Git Bash / Cygwin / MSYS2)
CACHE_DIR_ARG="$CACHE_DIR"
if command -v cygpath >/dev/null 2>&1; then
  CACHE_DIR_ARG="$(cygpath -m "$CACHE_DIR")"
fi

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

if [ "$1" == "--solution" ] || [ "$1" == "-s" ]; then
  TARGET_DIR="$SCRIPT_DIR/solution"
  echo -e "\n${BLUE}ℹ️  โหมด: ตรวจสอบไฟล์เฉลย (solution/)${NC}"
elif [ -d "$SCRIPT_DIR/practice" ] && compgen -G "$SCRIPT_DIR/practice/*.tf" > /dev/null; then
  TARGET_DIR="$SCRIPT_DIR/practice"
  echo -e "\n${GREEN}👉 กำลังตรวจโค้ดที่คุณเขียนใน: ${BOLD}lab03_iteration_dynamic/practice/${NC}"
elif compgen -G "$SCRIPT_DIR/*.tf" > /dev/null; then
  TARGET_DIR="$SCRIPT_DIR"
  echo -e "\n${GREEN}👉 กำลังตรวจโค้ดที่คุณเขียนใน: ${BOLD}lab03_iteration_dynamic/${NC}"
elif compgen -G "$PWD/*.tf" > /dev/null; then
  TARGET_DIR="$PWD"
  echo -e "\n${GREEN}👉 กำลังตรวจโค้ดที่คุณเขียนใน: ${BOLD}$PWD${NC}"
else
  echo -e "\n${RED}❌ ไม่พบไฟล์ .tf ที่คุณเขียน!${NC}"
  echo -e "คุณสามารถเริ่มเขียนโค้ดได้ที่:"
  echo -e "  - ${YELLOW}practice-terraform/lab03_iteration_dynamic/practice/${NC} หรือ"
  echo -e "  - ${YELLOW}practice-terraform/lab03_iteration_dynamic/${NC}"
  echo -e "\n💡 (หากต้องการดูผลตรวจของไฟล์เฉลย ให้ใช้คำสั่ง: ${BLUE}./check.sh --solution${NC})\n"
  exit 1
fi

cd "$TARGET_DIR"

PASSED=0
TOTAL=7

echo -e "${BLUE}===================================================================${NC}"
echo -e "${BLUE}🔍 ตรวจแบบฝึกหัด Lab 03: Iteration (for_each), Dynamic & For Expr${NC}"
echo -e "${BLUE}===================================================================${NC}"

# Check 1: Files
echo -n "1. ตรวจสอบโครงสร้างไฟล์ (variables.tf, main.tf, outputs.tf): "
if [ -f "variables.tf" ] && [ -f "main.tf" ] && [ -f "outputs.tf" ]; then
  echo -e "${GREEN}✓ PASS${NC}"
  ((PASSED++))
else
  echo -e "${RED}✗ FAIL${NC} (ต้องมี variables.tf, main.tf, outputs.tf)"
fi

# Check 2: fmt
echo -n "2. ตรวจสอบการจัดรูปแบบโค้ด (terraform fmt): "
if terraform fmt -check > /dev/null 2>&1; then
  echo -e "${GREEN}✓ PASS${NC}"
  ((PASSED++))
else
  echo -e "${YELLOW}⚠ WARN${NC} (รัน 'terraform fmt' เพื่อจัดระเบียบ)"
fi

# Check 3: init & validate
echo -n "3. ตรวจสอบความถูกต้องของ Syntax (terraform validate): "
if [ -d "$CACHE_DIR" ]; then
  terraform init -input=false -plugin-dir="$CACHE_DIR_ARG" > /dev/null 2>&1 || terraform init -input=false > /dev/null 2>&1
else
  terraform init -input=false > /dev/null 2>&1
fi

if terraform validate > /dev/null 2>&1; then
  echo -e "${GREEN}✓ PASS${NC}"
  ((PASSED++))
else
  echo -e "${RED}✗ FAIL${NC} (Syntax ผิดพลาด รัน 'terraform validate' เพื่อดู error)"
fi

# Check 4: for_each with toset
echo -n "4. ตรวจสอบการใช้ for_each กับ toset(...) ใน aws_subnet: "
if grep -qE 'for_each[[:space:]]*=[[:space:]]*toset\(' main.tf 2>/dev/null; then
  echo -e "${GREEN}✓ PASS${NC}"
  ((PASSED++))
else
  echo -e "${RED}✗ FAIL${NC} (ใน aws_subnet ต้องใช้ for_each = toset(var.subnet_cidrs))"
fi

# Check 5: dynamic block
echo -n "5. ตรวจสอบการสร้าง dynamic \"ingress\" block ใน Security Group: "
if grep -qE 'dynamic[[:space:]]+"ingress"' main.tf 2>/dev/null && grep -qE 'content[[:space:]]*\{' main.tf 2>/dev/null; then
  echo -e "${GREEN}✓ PASS${NC}"
  ((PASSED++))
else
  echo -e "${RED}✗ FAIL${NC} (ต้องมีบล็อก dynamic \"ingress\" พร้อม content { ... } ใน Security Group)"
fi

# Check 6: for_each with Map on EC2
echo -n "6. ตรวจสอบการใช้ for_each กับ Map ใน aws_instance: "
if grep -qE 'resource[[:space:]]+"aws_instance"' main.tf 2>/dev/null && grep -qE 'for_each[[:space:]]*=[[:space:]]*var\.web_servers' main.tf 2>/dev/null; then
  echo -e "${GREEN}✓ PASS${NC}"
  ((PASSED++))
else
  echo -e "${RED}✗ FAIL${NC} (ใน aws_instance ต้องมี for_each = var.web_servers)"
fi

# Check 7: For expressions in outputs
echo -n "7. ตรวจสอบการใช้ for expressions ใน outputs.tf: "
if grep -qE '\[[[:space:]]*for ' outputs.tf 2>/dev/null && grep -qE '\{[[:space:]]*for ' outputs.tf 2>/dev/null; then
  echo -e "${GREEN}✓ PASS${NC}"
  ((PASSED++))
else
  echo -e "${RED}✗ FAIL${NC} (ใน outputs.tf ต้องมีทั้ง [for ... in ... if ...] และ {for ... in ...})"
fi

echo -e "\n-------------------------------------------------------------------"
if [ "$PASSED" -eq "$TOTAL" ]; then
  echo -e "${GREEN}🎉 ยอดเยี่ยม! ผ่านการตรวจสอบทั้งหมด $PASSED/$TOTAL ข้อ${NC}\n"
else
  echo -e "${YELLOW}📊 คะแนน: ผ่าน $PASSED จากทั้งหมด $TOTAL ข้อ (ตรวจแก้ไขตามคำแนะนำด้านบน)${NC}\n"
fi
