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
  echo -e "\n${GREEN}👉 กำลังตรวจโค้ดที่คุณเขียนใน: ${BOLD}lab05_remote_state_management/practice/${NC}"
elif compgen -G "$SCRIPT_DIR/*.tf" > /dev/null; then
  TARGET_DIR="$SCRIPT_DIR"
  echo -e "\n${GREEN}👉 กำลังตรวจโค้ดที่คุณเขียนใน: ${BOLD}lab05_remote_state_management/${NC}"
elif compgen -G "$PWD/*.tf" > /dev/null; then
  TARGET_DIR="$PWD"
  echo -e "\n${GREEN}👉 กำลังตรวจโค้ดที่คุณเขียนใน: ${BOLD}$PWD${NC}"
else
  echo -e "\n${RED}❌ ไม่พบไฟล์ .tf ที่คุณเขียน!${NC}"
  echo -e "คุณสามารถเริ่มเขียนโค้ดได้ที่:"
  echo -e "  - ${YELLOW}practice-terraform/lab05_remote_state_management/practice/${NC} หรือ"
  echo -e "  - ${YELLOW}practice-terraform/lab05_remote_state_management/${NC}"
  echo -e "\n💡 (หากต้องการดูผลตรวจของไฟล์เฉลย ให้ใช้คำสั่ง: ${BLUE}./check.sh --solution${NC})\n"
  exit 1
fi

cd "$TARGET_DIR"

PASSED=0
TOTAL=6

echo -e "${BLUE}================================================================${NC}"
echo -e "${BLUE}🔍 ตรวจแบบฝึกหัด Lab 05: Remote State, Locking & State CLI${NC}"
echo -e "${BLUE}================================================================${NC}"

# Check 1: Files
echo -n "1. ตรวจสอบโครงสร้างไฟล์: "
if [ -f "terraform.tf" ] && [ -f "main.tf" ] && [ -f "outputs.tf" ]; then
  echo -e "${GREEN}✓ PASS${NC}"
  ((PASSED++))
else
  echo -e "${RED}✗ FAIL${NC} (ต้องมี terraform.tf, main.tf, outputs.tf)"
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

# Check 4: Backend S3 syntax check
echo -n "4. ตรวจสอบโครงสร้างคอนฟิก backend \"s3\": "
if grep -qE 'backend[[:space:]]+"s3"' terraform.tf 2>/dev/null; then
  echo -e "${GREEN}✓ PASS${NC}"
  ((PASSED++))
else
  echo -e "${RED}✗ FAIL${NC} (ใน terraform.tf ต้องมีบล็อก backend \"s3\" พร้อม bucket, key, region)"
fi

# Check 5: Remote state or state-only resources
echo -n "5. ตรวจสอบไวยากรณ์ terraform_remote_state / terraform_data: "
if grep -q 'terraform_remote_state' main.tf 2>/dev/null || grep -q 'terraform_data' main.tf 2>/dev/null; then
  echo -e "${GREEN}✓ PASS${NC}"
  ((PASSED++))
else
  echo -e "${RED}✗ FAIL${NC} (ต้องมี data \"terraform_remote_state\" หรือ resource \"terraform_data\")"
fi

# Check 6: State CLI simulation test
echo -n "6. จำลองทดสอบ State CLI (state list, state mv, state rm): "
terraform apply -auto-approve > /dev/null 2>&1
if terraform state list | grep -q 'terraform_data' 2>/dev/null; then
  echo -e "${GREEN}✓ PASS${NC}"
  ((PASSED++))
  # clean up local test state
  terraform destroy -auto-approve > /dev/null 2>&1 || true
  rm -f terraform.tfstate*
else
  echo -e "${RED}✗ FAIL${NC} (ไม่สามารถรันคำสั่ง state CLI ได้)"
fi

echo -e "\n----------------------------------------------------------------"
if [ "$PASSED" -eq "$TOTAL" ]; then
  echo -e "${GREEN}🎉 ยอดเยี่ยม! ผ่านการตรวจสอบทั้งหมด $PASSED/$TOTAL ข้อ${NC}\n"
else
  echo -e "${YELLOW}📊 คะแนน: ผ่าน $PASSED จากทั้งหมด $TOTAL ข้อ (ตรวจแก้ไขตามคำแนะนำด้านบน)${NC}\n"
fi
