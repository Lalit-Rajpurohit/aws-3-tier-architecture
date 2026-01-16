# AWS High-Availability 3-Tier Web Architecture

## 📋 Project Overview
This project demonstrates a production-ready **3-Tier Web Application** deployed on AWS. It leverages a highly available, fault-tolerant architecture using **Amazon EC2 Auto Scaling**, **Application Load Balancer**, and **Amazon RDS Multi-AZ**.

The infrastructure follows the **AWS Well-Architected Framework**, prioritizing security (private subnets, least privilege) and reliability (multi-AZ redundancy).

## 🏗️ Architecture
![Architecture Diagram](architecture-diagram.png)

### **Tier 1: Presentation (Public)**
- **Application Load Balancer (ALB):** Distributes incoming HTTPS traffic across multiple Availability Zones.
- **NAT Gateway:** Allows outbound internet access for private instances without exposing them to inbound traffic.

### **Tier 2: Application (Private)**
- **Auto Scaling Group (ASG):** Manages EC2 instances across 2 AZs.
- **Launch Template:** Defines immutable infrastructure configuration (AMI, Instance Type, User Data).
- **Security:** Instances reside in private subnets with no public IPs. SSH access is disabled in favor of **AWS Systems Manager (SSM)**.

### **Tier 3: Database (Private)**
- **Amazon RDS (Multi-AZ):** Managed Relational Database Service (MySQL/PostgreSQL) with synchronous replication to a standby instance.
- **Secrets Manager:** Rotates and stores database credentials securely; application retrieves them programmatically at runtime.

---

## 🛠️ Technology Stack
- **Cloud Provider:** AWS (Amazon Web Services)
- **Compute:** Amazon EC2 (t3.micro), Auto Scaling Groups
- **Networking:** VPC, Public/Private Subnets, Route Tables, NAT Gateway
- **Database:** Amazon RDS (Multi-AZ)
- **Security:** IAM Roles, Security Groups, AWS Secrets Manager
- **Load Balancing:** Application Load Balancer (ALB)

---

## 🚀 Deployment Steps (Summary)

### Phase 1: Networking
1. Create VPC `prod-vpc-main` (10.0.0.0/16).
2. Provision 2 Public Subnets and 4 Private Subnets (App & DB) across 2 AZs.
3. Configure Internet Gateway and NAT Gateway with correct Route Tables.

### Phase 2: Security
1. Create Security Groups chaining: `ALB` -> `App` -> `DB`.
2. Create IAM Role with `AmazonSSMManagedInstanceCore`.

### Phase 3: Database
1. Deploy RDS Multi-AZ in private subnets.
2. Store credentials in AWS Secrets Manager.

### Phase 4: Application
1. Create Launch Template with `user-data.sh`.
2. Deploy Auto Scaling Group (Min: 2, Max: 4).

### Phase 5: Routing
1. Configure ALB with Target Groups.
2. Set up HTTP-to-HTTPS redirection.

---

## 🧪 Testing & Validation
- **Resilience:** Terminated random EC2 instances; ASG auto-healed within 60 seconds.
- **Failover:** Rebooted RDS with failover; application remained responsive.
- **Security:** Verified no direct SSH access; database strictly isolated.
