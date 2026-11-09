# 🚀 Terraform Syntax Drill & Practice Exam Suite
**คู่มือและชุดแบบฝึกหัดสำหรับเตรียมสอบเขียน Terraform (Lab 1 - Lab 5 + Mock Exam)**

ชุดแบบฝึกหัดนี้ออกแบบมาโดยเฉพาะสำหรับการเตรียมตัวสอบเขียนโค้ด Terraform ด้วยตัวเองจากไฟล์ว่าง (From Scratch) โดยสามารถเปิด Official Documentation ควบคู่ไปด้วยได้ พร้อมระบบตรวจคำตอบอัตโนมัติที่รองรับทั้ง **Linux, macOS, WSL และ Windows (Git Bash / PowerShell / CMD)**

---

## 📁 โครงสร้างชุดฝึกซ้อม

```
practice-terraform/
├── README.md                          # แนะนำวิธีการใช้งานและคำสั่งตรวจคำตอบ
├── CHEATSHEET.md                      # สรุป Syntax ทุกโครงสร้าง + แผนที่นำทาง Official Docs
│
├── lab01_hcl_basics/                  # ด่านที่ 1: Provider, Data Source, Resource, Lifecycle
│   ├── README.md                      # โจทย์และข้อกำหนด
│   ├── check.sh                       # สคริปต์ตรวจคำตอบของ Lab 01
│   ├── practice/                      # (แนะนำ) โฟลเดอร์สำหรับเขียนโค้ดของคุณเอง
│   └── solution/                      # เฉลยโค้ดที่ถูกต้อง
│
├── lab02_variables_modules/           # ด่านที่ 2: Variables, Object Type, Validation, Locals, Outputs, Modules
│   ├── README.md
│   ├── check.sh
│   ├── practice/
│   └── solution/
│
├── lab03_iteration_dynamic/           # ด่านที่ 3: Expressions, count vs for_each, for list/map, dynamic blocks, try/can
│   ├── README.md
│   ├── check.sh
│   ├── practice/
│   └── solution/
│
├── lab04_state_and_lifecycle/         # ด่านที่ 4: Graph, Plan Files, Targeting (-target, -replace), Variable Precedence
│   ├── README.md
│   ├── check.sh
│   ├── practice/
│   └── solution/
│
├── lab05_remote_state_management/     # ด่านที่ 5: S3 Backend, State Locking, state mv/rm, import, remote_state
│   ├── README.md
│   ├── check.sh
│   ├── practice/
│   └── solution/
│
├── mock_exam_full/                    # 🎯 ข้อสอบจำลองเสมือนจริง (เขียนจากไฟล์ว่าง จับเวลา 60-90 นาที)
│   ├── README.md                      # โจทย์สอบจำลอง 5 พาร์ท + เกณฑ์ให้คะแนน (100 คะแนน)
│   ├── check.sh                       # สคริปต์ตรวจและคิดคะแนนสอบเต็ม 100
│   ├── practice/
│   └── solution/                      # เฉลยข้อสอบจำลอง
│
├── check.sh                           # 🛠️ สคริปต์ตรวจคำตอบหลัก (Linux / macOS / WSL / Windows Git Bash)
├── check.ps1                          # 🪟 สคริปต์ตรวจคำตอบสำหรับ Windows PowerShell
├── check.bat                          # 🪟 สคริปต์ตรวจคำตอบสำหรับ Windows Command Prompt
└── test_all.sh                        # สคริปต์ตรวจความถูกต้องของ syntax ทุกเฉลยอัตโนมัติ
```

---

## ✍️ จะเริ่มเขียนโค้ดตรงไหนได้บ้าง? (Auto-Detect)

ระบบตรวจคำตอบรองรับการตรวจหาโค้ดที่คุณเขียนได้ **2 รูปแบบอัตโนมัติ**:
1. **(แนะนำ)** สร้างโฟลเดอร์ย่อยชื่อ `practice/` ในแล็บนั้นๆ เช่น `lab01_hcl_basics/practice/` แล้ววางไฟล์ `.tf` ทั้งหมดไว้ข้างใน
2. หรือสร้างไฟล์ `.tf` วางไว้ในโฟลเดอร์ของแล็บนั้นโดยตรง เช่น `lab01_hcl_basics/main.tf`

