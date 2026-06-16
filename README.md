# Distributed Systems Architecture - Core Practical Tasks

This repository contains the practical implementation of key distributed systems patterns designed to improve client-side resiliency, prevent server-side cascading failures, and provide a seamless user experience. 

---

## 🚀 Task 1: Client Jittered Backoff & Jitter Lock Shield (Advanced)

### 📌 Core Architectural Concepts

When a distributed service experiences degraded performance or a temporary outage, naive clients that aggressively retry failed requests can inadvertently cause a **Thundering Herd Problem**, generating massive traffic spikes that prevent the server from recovering. 

To mitigate this, this project implements three distributed structural patterns:

#### 1. Exponential Backoff with Full Jitter
Instead of retrying immediately or at fixed intervals, the client backs off exponentially based on the number of failed attempts. To break the synchronization of multiple concurrent clients, a randomized noise factor (**Jitter**) is introduced. 
The mathematical boundary for the wait time is calculated as:

$$Wait\ Time = Random(0, Base \times 2^{attempt})$$

* **Base Delay:** $1.5 \text{ seconds}$
* **Max Attempts:** $4$
* This flattens the concurrent request spikes (**Flattening the Spikes**) across the time domain, distributing the load smoothly on the pharmaceutical/order backend.

#### 2. Network Optimistic UI
To maintain an optimal user experience under high latency or intermittent network connectivity, the application updates the local state **immediately** upon user interaction, assuming a $100\%$ success rate. 
* **Rollback Mechanism:** If the underlying distributed network layer fails permanently after the maximum number of jittered retries, a strict state rollback (**Conflict Resolution**) is triggered, restoring the UI to its correct historical state to maintain **Eventual Consistency**.

#### 3. Jitter Lock Shield
To prevent **Race Conditions** where a user might trigger multiple mutations on the same item while a previous request is still undergoing its background backoff-retry loop, a reactive concurrency lock (**Lock Shield**) is introduced via **GetX**. It guarantees data isolation until the state is safely synchronized or rolled back.

---

### 🖥️ Implementation Specifications (Flutter & GetX)

* **State Management:** Driven by reactive programming (`RxList`, `RxMap`) via **GetX** for immediate UI synchronization.
* **Distributed Simulation Terminal:** Built an in-app real-time terminal logging subsystem that precisely documents timing, exponential step increments, jitter intervals, locking mechanisms, and rollback triggers.
* **Fault Simulation:** Implemented a non-deterministic RPC mock layer with a $75\%$ failure rate to rigorously test the client-side resiliency logic under extreme network stress.
* 
### 📸 Execution & Visual Evidence

* <p align="center">
  <img src="Images/img.png" width="31%" alt="Optimistic UI Launch" />
  <img src="Images/img_1.png" width="31%" alt="Jittered Backoff Log" />
  <img src="Images/img_2.png" width="31%" alt="Rollback Mechanism" />
</p>

### 🖥️ Real-Time Execution Trace Analysis (Live Logs)

Below is an authentic execution trace captured from the Flutter development terminal, showcasing the system's asynchronous handling of multiple concurrent pharmaceutical orders under network stress:

```text
I/flutter (31981): DISTRIBUTED_LOG: [Optimistic UI]: The interface was updated immediately upon request Panadol Extra
I/flutter (31981): DISTRIBUTED_LOG: 📡 Demand 1781583050646: Attempt number (1) from (4)...
I/flutter (31981): DISTRIBUTED_LOG: [Optimistic UI]: The interface was updated immediately upon request Lipitor 20mg
I/flutter (31981): DISTRIBUTED_LOG: 📡 Demand 1781583050848: Attempt number (1) from (4)...
I/flutter (31981): DISTRIBUTED_LOG: [Optimistic UI]: The interface was updated immediately upon request Lipitor 20mg
I/flutter (31981): DISTRIBUTED_LOG: 📡 Demand 1781583051013: Attempt number (1) from (4)...
I/flutter (31981): DISTRIBUTED_LOG: [Optimistic UI]: The interface was updated immediately upon request Panadol Extra
I/flutter (31981): DISTRIBUTED_LOG: ❌ [Rollback]: All attempts failed. The request status has been rolled back. 1781583051651

---


