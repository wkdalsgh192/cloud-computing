# cloud-computing - Secure Multi-AZ AWS Architecture

## Overview

This project demonstrates a production-grade, highly available, and secure AWS network architecture designed to host a standard three-tier web application.
The system follows AWS Well-Architected security best practices, including network isolation, least-privilege access, and defense in depth.

The architecture is deployed inside a custom VPC with public, private application, and private data subnets across multiple Availability Zones (AZs).

---
## Architecture Overview

```mermaid
flowchart TB
    User[User]
    Internet[Internet]

    subgraph AWS[AWS Cloud]
        subgraph VPC[VPC 10.0.0.0/16]

            subgraph PublicSubnets[Public Subnets - Multi AZ]
                ALB[Application Load Balancer]
                Bastion[Bastion Host]
                NAT[NAT Gateway]
            end

            subgraph AppSubnets[Private App Subnets]
                App[Application Servers]
            end

            subgraph DataSubnets[Private Data Subnets]
                DB[(Database)]
            end
        end
    end

    User --> Internet --> ALB
    ALB --> App
    App --> DB

    Admin --> Bastion
    Bastion --> App
    App --> NAT --> Internet

## Network Traffic Flow
```mermaid
flowchart LR
    Internet -->|80/443| ALB
    ALB -->|443 only| App
    App -->|DB Port| DB

    Bastion -->|SSH 22| App

    classDef public fill:#E3F2FD,stroke:#1E88E5
    classDef app fill:#E8F5E9,stroke:#43A047
    classDef data fill:#FCE4EC,stroke:#C2185B

    class ALB,Bastion public
    class App app
    class DB data

## Multi-AZ Subnet Design

```mermaid
flowchart TB
    subgraph AZA[AZ-a]
        PubA[Public Subnet A]
        AppA[Private App Subnet A]
        DataA[Private Data Subnet A]
    end

    subgraph AZB[AZ-b]
        PubB[Public Subnet B]
        AppB[Private App Subnet B]
        DataB[Private Data Subnet B]
    end

    ALB[ALB] --- PubA
    ALB --- PubB

    PubA --> AppA --> DataA
    PubB --> AppB --> DataB

## Request & Access Sequence

```mermaid
sequenceDiagram
    participant User
    participant ALB
    participant App
    participant DB
    participant Admin
    participant Bastion

    User->>ALB: HTTPS request
    ALB->>App: Forward request
    App->>DB: Query
    DB-->>App: Response
    App-->>ALB: Response
    ALB-->>User: HTTPS response

    Admin->>Bastion: SSH
    Bastion->>App: SSH

## Security Configuration

### 1. Network Isolation

- The architecture is deployed inside a dedicated **VPC (10.0.0.0/16)**.
- Subnets are separated by function and trust level:
  - **Public Subnets**: Load balancer, bastion host, NAT gateway
  - **Private App Subnets**: Application servers
  - **Private Data Subnets**: Database
- Private subnets **do not allow direct internet access**, reducing the attack surface.

---

### 2. Security Groups (Stateful Access Control)

Security groups enforce **least-privilege communication between tiers**:

| Component            | Allowed Inbound Traffic | Source              |
|----------------------|-------------------------|---------------------|
| Load Balancer        | HTTP / HTTPS            | Internet            |
| Application Servers  | HTTPS                   | Load Balancer       |
| Database             | Database Port           | Application Servers |
| Bastion Host         | SSH                     | Admin IP only       |

Key principles:
- No direct internet access to application or database layers
- Tier-to-tier access only on required ports
- Security groups reference trusted sources only

---

### 3. Network ACLs (Stateless Protection)

- Network ACLs provide an additional layer of defense at the subnet level.
- Separate ACLs are applied for:
  - Public subnets
  - Private application subnets
  - Private data subnets
- Only explicitly allowed traffic is permitted; all other traffic is denied.

---

### 4. Bastion Host Access

- Administrative access to private instances is only possible through the **bastion host**. 
- SSH access is restricted to approved administrator IP addresses. (Currently open to all for demo)
- Application servers do not accept direct SSH connections from the internet.

---

### 5. Outbound Internet Access via NAT Gateway

- Private subnets require outbound access for updates and external services.
- A **NAT Gateway** enables outbound internet connectivity without exposing private resources.
- Inbound connections from the internet remain blocked.
