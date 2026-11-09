# 🧪 Lab 02: Variables, Validation, Locals & Reusable Modules

## 🎯 วัตถุประสงค์การเรียนรู้
1. ประกาศ Input Variables ทั้ง Primitive type และ Complex Type (`object`)
2. เขียน `validation` block สำหรับตรวจสอบค่าตัวแปร พร้อม `error_message`
3. กำหนดตัวแปรความลับด้วย `sensitive = true`
4. ใช้ `locals` คำนวณค่าซ้ำๆ และประเมิน Ternary expression
5. ประกาศ `outputs` เพื่อส่งออกค่า
6. แยกโค้ดเป็น Child Module (`modules/web_app`) และเรียกใช้จาก Root Module

---

## 📝 โจทย์ที่ต้องลงมือทำ

### ส่วนที่ 1: สร้าง Child Module (`modules/web_app/`)
สร้างไฟล์ภายใน `modules/web_app/`:
1. **`variables.tf`**:
   - `instance_type` (type: string, default: "t3.micro")
   - `server_name` (type: string, description: "Name prefix for server")
   - `volume_config` (type: object):
     ```hcl
     object({
       size_gb   = number
       encrypted = bool
     })
     ```
     มี validation block: ตรวจสอบว่า `size_gb >= 10 && size_gb <= 100` ถ้าไม่ตรงเงื่อนไขแจ้งว่า "Volume size must be between 10 and 100 GB."
   - `tags` (type: map(string), default: {})
2. **`main.tf`**:
   - data source `aws_ami`
   - resource `aws_instance "server"`:
     - ใช้ ami จาก data source
     - กำหนด `instance_type = var.instance_type`
     - กำหนด root block device โดยดึงค่าจาก `var.volume_config.size_gb` และ `encrypted`
     - รวม tag ด้วย `merge(var.tags, { Name = var.server_name })`
3. **`outputs.tf`**:
   - `instance_id`: ส่งค่า `aws_instance.server.id`
   - `private_ip`: ส่งค่า `aws_instance.server.private_ip`

---

### ส่วนที่ 2: Root Module
สร้างไฟล์ที่โฟลเดอร์หลักของ `lab02_variables_modules/`:
1. **`terraform.tf` & `provider.tf`**:
   - AWS provider configuration (mock settings for offline testing)
2. **`variables.tf`**:
   - `environment`: (type: string, default: "dev")
     - validation: ค่าต้องเป็นหนึ่งใน `["dev", "staging", "prod"]` เท่านั้น
   - `admin_password`: (type: string, sensitive: true)
3. **`locals.tf`**:
   - `project_name = "ipa-practice"`
   - `is_production = var.environment == "prod"`
   - `computed_instance_type = local.is_production ? "t3.small" : "t3.micro"`
   - `common_tags = { Project = local.project_name, Environment = var.environment }`
4. **`main.tf`**:
   - เรียกใช้ child module ด้วย `module "web"`:
     - `source = "./modules/web_app"`
     - `instance_type = local.computed_instance_type`
     - `server_name = "${local.project_name}-${var.environment}-web"`
     - `volume_config = { size_gb = local.is_production ? 30 : 10, encrypted = true }`
     - `tags = local.common_tags`
5. **`outputs.tf`**:
   - `server_id`: อ้างอิงจาก `module.web.instance_id`
   - `server_private_ip`: อ้างอิงจาก `module.web.private_ip`

---

## 🔍 คำสั่งตรวจสอบผลลัพธ์
```bash
terraform fmt -check
terraform init
terraform validate
```
ผลลัพธ์ต้องผ่านฉลุย!
