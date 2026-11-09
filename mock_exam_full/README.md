# 🎓 ข้อสอบจำลองเสมือนจริง: Terraform Coding Exam (Mock Exam)
**ระยะเวลาจำลอง:** 60 - 90 นาที  
**กติกา:** อนุญาตให้เปิด Official Documentation ได้ แต่ต้องเขียนโค้ดเองจากไฟล์ว่างทั้งหมด (ห้าม Copy โค้ดจากเฉลย)

---

## 📋 สถานการณ์ของโจทย์ (Scenario)
บริษัทต้องการสร้างโครงสร้างพื้นฐานระบบเว็บแอปพลิเคชันที่มีความยืดหยุ่นสูง รองรับหลายสภาพแวดล้อม (`dev`, `staging`, `prod`) โดยกำหนดให้เขียนโค้ดด้วย Terraform ตามมาตรฐานดังต่อไปนี้:

---

## 🎯 รายละเอียดข้อกำหนดที่ต้องเขียน (รวม 100 คะแนน)

### ส่วนที่ 1: การจัดการ Child Module (`modules/service_cluster/`) [25 คะแนน]
สร้างโมดูลที่นำกลับมาใช้ซ้ำได้ที่โฟลเดอร์ `modules/service_cluster/`:
1. **`variables.tf`**:
   - `cluster_name` (string): ชื่อของ cluster
   - `environment` (string)
   - `node_specs` (map of objects): รับชุด config ของเครื่อง เช่น:
     ```hcl
     {
       "web" = { instance_type = "t3.micro", disk_gb = 20 }
       "api" = { instance_type = "t3.small", disk_gb = 30 }
     }
     ```
     มี validation block: ทุก disk_gb ใน map ต้อง `>= 10` และ `<= 100` (ใช้ฟังก์ชัน `alltrue([for k, v in var.node_specs : v.disk_gb >= 10 && v.disk_gb <= 100])`)
   - `tags` (map(string), default = {})
2. **`main.tf`**:
   - Data source `aws_ami` สำหรับ Ubuntu 22.04 LTS (Canonical owner `099720109477`)
   - Resource `aws_instance "nodes"`:
     - ใช้ `for_each = var.node_specs`
     - ผูก `ami = data.aws_ami.ubuntu.id`
     - `instance_type = each.value.instance_type`
     - กำหนด `root_block_device`: `volume_size = each.value.disk_gb`
     - Lifecycle: `create_before_destroy = true`
     - Tags: `merge(var.tags, { Name = "${var.cluster_name}-${each.key}" })`
3. **`outputs.tf`**:
   - `node_ids`: Map ของ `node_name => instance_id`
   - `node_private_ips`: Map ของ `node_name => private_ip`

---

### ส่วนที่ 2: Root Configuration & Variables [20 คะแนน]
ที่โฟลเดอร์หลักของ `mock_exam_full/`:
1. **`terraform.tf`**:
   - `required_version = ">= 1.5.0"`
   - `required_providers`: `aws (~> 5.0)`
2. **`provider.tf`**:
   - Region: `ap-southeast-1`
   - ใส่ mock credentials เพื่อให้ทดสอบแบบ Offline ได้ (`skip_credentials_validation = true`, `skip_requesting_account_id = true`, `skip_metadata_api_check = true`, `access_key = "mock"`, `secret_key = "mock"`)
3. **`variables.tf`**:
   - `environment` (string, default = "dev"):
     - validation block: ต้องเป็น `"dev"`, `"staging"`, หรือ `"prod"` เท่านั้น
   - `project_name` (string, default = "ipa-exam")
   - `admin_api_token` (string, sensitive = true, default = "SecretToken123456")
   - `ingress_ports` (list(object({
       port        = number
       protocol    = string
       description = string
     }))):
     - default: พอร์ต 80 (HTTP), 443 (HTTPS), 8080 (App)

---