> ระบบจะตรวจโค้ดที่คุณเขียนจริงเสมอ และจะไม่แอบสลับไปตรวจ `solution` เว้นแต่จะระบุ flag `--solution` ชัดเจน

---

## 🧪 วิธีรันคำสั่งตรวจคำตอบ (Checking Commands)

### 🐧 บน Linux / macOS / WSL / Windows Git Bash (แนะนำ)
เปิด Terminal ในโฟลเดอร์ `practice-terraform/`:
```bash
./check.sh lab01    # ตรวจ Lab 01
./check.sh lab02    # ตรวจ Lab 02
./check.sh lab03    # ตรวจ Lab 03
./check.sh lab04    # ตรวจ Lab 04
./check.sh lab05    # ตรวจ Lab 05
./check.sh mock     # ตรวจและตัดเกรด Mock Exam (เต็ม 100 คะแนน)
./check.sh all      # ตรวจรวดเดียวทุกข้อ
```

หรือถ้า `cd` เข้าไปทำในโฟลเดอร์ย่อย สามารถสั่งตรวจได้เลย:
```bash
cd lab01_hcl_basics/practice
../check.sh
```

---

### 🪟 บน Windows PowerShell (VS Code Terminal)
เปิด PowerShell ในโฟลเดอร์ `practice-terraform/`:
```powershell
.\check.ps1 lab01   # ตรวจ Lab 01
.\check.ps1 lab02   # ตรวจ Lab 02
.\check.ps1 lab03   # ตรวจ Lab 03
.\check.ps1 lab04   # ตรวจ Lab 04
.\check.ps1 lab05   # ตรวจ Lab 05
.\check.ps1 mock    # ตรวจและคิดคะแนน Mock Exam (100 คะแนน)
.\check.ps1 all     # ตรวจทุกข้อรวดเดียว
```

---

### 🪟 บน Windows Command Prompt (CMD)
เปิด Command Prompt ในโฟลเดอร์ `practice-terraform/`:
```cmd
check.bat lab01     :: ตรวจ Lab 01
check.bat lab02     :: ตรวจ Lab 02
check.bat lab03     :: ตรวจ Lab 03
check.bat lab04     :: ตรวจ Lab 04
check.bat lab05     :: ตรวจ Lab 05
check.bat mock      :: ตรวจและคิดคะแนน Mock Exam (100 คะแนน)
check.bat all       :: ตรวจทุกข้อรวดเดียว
```

---

### 💡 ทริก: ตรวจสอบเทียบกับไฟล์เฉลย (Solution Mode)
หากต้องการดูว่าไฟล์เฉลยได้ผลลัพธ์คะแนนเต็มอย่างไร สามารถเติม `--solution` หรือ `-s` ได้ทุกคำสั่ง:

- **บน Git Bash / Linux:**
  ```bash
  ./check.sh lab01 --solution
  ./check.sh mock --solution
  ```
- **บน Windows PowerShell:**
  ```powershell
  .\check.ps1 lab01 --solution
  .\check.ps1 mock --solution
  ```
- **บน Windows Command Prompt:**
  ```cmd
  check.bat lab01 --solution
  check.bat mock --solution
  ```


---

## 🛠️ การฝึกแบบ Offline 100%

แคชของ Terraform Provider ถูกเตรียมไว้ในโฟลเดอร์ `.terraform-cache/` เรียบร้อยแล้ว (รองรับทั้ง `linux_amd64` และ `windows_amd64`):
```bash
# ทดสอบความถูกต้องของ Syntax และ Type:
terraform init
terraform validate

# จัดระเบียบการย่อหน้าและช่องว่างตามมาตรฐาน:
terraform fmt

# ทดสอบรันคำนวณ Built-in Functions และ Expressions ไวๆ:
terraform console
```
