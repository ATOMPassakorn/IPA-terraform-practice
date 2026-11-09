#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_help() {
  echo "=========================================================="
  echo "🛠️  Terraform Practice Suite - Check Runner"
  echo "=========================================================="
  echo "วิธีใช้งานคำสั่งตรวจคำตอบ:"
  echo "  ./check.sh lab01        - ตรวจคำตอบของ Lab 01"
  echo "  ./check.sh lab02        - ตรวจคำตอบของ Lab 02"
  echo "  ./check.sh lab03        - ตรวจคำตอบของ Lab 03"
  echo "  ./check.sh lab04        - ตรวจคำตอบของ Lab 04"
  echo "  ./check.sh lab05        - ตรวจคำตอบของ Lab 05"
  echo "  ./check.sh mock         - ตรวจและคำนวณคะแนน Mock Exam (100 คะแนน)"
  echo "  ./check.sh all          - ตรวจทุก Lab รวดเดียว"
  echo ""
  echo "ทริก: เติม --solution เพื่อตรวจเช็กกับไฟล์เฉลย เช่น ./check.sh lab01 --solution"
  echo "=========================================================="
}

TARGET="$1"
FLAG="$2"

case "$TARGET" in
  lab01|1)
    "$SCRIPT_DIR/lab01_hcl_basics/check.sh" $FLAG
    ;;
  lab02|2)
    "$SCRIPT_DIR/lab02_variables_modules/check.sh" $FLAG
    ;;
  lab03|3)
    "$SCRIPT_DIR/lab03_iteration_dynamic/check.sh" $FLAG
    ;;
  lab04|4)
    "$SCRIPT_DIR/lab04_state_and_lifecycle/check.sh" $FLAG
    ;;
  lab05|5)
    "$SCRIPT_DIR/lab05_remote_state_management/check.sh" $FLAG
    ;;
  mock|exam)
    "$SCRIPT_DIR/mock_exam_full/check.sh" $FLAG
    ;;
  all)
    "$SCRIPT_DIR/lab01_hcl_basics/check.sh" $FLAG
    "$SCRIPT_DIR/lab02_variables_modules/check.sh" $FLAG
    "$SCRIPT_DIR/lab03_iteration_dynamic/check.sh" $FLAG
    "$SCRIPT_DIR/lab04_state_and_lifecycle/check.sh" $FLAG
    "$SCRIPT_DIR/lab05_remote_state_management/check.sh" $FLAG
    "$SCRIPT_DIR/mock_exam_full/check.sh" $FLAG
    ;;
  *)
    show_help
    ;;
esac
