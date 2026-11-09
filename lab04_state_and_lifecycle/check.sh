#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)/.terraform-cache"

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
  echo -e "\n${GREEN}👉 กำลังตรวจโค้ดที่คุณเขียนใน: ${BOLD}lab04_state_and_lifecycle/practice/${NC}"
elif compgen -G "$SCRIPT_DIR/*.tf" > /dev/null; then
  TARGET_DIR="$SCRIPT_DIR"
  echo -e "\n${GREEN}👉 กำลังตรวจโค้ดที่คุณเขียนใน: ${BOLD}lab04_state_and_lifecycle/${NC}"
elif compgen -G "$PWD/*.tf" > /dev/null; then
  TARGET_DIR="$PWD"
  echo -e "\n${GREEN}👉 กำลังตรวจโค้ดที่คุณเขียนใน: ${BOLD}$PWD${NC}"
else
  echo -e "\n${RED}❌ ไม่พบไฟล์ .tf ที่คุณเขียน!${NC}"
  echo -e "คุณสามารถเริ่มเขียนโค้ดได้ที่:"
  echo -e "  - ${YELLOW}practice-terraform/lab04_state_and_lifecycle/practice/${NC} หรือ"
  echo -e "  - ${YELLOW}practice-terraform/lab04_state_and_lifecycle/${NC}"
  echo -e "\n💡 (หากต้องการดูผลตรวจของไฟล์เฉลย ให้ใช้คำสั่ง: ${BLUE}./check.sh --solution${NC})\n"
  exit 1
fi

cd "$TARGET_DIR"

PASSED=0
TOTAL=8

echo -e "${BLUE}================================================================${NC}"
echo -e "${BLUE}🔍 ตรวจแบบฝึกหัด Lab 04: Plan/Apply Lifecycle, State & Precedence${NC}"
echo -e "${BLUE}================================================================${NC}"

# Check 1: Files
echo -n "1. ตรวจสอบโครงสร้างไฟล์: "
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
terraform init -input=false > /dev/null 2>&1
if terraform validate > /dev/null 2>&1; then
  echo -e "${GREEN}✓ PASS${NC}"
  ((PASSED++))
else
  echo -e "${RED}✗ FAIL${NC} (Syntax ผิดพลาด รัน 'terraform validate' เพื่อดู error)"
fi

# Check 4: depends_on
echo -n "4. ตรวจสอบการใช้งาน 'depends_on' ระบุ Dependency: "
if grep -qE 'depends_on[[:space:]]*=' main.tf 2>/dev/null; then
  echo -e "${GREEN}✓ PASS${NC}"
  ((PASSED++))
else
  echo -e "${RED}✗ FAIL${NC} (ควรมีบล็อก depends_on เพื่อบังคับลำดับการสร้าง resource)"
fi

# Check 5: plan -out
echo -n "5. ทดสอบบันทึก Plan File (terraform plan -out=test.tfplan): "
if terraform plan -input=false -out=test.tfplan > /dev/null 2>&1; then
  echo -e "${GREEN}✓ PASS${NC}"
  ((PASSED++))
  rm -f test.tfplan
else
  echo -e "${RED}✗ FAIL${NC} (ไม่สามารถรัน terraform plan -out ได้)"
fi

# Check 6: plan -target
echo -n "6. ทดสอบคำสั่ง Targeting (terraform plan -target=...): "
if terraform plan -input=false -target=terraform_data.network > /dev/null 2>&1; then
  echo -e "${GREEN}✓ PASS${NC}"
  ((PASSED++))
else
  echo -e "${RED}✗ FAIL${NC} (คำสั่ง terraform plan -target ล้มเหลว)"
fi

# Check 7: plan -replace
echo -n "7. ทดสอบคำสั่ง Replace ทรัพยากร (terraform plan -replace=...): "
if terraform plan -input=false -replace=terraform_data.subnet > /dev/null 2>&1; then
  echo -e "${GREEN}✓ PASS${NC}"
  ((PASSED++))
else
  echo -e "${RED}✗ FAIL${NC} (คำสั่ง terraform plan -replace ล้มเหลว)"
fi

# Check 8: CLI -var override
echo -n "8. ทดสอบ Variable Precedence ด้วย flag -var: "
if terraform plan -input=false -var="instance_name=test-override" > /dev/null 2>&1; then
  echo -e "${GREEN}✓ PASS${NC}"
  ((PASSED++))
else
  echo -e "${RED}✗ FAIL${NC} (ไม่สามารถส่ง -var ได้)"
fi

echo -e "\n----------------------------------------------------------------"
if [ "$PASSED" -eq "$TOTAL" ]; then
  echo -e "${GREEN}🎉 ยอดเยี่ยม! ผ่านการตรวจสอบทั้งหมด $PASSED/$TOTAL ข้อ${NC}\n"
else
  echo -e "${YELLOW}📊 คะแนน: ผ่าน $PASSED จากทั้งหมด $TOTAL ข้อ (ตรวจแก้ไขตามคำแนะนำด้านบน)${NC}\n"
fi
