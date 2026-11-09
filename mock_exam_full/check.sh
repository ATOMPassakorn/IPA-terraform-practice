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
  echo -e "\n${GREEN}👉 กำลังตรวจโค้ดที่คุณเขียนใน: ${BOLD}mock_exam_full/practice/${NC}"
elif compgen -G "$SCRIPT_DIR/*.tf" > /dev/null; then
  TARGET_DIR="$SCRIPT_DIR"
  echo -e "\n${GREEN}👉 กำลังตรวจโค้ดที่คุณเขียนใน: ${BOLD}mock_exam_full/${NC}"
elif compgen -G "$PWD/*.tf" > /dev/null; then
  TARGET_DIR="$PWD"
  echo -e "\n${GREEN}👉 กำลังตรวจโค้ดที่คุณเขียนใน: ${BOLD}$PWD${NC}"
else
  echo -e "\n${RED}❌ ไม่พบไฟล์ .tf ที่คุณเขียน!${NC}"
  echo -e "คุณสามารถเริ่มเขียนโค้ดได้ที่:"
  echo -e "  - ${YELLOW}practice-terraform/mock_exam_full/practice/${NC} หรือ"
  echo -e "  - ${YELLOW}practice-terraform/mock_exam_full/${NC}"
  echo -e "\n💡 (หากต้องการดูผลตรวจของไฟล์เฉลย ให้ใช้คำสั่ง: ${BLUE}./check.sh --solution${NC})\n"
  exit 1
fi

cd "$TARGET_DIR"

SCORE=0

echo -e "${BLUE}================================================================${NC}"
echo -e "${BLUE}🎯 ตรวจและคำนวณคะแนน Mock Exam (คะแนนเต็ม 100)${NC}"
echo -e "${BLUE}================================================================${NC}"

# Section 1: Child Module (25 pts)
echo -e "\n${BOLD}[ส่วนที่ 1: Child Module (25 คะแนน)]${NC}"
if [ -d "modules/service_cluster" ] && [ -f "modules/service_cluster/variables.tf" ]; then
  echo -e "  - โครงสร้างไฟล์ Module: ${GREEN}+5 คะแนน${NC}"
  ((SCORE+=5))
else
  echo -e "  - โครงสร้างไฟล์ Module: ${RED}0 คะแนน (ไม่พบ modules/service_cluster/variables.tf)${NC}"
fi

if grep -qE 'alltrue[[:space:]]*\(' modules/service_cluster/variables.tf 2>/dev/null && grep -qE 'validation[[:space:]]*\{' modules/service_cluster/variables.tf 2>/dev/null; then
  echo -e "  - Input Validation ด้วย alltrue(): ${GREEN}+5 คะแนน${NC}"
  ((SCORE+=5))
else
  echo -e "  - Input Validation ด้วย alltrue(): ${RED}0 คะแนน (ขาด validation block หรือ alltrue)${NC}"
fi

if grep -qE 'resource[[:space:]]+"aws_instance"' modules/service_cluster/main.tf 2>/dev/null && grep -qE 'for_each[[:space:]]*=[[:space:]]*var\.node_specs' modules/service_cluster/main.tf 2>/dev/null; then
  echo -e "  - EC2 instance with for_each = var.node_specs: ${GREEN}+5 คะแนน${NC}"
  ((SCORE+=5))
else
  echo -e "  - EC2 instance with for_each = var.node_specs: ${RED}0 คะแนน${NC}"
fi

if grep -qE 'create_before_destroy[[:space:]]*=[[:space:]]*true' modules/service_cluster/main.tf 2>/dev/null; then
  echo -e "  - Lifecycle create_before_destroy = true: ${GREEN}+5 คะแนน${NC}"
  ((SCORE+=5))
else
  echo -e "  - Lifecycle create_before_destroy = true: ${RED}0 คะแนน${NC}"
fi

if grep -qE '\{[[:space:]]*for' modules/service_cluster/outputs.tf 2>/dev/null; then
  echo -e "  - Module Outputs (Map comprehension): ${GREEN}+5 คะแนน${NC}"
  ((SCORE+=5))
else
  echo -e "  - Module Outputs (Map comprehension): ${RED}0 คะแนน${NC}"
fi

# Section 2: Root & Variables (20 pts)
echo -e "\n${BOLD}[ส่วนที่ 2: Root Configuration & Variables (20 คะแนน)]${NC}"
if [ -f "terraform.tf" ] && [ -f "provider.tf" ]; then
  echo -e "  - Settings & Provider setup: ${GREEN}+5 คะแนน${NC}"
  ((SCORE+=5))
else
  echo -e "  - Settings & Provider setup: ${RED}0 คะแนน${NC}"
fi

if grep -qE 'validation[[:space:]]*\{' variables.tf 2>/dev/null && grep -qE 'contains[[:space:]]*\(' variables.tf 2>/dev/null; then
  echo -e "  - Environment validation block: ${GREEN}+5 คะแนน${NC}"
  ((SCORE+=5))
else
  echo -e "  - Environment validation block: ${RED}0 คะแนน${NC}"
fi

if grep -q 'admin_api_token' variables.tf 2>/dev/null && grep -qE 'sensitive[[:space:]]*=[[:space:]]*true' variables.tf 2>/dev/null; then
  echo -e "  - Sensitive variable (admin_api_token): ${GREEN}+5 คะแนน${NC}"
  ((SCORE+=5))
