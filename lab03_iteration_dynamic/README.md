# 🧪 Lab 03: Expressions, Iteration (`count` vs `for_each`), `for` Expressions & `dynamic` Blocks

## 🎯 วัตถุประสงค์การเรียนรู้
1. ทดสอบ built-in functions (`lookup`, `merge`, `contains`, `toset`, `try`, `can`) ด้วย `terraform console`
2. สร้าง Multiple Resources ด้วย `count` พร้อมอ้างอิง `count.index`
3. สร้าง Multiple Resources ด้วย `for_each` โดยใช้ทั้ง `toset(list)` และ `map` พร้อมอ้างอิง `each.key`, `each.value`
4. แปลงข้อมูลด้วย `for` expressions (ทั้งแบบ list comprehension และ map comprehension พร้อมเงื่อนไข `if`)
5. สร้าง Nested Blocks อัตโนมัติด้วย `dynamic` block (เช่น Security Group ingress rules)

---

## 📝 โจทย์ที่ต้องลงมือทำ (เริ่มจากไฟล์ว่าง)

### 1. `variables.tf`
- `environment` (type: string, default: "dev")
- `subnet_cidrs` (type: list(string), default: `["10.0.1.0/24", "10.0.2.0/24"]`)
- `web_servers` (type: map(object({
    instance_type = string
    is_public     = bool
  }))):
  Default มี 2 ตัว:
  ```hcl
  {
    "frontend" = { instance_type = "t3.micro", is_public = true }
    "backend"  = { instance_type = "t3.small", is_public = false }
  }
  ```
- `firewall_rules` (type: list(object({
    port        = number
    description = string
    protocol    = string
  }))):
  Default เป็น list ของ ports: 80 (HTTP), 443 (HTTPS), 22 (SSH)

### 2. `main.tf`
- **VPC Resource**: สร้าง `aws_vpc "main"` (`cidr_block = "10.0.0.0/16"`)
- **Subnets with `for_each`**:
  - สร้าง `aws_subnet "subnets"` โดยใช้ `for_each = toset(var.subnet_cidrs)`
  - ผูก `vpc_id = aws_vpc.main.id`
  - `cidr_block = each.value`
- **Security Group with `dynamic` block**:
  - สร้าง `aws_security_group "app_sg"`
  - มีบล็อก `dynamic "ingress"` ที่วนลูปตาม `var.firewall_rules`:
    - `from_port = ingress.value.port`
    - `to_port = ingress.value.port`
    - `protocol = ingress.value.protocol`
    - `description = ingress.value.description`
    - `cidr_blocks = ["0.0.0.0/0"]`
  - มีบล็อก `egress` อนุญาต all traffic (`from_port = 0`, `to_port = 0`, `protocol = "-1"`, `cidr_blocks = ["0.0.0.0/0"]`)
- **EC2 with `for_each` (Map)**:
  - ใช้ data source `aws_ami`
  - สร้าง `aws_instance "servers"` โดยใช้ `for_each = var.web_servers`
  - `instance_type = each.value.instance_type`
  - `tags = { Name = "server-${each.key}", Public = tostring(each.value.is_public) }`

### 3. `outputs.tf`
- **`for` List comprehension**: ดึงเฉพาะชื่อ server (keys) ที่มี `is_public == true`:
  - `[for k, v in var.web_servers : k if v.is_public]`
- **`for` Map comprehension**: สร้าง Map คู่ระหว่าง `server_name => instance_arn`:
  - `{ for k, inst in aws_instance.servers : k => inst.arn }`

---

## 🔍 คำสั่งตรวจสอบผลลัพธ์
```bash
terraform fmt -check
terraform init
terraform validate
```
และสามารถทดสอบรัน `terraform console` เพื่อพิมพ์คำนวณนิพจน์ต่างๆ เช่น:
```hcl
> [for k, v in var.web_servers : upper(k)]
> {for k, v in var.web_servers : k => v.instance_type}
```
