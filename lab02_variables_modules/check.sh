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
  echo -e "\n${GREEN}👉 กำลังตรวจโค้ดที่คุณเขียนใน: ${BOLD}lab02_variables_modules/practice/${NC}"
elif compgen -G "$SCRIPT_DIR/*.tf" > /dev/null; then
  TARGET_DIR="$SCRIPT_DIR"
  echo -e "\n${GREEN}👉 กำลังตรวจโค้ดที่คุณเขียนใน: ${BOLD}lab02_variables_modules/${NC}"
elif compgen -G "$PWD/*.tf" > /dev/null; then
  TARGET_DIR="$PWD"
  echo -e "\n${GREEN}👉 กำลังตรวจโค้ดที่คุณเขียนใน: ${BOLD}$PWD${NC}"
else
  echo -e "\n${RED}❌ ไม่พบไฟล์ .tf ที่คุณเขียน!${NC}"
  echo -e "คุณสามารถเริ่มเขียนโค้ดได้ที่:"
  echo -e "  - ${YELLOW}practice-terraform/lab02_variables_modules/practice/${NC} หรือ"
  echo -e "  - ${YELLOW}practice-terraform/lab02_variables_modules/${NC}"
  echo -e "\n💡 (หากต้องการดูผลตรวจของไฟล์เฉลย ให้ใช้คำสั่ง: ${BLUE}./check.sh --solution${NC})\n"
  exit 1
fi

cd "$TARGET_DIR"

PASSED=0
TOTAL=8

echo -e "${BLUE}======================================================${NC}"
echo -e "${BLUE}🔍 ตรวจแบบฝึกหัด Lab 02: Variables, Validation & Module${NC}"
echo -e "${BLUE}======================================================${NC}"

# Check 1: Files
echo -n "1. ตรวจสอบโครงสร้างไฟล์ Root และ Child Module: "
if [ -f "variables.tf" ] && [ -f "locals.tf" ] && [ -f "main.tf" ] && [ -f "outputs.tf" ] && [ -d "modules/web_app" ]; then
  echo -e "${GREEN}✓ PASS${NC}"
  ((PASSED++))
else
  echo -e "${RED}✗ FAIL${NC} (ต้องมี variables.tf, locals.tf, main.tf, outputs.tf และโฟลเดอร์ modules/web_app)"
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
echo -n "3. ตรวจสอบความถูกต้องของ Syntax และ Module (terraform validate): "
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

# Check 4: Variable validation on environment
echo -n "4. ตรวจสอบ Input Validation ในตัวแปร 'environment': "
if grep -qE 'validation[[:space:]]*\{' variables.tf 2>/dev/null && grep -qE 'contains[[:space:]]*\(' variables.tf 2>/dev/null; then
  echo -e "${GREEN}✓ PASS${NC}"
  ((PASSED++))
else
  echo -e "${RED}✗ FAIL${NC} (ใน variables.tf ต้องมีบล็อก validation พร้อมฟังก์ชัน contains)"
fi

# Check 5: Sensitive variable
echo -n "5. ตรวจสอบ Sensitive variable สำหรับรหัสผ่าน: "
if grep -qE 'sensitive[[:space:]]*=[[:space:]]*true' variables.tf 2>/dev/null; then
  echo -e "${GREEN}✓ PASS${NC}"
  ((PASSED++))
else
  echo -e "${RED}✗ FAIL${NC} (ไม่พบตัวแปรที่ตั้งค่า sensitive = true ใน variables.tf)"
fi

# Check 6: Child module object validation
echo -n "6. ตรวจสอบ Object Type & Validation ใน Child Module (modules/web_app): "
if [ -f "modules/web_app/variables.tf" ] && grep -qE 'object[[:space:]]*\(' modules/web_app/variables.tf && grep -qE 'validation[[:space:]]*\{' modules/web_app/variables.tf; then
  echo -e "${GREEN}✓ PASS${NC}"
  ((PASSED++))
else
  echo -e "${RED}✗ FAIL${NC} (ใน modules/web_app/variables.tf ต้องมี object({...}) และ validation บล็อก)"
fi

# Check 7: Locals ternary
echo -n "7. ตรวจสอบการใช้ Ternary Expression ใน locals.tf: "
if grep -q '?' locals.tf 2>/dev/null && grep -q ':' locals.tf 2>/dev/null; then
  echo -e "${GREEN}✓ PASS${NC}"
  ((PASSED++))
else
  echo -e "${RED}✗ FAIL${NC} (ไม่พบนิพจน์เงื่อนไขแบบ Ternary <cond> ? <true> : <false> ใน locals.tf)"
fi

# Check 8: Module call & outputs
echo -n "8. ตรวจสอบการเรียกใช้ Module และการดึง Output: "
if grep -qE 'module[[:space:]]+"web"' main.tf 2>/dev/null && grep -qE 'module\.web\.' outputs.tf 2>/dev/null; then
  echo -e "${GREEN}✓ PASS${NC}"
  ((PASSED++))
else
  echo -e "${RED}✗ FAIL${NC} (main.tf ต้องเรียก module \"web\" และ outputs.tf ต้องอ้างอิง module.web.<output>)"
fi

echo -e "\n------------------------------------------------------"
if [ "$PASSED" -eq "$TOTAL" ]; then
  echo -e "${GREEN}🎉 ยอดเยี่ยม! ผ่านการตรวจสอบทั้งหมด $PASSED/$TOTAL ข้อ${NC}\n"
else
  echo -e "${YELLOW}📊 คะแนน: ผ่าน $PASSED จากทั้งหมด $TOTAL ข้อ (ตรวจแก้ไขตามคำแนะนำด้านบน)${NC}\n"
fi
