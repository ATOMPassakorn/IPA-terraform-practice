# 🧪 Lab 01: HCL Components, First Resource & Lifecycle

## 🎯 วัตถุประสงค์การเรียนรู้
1. สร้างโครงสร้างไฟล์มาตรฐาน Terraform (`terraform.tf`, `provider.tf`, `main.tf`)
2. กำหนด `terraform {}` block พร้อม `required_providers` (AWS version ~> 5.0)
3. คอนฟิก AWS Provider
4. ค้นหา AMI ด้วย Data Source (`data "aws_ami" "ubuntu"`)
5. ประกาศ Resource `aws_instance` พร้อมกำหนด Tag
6. กำหนด `lifecycle` meta-argument (`prevent_destroy`, `ignore_changes`)

---

## 📝 โจทย์ที่ต้องลงมือทำ (เริ่มจากไฟล์ว่าง)

สร้างโฟลเดอร์นี้และเขียนไฟล์ด้วยตนเอง:

### 1. `terraform.tf`
- กำหนด `required_version` ให้รองรับ `>= 1.5.0`
- กำหนด `required_providers` สำหรับ `aws`:
  - `source = "hashicorp/aws"`
  - `version = "~> 5.0"`

### 2. `provider.tf`
- คอนฟิก `provider "aws"`:
  - `region = "ap-southeast-1"`
  - ใส่ mock settings สำหรับทดสอบแบบ offline:
    ```hcl
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    access_key                  = "mock_key"
    secret_key                  = "mock_secret"
    ```

### 3. `main.tf`
- สร้าง Data Source `data "aws_ami" "ubuntu"`:
  - `most_recent = true`
  - `owners = ["099720109477"]` (Canonical)
  - filter name: `ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*`
- สร้าง Resource `aws_instance "web"`:
  - `ami = data.aws_ami.ubuntu.id`
  - `instance_type = "t3.micro"`
  - กำหนด tag: `Name = "lab01-web-server"`, `Environment = "dev"`
  - ใส่ block `lifecycle`:
    - `prevent_destroy = false`
    - `ignore_changes = [tags["Environment"]]`

---

## 🔍 คำสั่งตรวจสอบผลลัพธ์
เมื่อเขียนเสร็จ ให้รันคำสั่งเหล่านี้ในโฟลเดอร์ของแล็บ:
```bash
terraform fmt -check
terraform init
terraform validate
```
ต้องผ่านโดยไม่มี error (`Success! The configuration is valid.`)

---

## 💡 ดูเฉลย
หากติดขัดหรือต้องการตรวจคำตอบ สามารถดูโค้ดตัวอย่างได้ที่โฟลเดอร์ `solution/`
