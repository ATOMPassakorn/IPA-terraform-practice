# 📖 Terraform Syntax & Exam Cheat Sheet

สรุปรูปแบบ Syntax สำคัญทั้งหมด ครอบคลุมเนื้อหา Lab 1 ถึง Lab 5 พร้อมเทคนิคการค้นหาใน Official Docs ให้เจอไวที่สุดในห้องสอบ

---

## 🔍 เทคนิคค้นหาใน Official Documentation ในห้องสอบ
เมื่ออาจารย์อนุญาตให้เปิด Terraform Official Docs และ AWS Provider Docs (https://registry.terraform.io/providers/hashicorp/aws/latest/docs) ให้ใช้ Keyword ค้นหาดังนี้:

| สิ่งที่ต้องการหา | Keyword ค้นหาที่แม่นที่สุด | หัวข้อใน Docs |
|---|---|---|
| โครงสร้าง `terraform {}` | `terraform settings block` | Configuration > Terraform Settings |
| การเขียนเงื่อนไขตรวจสอบตัวแปร | `custom condition checks` หรือ `variable validation` | Configuration > Variables > Custom Condition Checks |
| การวนซ้ำ resource | `for_each meta-argument` หรือ `count meta-argument` | Configuration > Resources > Meta-arguments |
| การวนซ้ำ nested block ซ้ำๆ | `dynamic blocks` | Configuration > Expressions > Dynamic Blocks |
| การแปลงข้อมูล list/map | `for expressions` | Configuration > Expressions > For Expressions |
| ฟังก์ชันต่างๆ | `functions list` หรือชื่อฟังก์ชัน เช่น `merge function` | Configuration > Functions |
| การตั้งค่า Remote S3 | `backend s3` | Language > Settings > Backends > s3 |
| การสั่งข้ามการทำลาย/สร้างก่อน | `lifecycle meta-argument` | Configuration > Resources > Meta-arguments > lifecycle |
| การดึงค่า state อื่น | `data terraform_remote_state` | Built-in Data Sources > terraform_remote_state |

---

## 🌐 เทคนิคเปิดและดึงโค้ดจาก AWS Provider Docs ให้เร็วที่สุด (Speedrunning AWS Docs)
หน้าเว็บ: `https://registry.terraform.io/providers/hashicorp/aws/latest/docs`

### 1. กฎการนำทาง 3 จังหวะ (ลดเวลาหาเหลือ 10 วินาที):
1. **กดช่อง `Filter by title` ทางแถบซ้ายมือ**: พิมพ์ชื่อ Resource ที่ต้องการทันที เช่น `aws_instance`, `aws_security_group`, `aws_vpc`
2. **ระวังอย่าสับสนระหว่าง Resources กับ Data Sources**:
   - ถ้าต้องการ **"สร้างของใหม่"** ให้คลิกที่แถบ **Resources** (ไอคอนกล่องลูกบาศก์)
   - ถ้าต้องการ **"ดึงข้อมูลเดิม"** ให้คลิกที่แถบ **Data Sources** (เช่น `aws_ami`, `aws_vpc`)
3. **เลื่อนลงไปที่หัวข้อ "Example Usage" ทันที**:
   - ด้านบนสุดของทุก Resource จะมีตัวอย่างโค้ดที่รันได้จริง 100% ก๊อปปี้บล็อกนี้มาวางเป็นแม่แบบแล้วเปลี่ยนค่าตามโจทย์ได้ทันที ไม่ต้องพิมพ์เองจากศูนย์!

### 2. จุดสังเกตในหน้า Docs:
- **Argument Reference**: เลื่อนลงมาดูว่าตัวไหนมีวงเล็บ `(Required)` นั่นคือตัวที่**ขาดไม่ได้เด็ดขาด** ถ้าไม่ใส่จะ `terraform validate` ไม่ผ่าน ส่วนที่เขียน `(Optional)` คือมี default ให้แล้ว
- **Attribute Reference**: อยู่ล่างสุดของหน้า เอาไว้ดูว่า resource นั้นส่งค่าอะไรออกมาให้เราดึงไปใช้ต่อใน `outputs.tf` หรือส่งต่อให้ resource อื่น เช่น `.id`, `.arn`, `.public_ip`, `.private_ip`

### 3. ตารางทางลัด Resource สำคัญที่ออกสอบบ่อยใน AWS Provider:

| สิ่งที่โจทย์ต้องการ | ชื่อใน Docs | จุดที่ต้องระวังเป็นพิเศษ |
|---|---|---|
| หา Ubuntu AMI | `Data Sources > aws_ami` | ต้องมี `owners = ["099720109477"]` (Canonical) และบล็อก `filter { name = "name", values = [...] }` |
| สร้าง VM / EC2 | `Resources > aws_instance` | - ผูก Security Group ใน VPC ต้องใช้ `vpc_security_group_ids = [...]` (เป็น list)<br>- กำหนดขนาดดิสก์ใช้บล็อก `root_block_device { volume_size = 20 }` |
| สร้าง VPC | `Resources > aws_vpc` | ต้องการเปิด DNS ให้ใส่ `enable_dns_hostnames = true` |
| สร้าง Subnet | `Resources > aws_subnet` | ต้องผูก `vpc_id = aws_vpc.<name>.id` และ `cidr_block` |
| Firewall / Security Group | `Resources > aws_security_group` | - `cidr_blocks` ต้องมีตัว `s` และใส่เป็น List `["0.0.0.0/0"]`<br>- `protocol = "-1"` แปลว่า all protocols<br>- ใช้คู่กับ `dynamic "ingress"` |
| S3 Bucket | `Resources > aws_s3_bucket` | ใช้แค่ `bucket = "ชื่อที่ไม่ซ้ำใคร"` |
| Elastic IP | `Resources > aws_eip` | ใน v5 แนะนำให้ใส่ `domain = "vpc"` (ถ้าเวอร์ชันเก่าใช้ `vpc = true`) |

---

## 🧭 แผนที่นำทางด่วนบนเว็บ Terraform Docs (developer.hashicorp.com/terraform/docs)
ในห้องสอบเมื่อเปิดหน้านี้ แถบซ้ายมือจะแบ่งเป็น 2 เมนูหลัก คือ **Terraform Language** และ **Terraform CLI**:

```
developer.hashicorp.com/terraform/docs
│
├── 📂 Terraform Language (เมนูไวยากรณ์โค้ด .tf)
│   ├── 📁 Settings
│   │   ├── The terraform Block          → ดูโครงสร้าง required_version, required_providers
│   │   └── 📁 Backends > s3             → ตัวอย่างคอนฟิก backend "s3" พร้อม dynamodb_table
│   │
│   ├── 📁 Resources
│   │   └── 📁 Meta-Arguments
│   │       ├── count                    → การใช้ count และ count.index
│   │       ├── for_each                 → การใช้ for_each กับ map หรือ set
│   │       └── lifecycle                → การตั้ง create_before_destroy, prevent_destroy, ignore_changes
│   │
│   ├── 📁 Values (ตัวแปร)
│   │   ├── Input Variables              → เลื่อนลงไปดูหัวข้อ "Custom Condition Checks" เพื่อก๊อปบล็อก validation
│   │   ├── Local Values                 → ตัวอย่างการประกาศ locals {}
│   │   └── Output Values                → ตัวอย่าง output {} พร้อม sensitive = true
│   │
│   ├── 📁 Modules
│   │   └── Calling Child Modules        → วิธีเรียกใช้ module "<name>" { source = ... } และการดึง module.<name>.<output>
│   │
│   ├── 📁 Expressions
│   │   ├── Dynamic Blocks               → ตัวอย่าง dynamic "<name>" { for_each = ... content {} } ก๊อปมาใช้ได้เลย
│   │   ├── For Expressions              → ตัวอย่าง [for ...] และ {for ...}
│   │   └── Types and Values             → ตัวอย่างโครงสร้าง object({ ... })
│   │
│   └── 📁 Functions (มีลิสต์ทุกฟังก์ชัน)
│       ├── Collection Functions         → merge, lookup, contains, toset, flatten, zipmap
│       └── Type Conversion Functions    → try, can, tostring, tonumber
│
└── 📂 Terraform CLI (เมนูคำสั่ง Terminal)
    └── 📁 Commands
        ├── plan / apply                 → ดู Flags: -target, -replace, -refresh-only, -out
        ├── state                        → ดูไวยากรณ์ state list, state mv, state rm, state show
        └── force-unlock                 → วิธีปลด lock ด้วย terraform force-unlock <LOCK-ID>
```



---

## 1. File Structure มาตรฐานที่ควรสร้างเสมอ
```
├── terraform.tf     # เวอร์ชัน terraform, required_providers, backend
├── provider.tf      # ตั้งค่า provider (เช่น aws region, credentials)
├── variables.tf     # ประกาศ input variables ทั้งหมด
├── locals.tf        # ตัวแปรคำนวณภายใน / reusable constants
├── main.tf          # resources และ data sources หลัก
└── outputs.tf       # ค่าที่ต้องการ export ออกมา
```

---

## 2. Terraform Settings & Providers (`terraform.tf`, `provider.tf`)

```hcl
# terraform.tf
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # Backend S3 (สำหรับ Lab 5)
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "prod/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-locks" # หรือ S3 native locking ใน tf 1.10+
    encrypt        = true
  }
}
```

```hcl
# provider.tf
provider "aws" {
  region = var.aws_region

  # ทริก: สำหรับการทดสอบแบบ Offline ไม่ให้ error เรื่อง AWS credentials
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  access_key                  = "mock_key"
  secret_key                  = "mock_secret"

  default_tags {
    tags = local.common_tags
  }
}
```

---

## 3. Variables & Input Validation (`variables.tf`)

### ชนิดตัวแปรพื้นฐาน & Complex Type (Object)
```hcl
variable "environment" {
  type        = string
  description = "Target deployment environment"
  default     = "dev"

  # Validation Block (ออกสอบบ่อยมาก!)
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "The environment must be one of: dev, staging, prod."
  }
}

variable "instance_count" {
  type    = number
  default = 2

  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}

variable "db_password" {
  type      = string
  sensitive = true # ซ่อนค่าไม่ให้แสดงบน console/logs
}

# Object Type ซับซ้อน
variable "server_config" {
  type = object({
    instance_type = string
    disk_size_gb  = number
    enable_backup = bool
  })
  default = {
    instance_type = "t3.micro"
    disk_size_gb  = 20
    enable_backup = false
  }
}
```

---

## 4. Locals & Outputs (`locals.tf`, `outputs.tf`)

```hcl
# locals.tf
locals {
  name_prefix   = "${var.project_name}-${var.environment}"
  is_production = var.environment == "prod"

  # Ternary Operator: เงื่อนไข ? จริง : เท็จ
  effective_instance_type = local.is_production ? "t3.medium" : "t3.micro"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# outputs.tf
output "web_public_ips" {
  description = "Public IP addresses of web instances"
  value       = [for instance in aws_instance.web : instance.public_ip]
  # หรือใช้ splat operator: aws_instance.web[*].public_ip
}

output "db_connection_string" {
  value     = "server=${aws_instance.db.private_ip};pwd=${var.db_password}"
  sensitive = true # ถ้าอ้างอิง sensitive variable ต้องใส่ sensitive = true ใน output ด้วย
}
```

---

## 5. Resources, Data Sources & Lifecycle (`main.tf`)

```hcl
# Data Source (ดึงข้อมูลที่มีอยู่แล้วจาก AWS)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Resource
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = local.effective_instance_type

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-web"
  })

  # Lifecycle Block
  lifecycle {
    create_before_destroy = true  # สร้าง instance ใหม่ก่อนทำลายอันเดิม
    prevent_destroy       = false # ถ้าเป็น true จะป้องกันไม่ให้สั่ง terraform destroy ได้
    ignore_changes = [
      tags["LastModified"]       # ไม่อัปเดตเมื่อ tag นี้เปลี่ยนภายนอก
    ]
  }
}
```

---

## 6. Iteration: `count` vs `for_each` (หัวใจสำคัญ!)

### กฎทอง:
- ใช้ `count` เมื่อทรัพยากรเหมือนกันทุกประการ (ระบุด้วย index `0, 1, 2`) หรือใช้เปิด/ปิดทรัพยากร (`count = var.enabled ? 1 : 0`)
  - **ข้อเสียของ count:** ถ้าลบตัวกลาง list ทรัพยากรด้านหลังจะถูก recreate ทั้งหมด!
- ใช้ `for_each` เมื่อต้องการระบุตัวตนทรัพยากรด้วย Key (ระบุด้วย `map` หรือ `set(string)`)

```hcl
# 1) count กับ ternary (เปิด/ปิด)
resource "aws_eip" "nat" {
  count = local.is_production ? 1 : 0
  vpc   = true
}

# 2) for_each กับ toset (List แปลงเป็น Set)
variable "subnet_zones" {
  type    = list(string)
  default = ["ap-southeast-1a", "ap-southeast-1b"]
}

resource "aws_subnet" "public" {
  for_each          = toset(var.subnet_zones)
  vpc_id            = aws_vpc.main.id
  availability_zone = each.key # หรือ each.value
  cidr_block        = "10.0.${index(var.subnet_zones, each.key)}.0/24"

  tags = {
    Name = "subnet-${each.key}"
  }
}

# 3) for_each กับ Map
variable "users" {
  type = map(object({
    role = string
    tier = number
  }))
  default = {
    alice = { role = "admin", tier = 1 }
    bob   = { role = "dev", tier = 2 }
  }
}

resource "aws_iam_user" "staff" {
  for_each = var.users
  name     = each.key # alice, bob

  tags = {
    Role = each.value.role # admin, dev
    Tier = each.value.tier
  }
}
```

---

## 7. `for` Expressions & Splat Operator

```hcl
# 1) List Comprehension (กรองและแปลงค่า)
# เอาเฉพาะ subnets ที่เป็น public และแปลงเป็นตัวพิมพ์ใหญ่
locals {
  public_subnets = [for s in var.subnets : upper(s.name) if s.is_public == true]
}

# 2) Map Comprehension (แปลง list หรือ map ไปเป็น map ใหม่)
locals {
  instance_id_map = {
    for k, inst in aws_instance.web : k => inst.private_ip
  }
}

# 3) Splat Operator [*] (ย่อการดึง attribute เดียวจาก list of resources)
# aws_instance.web[*].id เทียบเท่ากับ [for i in aws_instance.web : i.id]
```

---

## 8. Dynamic Blocks (สำหรับ Nested Blocks ซ้ำๆ)

ใช้กับบล็อกที่อยู่ข้างใน resource เช่น `ingress`, `egress` ใน Security Group หรือ `setting` ใน Elastic Beanstalk:

```hcl
variable "ingress_rules" {
  type = list(object({
    port        = number
    description = string
    protocol    = string
  }))
  default = [
    { port = 80, description = "HTTP", protocol = "tcp" },
    { port = 443, description = "HTTPS", protocol = "tcp" },
    { port = 22, description = "SSH", protocol = "tcp" }
  ]
}

resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.main.id

  # Dynamic Block
  dynamic "ingress" {
    for_each = var.ingress_rules
    iterator = rule # ถ้าไม่ระบุ iterator จะใช้ชื่อบล็อกเป็นตัวอ้างอิง (ingress.value)
    content {
      description = rule.value.description
      from_port   = rule.value.port
      to_port     = rule.value.port
      protocol    = rule.value.protocol
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

---

## 9. Modules (สร้างเอง & เรียกใช้)

```hcl
# การเรียกใช้ Child Module
module "my_vpc" {
  source = "./modules/vpc" # หรือ Registry source เช่น "terraform-aws-modules/vpc/aws"

  # ส่งตัวแปร Input เข้าไป
  vpc_cidr   = "10.0.0.0/16"
  env_name   = var.environment
  az_list    = ["ap-southeast-1a", "ap-southeast-1b"]

  tags = local.common_tags
}

# การอ้างอิงค่า Output จาก Child Module
resource "aws_instance" "web" {
  subnet_id = module.my_vpc.public_subnet_ids[0] # module.<NAME>.<OUTPUT_NAME>
}
```

---

## 10. Built-in Functions สำคัญที่ต้องรู้

| ฟังก์ชัน | ตัวอย่างการใช้งาน | ผลลัพธ์ |
|---|---|---|
| `lookup(map, key, default)` | `lookup({a=1}, "b", 99)` | `99` |
| `merge(map1, map2)` | `merge({a=1}, {b=2})` | `{a=1, b=2}` |
| `contains(list, val)` | `contains(["a", "b"], "a")` | `true` |
| `toset(list)` | `toset(["a", "b", "a"])` | `["a", "b"]` |
| `flatten(list_of_lists)`| `flatten([[1, 2], [3]])` | `[1, 2, 3]` |
| `zipmap(keys, vals)` | `zipmap(["a", "b"], [1, 2])` | `{a=1, b=2}` |
| `try(expr, fallback)` | `try(tonumber("abc"), 0)` | `0` (ไม่แครช) |
| `can(expr)` | `can(regex("^[0-9]+$", "123"))` | `true` (คืน bool) |
| `coalesce(val1, val2)` | `coalesce("", null, "default")` | `"default"` |
| `format(fmt, ...)` | `format("web-%02d", 3)` | `"web-03"` |

---

## 11. State Management CLI Commands (Lab 4 & 5)

| คำสั่ง | คำอธิบายและตัวอย่างการใช้งาน |
|---|---|
| `terraform state list` | แสดง Resource address ทั้งหมดใน state |
| `terraform state show <addr>` | ดูรายละเอียดของ Resource เช่น `terraform state show aws_instance.web[0]` |
| `terraform state mv <src> <dst>` | ย้ายชื่อ/ย้ายเข้า module เช่น `terraform state mv aws_instance.web module.compute.aws_instance.web` |
| `terraform state rm <addr>` | ลบ resource ออกจาก state (ไม่ทำลาย resource จริงบน cloud) |
| `terraform import <addr> <id>` | นำ resource ที่มีอยู่แล้วเข้า state เช่น `terraform import aws_s3_bucket.bucket my-bucket-name` |
| `terraform plan -target=<addr>` | plan เฉพาะ resource ที่ระบุ (ควรระวัง dependency) |
| `terraform apply -replace=<addr>` | บังคับทำลายและสร้าง resource นั้นใหม่ (แทนที่ `taint` เก่า) |
| `terraform plan -out=tfplan` | บันทึก execution plan ลงไฟล์เพื่อนำไป apply ใน CI/CD |
| `terraform apply tfplan` | apply จากไฟล์ plan ที่เซฟไว้ |

---

## 12. Cross-Project State Sharing (`terraform_remote_state`)

```hcl
data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "my-company-terraform-states"
    key    = "network/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

# ดึงค่า output ของโปรเจกต์ network มาใช้งาน:
resource "aws_instance" "app" {
  subnet_id = data.terraform_remote_state.network.outputs.public_subnet_id
}
```
