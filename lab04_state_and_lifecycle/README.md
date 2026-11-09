# 🧪 Lab 04: The Plan/Apply Lifecycle, State & Variable Precedence

## 🎯 วัตถุประสงค์การเรียนรู้
1. เข้าใจลำดับความสำคัญของตัวแปร (Variable Input Precedence 5 ลำดับ)
2. สร้างและวิเคราะห์ Dependency Graph (`terraform graph`)
3. บันทึก Execution Plan ลงไฟล์ (`terraform plan -out=...`) และนำไป apply
4. ใช้งาน Planning Modes & CLI Flags:
   - `-target` เพื่อ plan/apply เฉพาะ resource
   - `-replace` เพื่อบังคับ destroy แล้ว create ใหม่ (แทนที่คำสั่ง `taint` ในอดีต)
   - `-refresh-only` เพื่อตรวจสอบ drift ระหว่าง Cloud จริงกับ State file
5. เข้าใจโครงสร้าง State file (`serial`, `lineage`, `resources`, `schema_version`)

---

## 📝 ส่วนที่ 1: Variable Input Precedence (ออกทฤษฎี/สอบข้อเขียนบ่อยมาก!)
เรียงจากความสำคัญ **ต่ำสุด -> สูงสุด** (ตัวที่อยู่ล่างสุดจะ Override ทับตัวบนเสมอ):
1. **Default value** ในบล็อก `variable`
2. **Environment variable**: `TF_VAR_<variable_name>`
3. ไฟล์ **`terraform.tfvars`** (หรือ `terraform.tfvars.json`)
4. ไฟล์ **`*.auto.tfvars`** (เรียงตามลำดับชื่อไฟล์ตามตัวอักษร)
5. CLI Flags: **`-var`** หรือ **`-var-file`** (มีอำนาจสูงสุด ชนะทุกอย่าง!)

---

## 📝 ส่วนที่ 2: โจทย์ฝึกปฏิบัติการ

สร้างชุดไฟล์โครงสร้างจำลองการเกิด Dependency:
1. **`variables.tf`**:
   - `instance_name` (type: string, default: "default-server")
   - `environment` (type: string, default: "dev")
2. **`main.tf`**:
   - สร้าง resource `terraform_data "network"` (เป็น built-in resource ไม่ต้องใช้ cloud)
     - กำหนด `input = "10.0.0.0/16"`
   - สร้าง resource `terraform_data "subnet"`
     - กำหนด `input = "${terraform_data.network.output}-subnet-a"`
     - บังคับลำดับ dependency โดยใช้ `depends_on = [terraform_data.network]`
   - สร้าง resource `terraform_data "server"`
     - กำหนด `input = "${terraform_data.subnet.output}-${var.instance_name}"`
3. **`outputs.tf`**:
   - `server_full_address = terraform_data.server.output`

---

## 🔍 แบบฝึกหัดคำสั่ง CLI ที่ต้องทดสอบพิมพ์ให้คล่อง

### 1. ทดสอบบันทึก Plan File
```bash
# Plan และบันทึกลงไฟล์ชื่อ myplan.tfplan
terraform plan -out=myplan.tfplan

# ตรวจสอบเนื้อหาของ plan file
terraform show myplan.tfplan

# Apply จากไฟล์ plan (จะไม่ถามพิมพ์ yes ซ้ำ)
terraform apply myplan.tfplan
```

### 2. ทดสอบ -target
```bash
# สั่ง plan หรือ apply เจาะจงเฉพาะ resource network
terraform plan -target=terraform_data.network
```

### 3. ทดสอบ -replace
```bash
# สั่งทำลายและสร้าง resource subnet ใหม่
terraform plan -replace=terraform_data.subnet
```

### 4. ทดสอบ Variable Precedence
```bash
# สร้าง terraform.tfvars
echo 'instance_name = "from-tfvars"' > terraform.tfvars

# รันด้วย -var ทับ
terraform plan -var="instance_name=from-cli-override"
# สังเกตว่าค่าจะกลายเป็น "from-cli-override" เพราะ CLI flag ชนะ tfvars เสมอ
```
