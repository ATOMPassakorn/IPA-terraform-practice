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

# ตรวจสอบตำแหน่งโฟลเดอร์ของโค้ด (รองรับทั้งโฟลเดอร์ lab01_hcl_basics/ และโฟลเดอร์ practice/)
if [ "$1" == "--solution" ] || [ "$1" == "-s" ]; then
  TARGET_DIR="$SCRIPT_DIR/solution"
  echo -e "\n${BLUE}ℹ️  โหมด: ตรวจสอบไฟล์เฉลย (solution/)${NC}"
elif [ -d "$SCRIPT_DIR/practice" ] && compgen -G "$SCRIPT_DIR/practice/*.tf" > /dev/null; then
  TARGET_DIR="$SCRIPT_DIR/practice"
  echo -e "\n${GREEN}👉 กำลังตรวจโค้ดที่คุณเขียนใน: ${BOLD}lab01_hcl_basics/practice/${NC}"
elif compgen -G "$SCRIPT_DIR/*.tf" > /dev/null; then
  TARGET_DIR="$SCRIPT_DIR"
  echo -e "\n${GREEN}👉 กำลังตรวจโค้ดที่คุณเขียนใน: ${BOLD}lab01_hcl_basics/${NC}"
elif compgen -G "$PWD/*.tf" > /dev/null; then
  TARGET_DIR="$PWD"
  echo -e "\n${GREEN}👉 กำลังตรวจโค้ดที่คุณเขียนใน: ${BOLD}$PWD${NC}"
else
  echo -e "\n${RED}❌ ไม่พบไฟล์ .tf ที่คุณเขียน!${NC}"
  echo -e "คุณสามารถเริ่มเขียนโค้ดได้ที่:"
  echo -e "  - ${YELLOW}practice-terraform/lab01_hcl_basics/practice/${NC} หรือ"
  echo -e "  - ${YELLOW}practice-terraform/lab01_hcl_basics/${NC}"
  echo -e "\n💡 (หากต้องการดูผลตรวจของไฟล์เฉลย ให้ใช้คำสั่ง: ${BLUE}./check.sh --solution${NC})\n"
  exit 1
fi

cd "$TARGET_DIR"

PASSED=0
TOTAL=6

echo -e "${BLUE}==============================================${NC}"
echo -e "${BLUE}🔍 ตรวจแบบฝึกหัด Lab 01: HCL Components & EC2${NC}"
echo -e "${BLUE}==============================================${NC}"

# Check 1: Files
echo -n "1. ตรวจสอบโครงสร้างไฟล์ (terraform.tf, provider.tf, main.tf): "
if [ -f "terraform.tf" ] && [ -f "provider.tf" ] && [ -f "main.tf" ]; then
  echo -e "${GREEN}✓ PASS${NC}"
  ((PASSED++))
else
  echo -e "${RED}✗ FAIL${NC} (ขาดไฟล์สำคัญ ควรมี terraform.tf, provider.tf, main.tf)"
fi

# Check 2: fmt
echo -n "2. ตรวจสอบการจัดรูปแบบโค้ด (terraform fmt): "
if terraform fmt -check > /dev/null 2>&1; then
  echo -e "${GREEN}✓ PASS${NC}"
  ((PASSED++))
else
  echo -e "${YELLOW}⚠ WARN${NC} (รัน 'terraform fmt' เพื่อจัดระเบียบช่องว่างและการย่อหน้า)"
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

# Check 4: Data Source AMI
echo -n "4. ตรวจสอบ Data Source 'aws_ami': "
if grep -qE 'data[[:space:]]+"aws_ami"' *.tf && grep -q '099720109477' *.tf; then
  echo -e "${GREEN}✓ PASS${NC}"
  ((PASSED++))
else
  echo -e "${RED}✗ FAIL${NC} (ไม่พบ data \"aws_ami\" หรือ owners = [\"099720109477\"])"
fi

# Check 5: Resource EC2
echo -n "5. ตรวจสอบ Resource 'aws_instance': "
if grep -qE 'resource[[:space:]]+"aws_instance"' *.tf; then
  echo -e "${GREEN}✓ PASS${NC}"
  ((PASSED++))
else
  echo -e "${RED}✗ FAIL${NC} (ไม่พบ resource \"aws_instance\")"
fi

# Check 6: Lifecycle block
echo -n "6. ตรวจสอบบล็อก lifecycle (prevent_destroy / ignore_changes): "
if grep -qE 'lifecycle[[:space:]]*\{' *.tf && (grep -q 'prevent_destroy' *.tf || grep -q 'ignore_changes' *.tf); then
  echo -e "${GREEN}✓ PASS${NC}"
  ((PASSED++))
else
  echo -e "${RED}✗ FAIL${NC} (ไม่พบบล็อก lifecycle พร้อม prevent_destroy หรือ ignore_changes)"
fi

echo -e "\n----------------------------------------------"
if [ "$PASSED" -eq "$TOTAL" ]; then
  echo -e "${GREEN}🎉 ยอดเยี่ยม! ผ่านการตรวจสอบทั้งหมด $PASSED/$TOTAL ข้อ${NC}\n"
else
  echo -e "${YELLOW}📊 คะแนน: ผ่าน $PASSED จากทั้งหมด $TOTAL ข้อ (ตรวจแก้ไขตามคำแนะนำด้านบน)${NC}\n"
fi