else
  echo -e "  - Sensitive variable (admin_api_token): ${RED}0 คะแนน${NC}"
fi

if grep -q 'ingress_ports' variables.tf 2>/dev/null && grep -qE 'list[[:space:]]*\([[:space:]]*object[[:space:]]*\(' variables.tf 2>/dev/null; then
  echo -e "  - Ingress ports complex object list: ${GREEN}+5 คะแนน${NC}"
  ((SCORE+=5))
else
  echo -e "  - Ingress ports complex object list: ${RED}0 คะแนน${NC}"
fi

# Section 3: Locals & Dynamic Security Group (25 pts)
echo -e "\n${BOLD}[ส่วนที่ 3: Locals & Dynamic SG (25 คะแนน)]${NC}"
if grep -q 'is_production' locals.tf 2>/dev/null && grep -q '?' locals.tf 2>/dev/null; then
  echo -e "  - Locals ternary environment sizing: ${GREEN}+5 คะแนน${NC}"
  ((SCORE+=5))
else
  echo -e "  - Locals ternary environment sizing: ${RED}0 คะแนน${NC}"
fi

if grep -qE 'resource[[:space:]]+"aws_vpc"' main.tf 2>/dev/null; then
  echo -e "  - VPC resource declaration: ${GREEN}+5 คะแนน${NC}"
  ((SCORE+=5))
else
  echo -e "  - VPC resource declaration: ${RED}0 คะแนน${NC}"
fi

if grep -qE 'dynamic[[:space:]]+"ingress"' main.tf 2>/dev/null && grep -qE 'content[[:space:]]*\{' main.tf 2>/dev/null; then
  echo -e "  - Dynamic Ingress Block in SG: ${GREEN}+10 คะแนน${NC}"
  ((SCORE+=10))
else
  echo -e "  - Dynamic Ingress Block in SG: ${RED}0 คะแนน${NC}"
fi

if grep -qE 'module[[:space:]]+"app_cluster"' main.tf 2>/dev/null; then
  echo -e "  - Module app_cluster instantiation: ${GREEN}+5 คะแนน${NC}"
  ((SCORE+=5))
else
  echo -e "  - Module app_cluster instantiation: ${RED}0 คะแนน${NC}"
fi

# Section 4: Outputs & Expressions (15 pts)
echo -e "\n${BOLD}[ส่วนที่ 4: Outputs & Expressions (15 คะแนน)]${NC}"
if grep -qE 'format[[:space:]]*\(' outputs.tf 2>/dev/null; then
  echo -e "  - Summary report with format() function: ${GREEN}+5 คะแนน${NC}"
  ((SCORE+=5))
else
  echo -e "  - Summary report with format() function: ${RED}0 คะแนน${NC}"
fi

if grep -qE '\[[[:space:]]*for .* in var\.ingress_ports' outputs.tf 2>/dev/null; then
  echo -e "  - Ports list using for expression: ${GREEN}+5 คะแนน${NC}"
  ((SCORE+=5))
else
  echo -e "  - Ports list using for expression: ${RED}0 คะแนน${NC}"
fi

if grep -qE 'module\.app_cluster\.node_ids' outputs.tf 2>/dev/null; then
  echo -e "  - Exporting child module output: ${GREEN}+5 คะแนน${NC}"
  ((SCORE+=5))
else
  echo -e "  - Exporting child module output: ${RED}0 คะแนน${NC}"
fi

# Section 5: CLI & Validation (15 pts)
echo -e "\n${BOLD}[ส่วนที่ 5: CLI Formatting & Validation (15 คะแนน)]${NC}"
if terraform fmt -check > /dev/null 2>&1; then
  echo -e "  - terraform fmt formatting: ${GREEN}+5 คะแนน${NC}"
  ((SCORE+=5))
else
  echo -e "  - terraform fmt formatting: ${YELLOW}0 คะแนน (รัน 'terraform fmt' เพื่อจัดระเบียบ)${NC}"
fi

if [ -d "$CACHE_DIR" ]; then
  terraform init -input=false -plugin-dir="$CACHE_DIR_ARG" > /dev/null 2>&1 || terraform init -input=false > /dev/null 2>&1
else
  terraform init -input=false > /dev/null 2>&1
fi

if terraform validate > /dev/null 2>&1; then
  echo -e "  - terraform validate syntax check: ${GREEN}+10 คะแนน${NC}"
  ((SCORE+=10))
else
  echo -e "  - terraform validate syntax check: ${RED}0 คะแนน (validate ไม่ผ่าน)${NC}"
fi

echo -e "\n================================================================"
if [ "$SCORE" -ge 80 ]; then
  echo -e "${GREEN}🏆 ยอดเยี่ยมมาก! คะแนนรวม: $SCORE / 100 คะแนน (เกรด A)${NC}"
elif [ "$SCORE" -ge 60 ]; then
  echo -e "${YELLOW}👍 ผ่านเกณฑ์! คะแนนรวม: $SCORE / 100 คะแนน (ลองแก้จุดที่ตกเพื่อคะแนนเต็ม)${NC}"
else
  echo -e "${RED}⚠️ ต้องฝึกซ้อมเพิ่ม! คะแนนรวม: $SCORE / 100 คะแนน (เปิดดูแนวทางใน solution/)${NC}"
fi
echo -e "================================================================\n"
