# 🧪 Lab 05: Remote State, State Locking, State Manipulation & Import

## 🎯 วัตถุประสงค์การเรียนรู้
1. กำหนดค่า Remote State Backend บน AWS S3 (`backend "s3"`) พร้อมการ Lock
2. จัดการ State Locking และคำสั่งปลด Lock เมื่อชนกัน (`terraform force-unlock <LOCK-ID>`)
3. ย้ายชื่อ Resource ใน State โดยไม่ทำลายของจริง (`terraform state mv`)
4. นำ Resource ออกจาก State โดยไม่ลบของจริงบน Cloud (`terraform state rm`)
5. นำทรัพยากรที่มีอยู่แล้วเข้ามาในการดูแลของ Terraform (`terraform import` และ `import {}` block)
6. แชร์ข้อมูลข้าม Project ด้วย `data "terraform_remote_state"`

---

## 📝 ส่วนที่ 1: Syntax สำคัญของ Lab 05

### 1.1 การคอนฟิก Backend S3
```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-2026"
    key            = "environments/prod/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-table" # หรือ S3 native locking
  }
}
```

### 1.2 การดึงค่า State ข้ามโปรเจกต์ด้วย `terraform_remote_state`
```hcl
data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "my-terraform-state-bucket-2026"
    key    = "network/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

# เรียกใช้ Output ของโปรเจกต์ network:
# data.terraform_remote_state.network.outputs.<output_name>
```

### 1.3 บล็อก `import` (Syntax ใหม่ใน Terraform 1.5+)
```hcl
import {
  to = aws_s3_bucket.legacy_bucket
  id = "already-existing-bucket-name"
}
```

---

## 📝 ส่วนที่ 2: โจทย์ฝึกซ้อม State CLI Manipulation

### 1. จำลองการสร้าง State
สร้าง `terraform_data "old_database"` และ `terraform_data "app"` ใน `main.tf`
```bash
terraform init
terraform apply -auto-approve
terraform state list
```

### 2. ซ้อมคำสั่ง `terraform state mv` (ย้ายชื่อ Resource)
ต้องการเปลี่ยนชื่อจาก `terraform_data.old_database` เป็น `terraform_data.primary_db`:
```bash
# 1. แก้ชื่อใน main.tf ให้เป็น resource "terraform_data" "primary_db"
# 2. ย้าย address ใน state เพื่อไม่ให้มันลบแล้วสร้างใหม่:
terraform state mv terraform_data.old_database terraform_data.primary_db

# 3. รัน plan ตรวจสอบ ต้องขึ้น No changes!
terraform plan
```

### 3. ซ้อมคำสั่ง `terraform state rm` (ถอด resource ออกจาก state)
```bash
# ลบ resource ออกจาก state
terraform state rm terraform_data.primary_db

# ตรวจสอบ list ใน state
terraform state list
```

---

## 💡 สรุปข้อสอบ State Commands ที่ต้องจำ
- **State Lock Collision**: เมื่อมีคน apply พร้อมกันจะเจอ `Error: Error acquiring the state lock`
- **วิธีปลด Lock ฉุกเฉิน**: `terraform force-unlock <LOCK-ID>`
- **ความต่างระหว่าง `state rm` กับ `destroy`**:
  - `terraform destroy`: ลบ resource จริงบน Cloud ทิ้ง
  - `terraform state rm`: แค่เอาออกจากสมุดจด (State) ทรัพยากรจริงบน Cloud ยังคงอยู่เหมือนเดิม 100%
- **`state mv`**: ใช้เมื่อเรา refactor ย้าย resource เดี่ยวเข้าไปอยู่ใน module หรือเปลี่ยนชื่อ resource โดยไม่อยากให้มันถูกทำลายแล้วสร้างใหม่
