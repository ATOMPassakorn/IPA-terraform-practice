#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)/.terraform-cache"

echo "=========================================================="
echo "🧪 Running Terraform Validation for All Practice Solutions"
echo "=========================================================="

SOLUTIONS=(
  "$SCRIPT_DIR/lab01_hcl_basics/solution"
  "$SCRIPT_DIR/lab02_variables_modules/solution"
  "$SCRIPT_DIR/lab03_iteration_dynamic/solution"
  "$SCRIPT_DIR/lab04_state_and_lifecycle/solution"
  "$SCRIPT_DIR/lab05_remote_state_management/solution"
  "$SCRIPT_DIR/mock_exam_full/solution"
)

for sol in "${SOLUTIONS[@]}"; do
  rel_path="${sol#$SCRIPT_DIR/}"
  echo -e "\n📂 Checking: $rel_path"
  cd "$sol"

  echo "  ▶ terraform fmt -check"
  terraform fmt -check

  echo "  ▶ terraform init (using local cache: $CACHE_DIR)"
  if [ -d "$CACHE_DIR" ]; then
    terraform init -input=false -plugin-dir="$CACHE_DIR" > /dev/null 2>&1 || terraform init -input=false > /dev/null
  else
    terraform init -input=false > /dev/null
  fi

  echo "  ▶ terraform validate"
  terraform validate

  echo "  ✅ PASS"
done

echo -e "\n🎉 ALL SOLUTIONS ARE VALID AND READY FOR PRACTICE! 🎉\n"