### ส่วนที่ 3: Locals & Dynamic Security Group [25 คะแนน]
1. **`locals.tf`**:
   - `is_production = var.environment == "prod"`
   - `cluster_prefix = "${var.project_name}-${var.environment}"`
   - `cluster_nodes`: กำหนด map ของ nodes:
     - ถ้าเป็น prod ให้ใช้ `t3.medium` และดิสก์ `50GB`
     - ถ้าไม่ใช่ prod ให้ใช้ `t3.micro` และดิสก์ `20GB`
     (มีอย่างน้อย 2 โหนด: `frontend` และ `backend`)
   - `common_tags`: Map รวม `Project`, `Environment`, `ManagedBy = "Terraform"`
2. **`main.tf`**:
   - Resource `aws_vpc "main"` (`cidr_block = "10.100.0.0/16"`)
   - Resource `aws_security_group "cluster_sg"`:
     - ผูกกับ `aws_vpc.main.id`
     - ใช้ **`dynamic "ingress"`** วนลูปตาม `var.ingress_ports`:
       - `from_port = ingress.value.port`
       - `to_port = ingress.value.port`
       - `protocol = ingress.value.protocol`
       - `description = ingress.value.description`
       - `cidr_blocks = ["0.0.0.0/0"]`
     - บล็อก `egress`: อนุญาต all outbound traffic (`0.0.0.0/0`)
   - เรียกใช้ Child Module:
     ```hcl
     module "app_cluster" {
       source       = "./modules/service_cluster"
       cluster_name = local.cluster_prefix
       environment  = var.environment
       node_specs   = local.cluster_nodes
       tags         = local.common_tags
     }
     ```

---

### ส่วนที่ 4: Outputs & Expressions [15 คะแนน]
ใน **`outputs.tf`**:
1. `cluster_node_ids`: ส่งออก Map ของ node IDs ที่ได้มาจาก `module.app_cluster.node_ids`
2. `summary_report`: ส่งออก string ข้อความสรุปด้วยฟังก์ชัน `format()` เช่น:
   `"Cluster [ipa-exam-dev] deployed with 2 nodes"` (ใช้ `length(keys(local.cluster_nodes))`)
3. `public_ports_allowed`: ใช้ `for` expression สกัดเฉพาะเลข port จาก `var.ingress_ports` ออกมาเป็น list of numbers: `[for p in var.ingress_ports : p.port]`

---

### ส่วนที่ 5: State & CLI Verification [15 คะแนน]
ทดสอบคำสั่งทั้งหมดผ่าน Terminal:
1. `terraform fmt -check` (ต้องไม่มีไฟล์ไหนเตือนเรื่อง formatting)
2. `terraform init -plugin-dir=/home/atompassakorn/Downloads/ipa-terraform/.terraform-cache` (ต้อง initialized สำเร็จ)
3. `terraform validate` (ต้องขึ้น `Success! The configuration is valid.`)
4. ตอบคำถามสั้น (Self-check):
   - Q1: หากต้องการลบเฉพาะ `aws_security_group.cluster_sg` ออกจาก State โดยไม่ทำลายของจริงบน AWS ต้องพิมพ์คำสั่งใด?
   - Q2: หากต้องการสั่งสร้างโหนด `aws_instance.nodes["web"]` ใหม่ทันทีในการ apply ครั้งต่อไป ต้องใช้ Flag ใด?

---

## 📊 เกณฑ์การให้คะแนน (Scoring Rubric - 100 คะแนน)

| ส่วน | รายละเอียด | คะแนนเต็ม | คะแนนที่ได้ |
|---|---|:---:|:---:|
| 1. Child Module | ประกาศ Input/Output และ Validation condition ถูกต้อง | 25 | |
| 2. Root & Providers | Provider mock, Variable validation และ Sensitive | 20 | |
| 3. Dynamic SG & Locals| `dynamic` block ingress และ Ternary ใน locals ถูกต้อง | 25 | |
| 4. Outputs & For Expr | `for` list comprehension, `format()` และ module output | 15 | |
| 5. CLI & Validation | ผ่าน `terraform fmt` และ `terraform validate` สมบูรณ์ | 15 | |
| **รวม** | | **100** | |

---

## 💡 ดูเฉลยและแนวทางคำตอบ
เมื่อฝึกทำจนเสร็จสิ้นหรือติดขัด สามารถเปิดดูไฟล์เฉลยได้ที่โฟลเดอร์ `solution/`
