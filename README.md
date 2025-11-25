# Salesforce Enterprise Order Management Architecture

[![Salesforce](https://img.shields.io/badge/Platform-Salesforce-blue.svg)](https://developer.salesforce.com/) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)]()

## 📖 Overview
This repository serves as a **Reference Architecture** for a scalable, enterprise-grade Salesforce application. It moves beyond standard "Trigger Logic" to implement a robust **MVCS (Model-View-Controller-Service)** architecture.

The project simulates a high-volume **Order Processing Engine** that handles validation, recursion control, and dynamic pricing algorithms without tight coupling.

### 🎯 Objectives
* Demonstrate **Separation of Concerns (SoC)** between Triggers, Domain logic, and Business Services.
* Implement **GoF Design Patterns** (Strategy, Factory, Template Method) in Apex.
* Adhere to **SOLID Principles**, specifically the Open/Closed Principle and Interface Segregation.
* Showcase **Enterprise Best Practices** (Recursion Guards, Error Handling, Security).

---

## 🏗 Architectural Design

### The Execution Flow
The system utilizes a **Trigger Framework** to route execution. The logic flows from the Context-Aware layers (Trigger/Domain) to the Context-Agnostic layers (Service/Strategy).

```mermaid
sequenceDiagram
    participant SF as Salesforce Platform
    participant Trig as OrderTrigger
    participant Disp as TriggerDispatcher
    participant Dom as OrderDomain (Handler)
    participant Svc as OrderService
    participant Rec as RecursionCheck
    participant Factory as PricingStrategyFactory

    SF->>Trig: Fire Trigger (After Update)
    Trig->>Disp: run(new OrderDomain())
    Note over Disp: Detects Context (AfterUpdate)
    Disp->>Dom: afterUpdate(records)
    Dom->>Svc: calculatePricing(records)
    
    loop For Each Record
        Svc->>Rec: isRecordProcessed(Id)?
        alt Is New Context
            Rec-->>Svc: False (Proceed)
            Svc->>Factory: getStrategy(AccountType)
            Factory-->>Svc: Returns VIP/Standard Strategy
            Svc->>Svc: Execute Calculation
        else Recursion Detected
            Rec-->>Svc: True (Skip)
        end
    end
    
    Svc->>SF: Update Records (DML)
````

### Layer Breakdown

| Layer | Class | Responsibility |
| :--- | :--- | :--- |
| **Interface** | `ITriggerHandler` | Defines the contract for all domain handlers. |
| **Dispatcher** | `TriggerDispatcher` | Routes Trigger context (Insert/Update) to the correct method. |
| **Domain** | `OrderDomain` | **"The Waiter"**. Handles validation and dirty data. Delegates to Service. |
| **Service** | `OrderService` | **"The Chef"**. Handles pure business logic and database orchestration. |
| **Pattern** | `IPricingStrategy` | **Strategy Pattern**. Interface for dynamic algorithms. |

-----

## 🛠 Key Technical Implementations

### 1\. Lean Trigger Framework (Virtual Inheritance)

Instead of forcing the Domain class to implement every method of the `ITriggerHandler` interface, I utilized a **Virtual Base Class** (`TriggerHandler`).

  * **Why?** This adheres to the **Interface Segregation Principle**. The `OrderDomain` only overrides the methods it needs (e.g., `afterUpdate`), keeping the code clean and readable.

### 2\. Strategy & Factory Pattern

To avoid complex `If/Else` chains for pricing logic (e.g., VIP vs. Standard vs. Employee), I implemented the **Strategy Pattern**.

  * **Why?** This adheres to the **Open/Closed Principle**. We can add a new "Black Friday" pricing strategy without modifying the existing, tested Service code.

### 3\. Recursion Guard

An `OrderService` update often triggers the `OrderTrigger` again, leading to infinite loops and `Stack Depth` exceptions.

  * **Solution:** Implemented `RecursionCheck.cls` using a `static Set<Id>`.
  * **Benefit:** Ensures a record is processed exactly once per transaction context.

### 4\. Security & Sharing

  * **`inherited sharing`**: Used on Utility/Service classes (`TriggerDispatcher`, `PricingStrategyFactory`) to dynamically respect the caller's security context (e.g., LWC vs. Batch).
  * **`with sharing`**: Enforced on Logic classes (`VipPricingStrategy`) to ensure Record-Level Security is respected.

-----

## 📂 Project Structure

```bash
force-app/main/default/
├── classes/
│   ├── framework/
│   │   ├── ITriggerHandler.cls       # Interface Contract
│   │   ├── TriggerHandler.cls        # Virtual Base Class
│   │   └── TriggerDispatcher.cls     # Logic Router
│   ├── domain/
│   │   └── OrderDomain.cls           # Validation & Delegation
│   ├── service/
│   │   └── OrderService.cls          # Business Logic
│   ├── patterns/
│   │   ├── IPricingStrategy.cls      # Strategy Interface
│   │   ├── PricingStrategyFactory.cls# Factory implementation
│   │   ├── VipPricingStrategy.cls    # Concrete Algorithm
│   │   └── StandardPricingStrategy.cls
│   └── utils/
│       ├── Logger.cls                # Error Handling Wrapper
│       └── RecursionCheck.cls        # Loop Prevention
└── triggers/
    └── OrderTrigger.trigger          # One-line Trigger
```

-----

## 🚀 Deployment & Testing

### Prerequisite

  * Salesforce CLI (SFDX) installed.
  * Visual Studio Code.

### Deploy to Scratch Org / Sandbox

```bash
# 1. Clone the repository
git clone [https://github.com/k4zludk3/sfdc-enterprise-om.git](https://github.com/k4zludk3/sfdc-enterprise-om.git)

# 2. Deploy source
sfdx force:source:deploy -p force-app
```

### Verify Logic (Anonymous Apex)

Run the following script in the Developer Console to verify the Strategy Pattern and Recursion Guard:

```java
// Create a VIP Order
Order vipOrder = new Order(
    AccountId = '001...', // Add valid Account ID
    Status = 'Draft',
    EffectiveDate = Date.today(),
    Type = 'VIP' // triggers VipPricingStrategy
);
insert vipOrder;

// Activate to trigger the Service Layer logic
vipOrder.Status = 'Activated';
update vipOrder;

// Verify Result
Order res = [SELECT Description FROM Order WHERE Id = :vipOrder.Id];
System.debug(res.Description); 
// Expected Output: "Final Price: 85.00" (15% Discount applied)
```

-----

### 👤 Author

**Lucas Duque**

  * Senior Salesforce Developer | Architect Mindset
  * Focus: Scalable Apex, LWC, Enterprise Patterns
  * [LinkedIn Profile](https://www.linkedin.com/in/lucasduque97/)

<!-- end list -->

```
```