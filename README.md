# Terraform Lifecycle

Terraform lifecycle is a block or rule that controls how Terraform handles resource changes during plan and apply operations. It provides rules for how specific resources should be managed throughout their lifecycle, giving you greater control over the create, update, and destroy operations. These lifecycle rules allow you to customize **how Terraform interacts with your infrastructure** during apply and destroy operations.

## **Terraform Lifecycle Meta-Arguments**
Terraform provides the following lifecycle meta-arguments:

1. **`create_before_destroy`** 
    - Ensures a new resource is created before destroying the old one.
    - Useful for replacing resources without downtime.
2. **`prevent_destroy`**
    - Prevents Terraform from accidentally destroying a resource.
    - Useful for critical infrastructure like databases.
3. **`ignore_changes`** 
    - Ignores specific changes in a resource to prevent unnecessary updates.
    - Useful for fields modified externally (e.g., auto-scaling).
4. **`replace_triggered_by`**  _(Terraform 1.2+)_
    - Forces a resource to be replaced if another resource changes.
    - Useful when dependencies require full recreation.
# **📌 Terraform Lifecycle Arguments Practical Guide**
## **🛠️ Lifecycle Arguments Covered**
| Lifecycle Argument | Effect |
| ----- | ----- |
| `create_before_destroy`  | <p>Creates a new resource </p><p> before destroying the old one (avoiding downtime).</p> |
| `prevent_destroy`  | Prevents accidental deletion of critical resources. |
| `ignore_changes`  | Ignores specific attribute changes to avoid unnecessary updates. |
| `replace_triggered_by`  | Forces replacement of a resource when a related resource changes. |
---

## **1️⃣ **`create_before_destroy`** – Ensuring Zero Downtime**
### **🔹 What Happens Without It?**
Terraform **destroys the old resource first**, then creates a new one. This causes **downtime**.

### **🔹 What Happens With **`create_before_destroy`**?**
Terraform **creates a new resource first**, then destroys the old one. This avoids downtime.

---

### **📝 Terraform Code**
```hcl
hclCopyEditprovider "aws" {
  region = "us-east-1"
}

# ✅ Create an EC2 instance that gets replaced without downtime
resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0"  # Example Ubuntu AMI
  instance_type = "t2.micro"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "Web Server"
  }
}
```
### **🚀 Steps to Test**
1. **Run Terraform**:
```
sh

terraform init
terraform apply -auto-approve
```
✅ Creates an EC2 instance.



1. **Modify the instance type in **`main.tf`** :
 Change:
```
instance_type = "t2.micro"
```
To:

```
instance_type = "t2.small"`
```




1. **Apply Again**:
```
terraform apply -auto-approve
```
✅ **New EC2 instance is created BEFORE the old one is deleted.** No downtime!



---

![image](https://github.com/user-attachments/assets/f79efed9-ab99-448e-9e71-030869176592)

![image](https://github.com/user-attachments/assets/42f4436c-8b79-49f8-bd22-a66794169edd)



## **2️⃣ **`prevent_destroy`** – Prevent Accidental Deletion**
### **🔹 What Happens Without It?**
Running `terraform destroy` **removes the resource permanently**.

### **🔹 What Happens With **`**prevent_destroy**`**?**
Terraform **prevents deletion** and gives an error instead of destroying the resource.

---

### **📝 Terraform Code**
```hcl
hclCopyEditprovider "aws" {
  region = "us-east-1"
}

# ✅ Protect this S3 bucket from accidental deletion
resource "aws_s3_bucket" "secure_bucket" {
  bucket = "my-secure-bucket-12345"

  lifecycle {
    prevent_destroy = true
  }
}
```
### **🚀 Steps to Test**
1. **Run Terraform**:
```
terraform init
terraform apply -auto-approve
```
✅ Creates an **S3 bucket**.


1. **Try to Destroy**:
```
terraform destroy -auto-approve
```
❌ Terraform **throws an error** because `prevent_destroy`  is enabled.

---

![image](https://github.com/user-attachments/assets/f8b35b5b-3808-4451-be23-a3d4df896d09)


## **3️⃣ **`ignore_changes`** – Ignore External Modifications**
### **🔹 What Happens Without It?**
If an attribute is changed outside Terraform (e.g., in AWS Console), Terraform **detects the drift** and reverts the change.

### **🔹 What Happens With **`ignore_changes`**?**
Terraform **ignores** changes to the specified attribute.

---

### **📝 Terraform Code**
```hcl
hclCopyEditprovider "aws" {
  region = "us-east-1"
}

# ✅ Ignore changes to instance type (Terraform won’t override manual updates)
resource "aws_instance" "dev_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  lifecycle {
    ignore_changes = [instance_type]
  }

  tags = {
    Name = "Dev Server"
  }
}
```
### **🚀 Steps to Test**
1. **Apply Terraform**:
```
terraform init
terraform apply -auto-approve
```
✅ Creates an **EC2 instance**.



1. **Manually Change Instance Type in AWS Console**:
 Change **instance type** from `t2.micro`  → `t2.medium` .
2. **Re-run Terraform Apply**:
```
terraform apply --auto-approve
```
✅ Terraform **does not revert** the manual change.

![image](https://github.com/user-attachments/assets/6ef7d2a0-bc10-4d5a-b705-6b05cb82b0af)

![image](https://github.com/user-attachments/assets/f31fc6f3-d43f-4a64-984f-08549a81d60f)



## **4️⃣ **`replace_triggered_by`** – Force Replacement When Another Resource Changes**
Note: The `replace_triggered_by` argument was **introduced in Terraform v1.2.0**

### **🔹 What Happens Without It?**
Terraform **does not automatically replace a resource** when a dependency (e.g., security group) changes.

### **🔹 What Happens With **`replace_triggered_by`**?**
Terraform **replaces the resource** whenever the dependency changes.

---

### **📝 Terraform Code**
```hcl
hclCopyEditprovider "aws" {
  region = "us-east-1"
}

# ✅ Security Group
resource "aws_security_group" "web_sg" {
  name        = "web-security-group"
  description = "Security group for web server"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ✅ EC2 instance that REPLACES if security group changes
resource "aws_instance" "app_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  lifecycle {
    replace_triggered_by = [aws_security_group.web_sg]
  }

  tags = {
    Name = "App Server"
  }
}
```
### **🚀 Steps to Test**
1. **Apply Terraform**:
```
terraform init
terraform apply -auto-approve
```
✅ Creates an **EC2 instance**.

1. **Modify Security Group Rules in **`main.tf`** :
Add **SSH access**:
```
ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
```
1. **Apply Again**:
```
terraform apply --auto-approve
```
✅ **Terraform destroys and recreates the EC2 instance**.

![image](https://github.com/user-attachments/assets/7a0c77d2-1b8a-459d-a083-ce3d2df9502d)

![image](https://github.com/user-attachments/assets/9341ea78-dba1-4cb8-af14-737aab3cf09b)



# **🎯 Summary of Terraform Lifecycle Arguments**
| Lifecycle Argument | Effect |
| ----- | ----- |
| `create_before_destroy`  | Creates a new resource before destroying the old one (zero downtime). |
| `prevent_destroy`  | `Prevents accidental deletion. |
| `ignore_changes`  | Ignores specific attribute changes to avoid unnecessary updates. |
| `replace_triggered_by`  | Forces replacement when a related resource changes. |
---

## **🚀 Next Steps**
- Copy the above **Terraform templates** and **test them yourself**.
- Try **removing the lifecycle blocks** and compare behaviors.
- Modify and experiment with **different scenarios**.



