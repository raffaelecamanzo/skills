# Architecture Document Template

Use this template for the output file `docs/specs/architecture.md`. Adapt sections based on relevance — omit sections that genuinely don't apply. Every architectural decision must trace to an SRS requirement, a user answer, or an explicit assumption.

```markdown
# Architecture Specification — [System Name]

> Source SRS: docs/specs/software-spec.md
> Author: Software Architect (AI-assisted)
> Date: [generation date]
> Status: Draft — pending stakeholder review
> Version: 1.0

## 1. Executive Summary

[3-5 sentences: system purpose, architectural style chosen, key technology decisions, and the most critical quality attribute strategies.]

## 2. Architectural Drivers

### 2.1 Key Quality Attributes

[Quality attributes from SRS NFRs that most significantly shape the architecture. These are the "why" behind every structural decision.]

| ID | Quality Attribute | SRS Source | Architectural Influence |
|----|-------------------|------------|------------------------|
| [NFR-XX-##] | [e.g., Availability > 99.9%] | [SRS section] | [How this shapes the architecture] |

### 2.2 Business Constraints

- [Constraint — source: budget/timeline/team/regulatory]

### 2.3 Technical Constraints

- [Constraint — source: legacy system/platform mandate/licensing]

### 2.4 Assumptions

| ID | Assumption | Source | Impact if Wrong | Validated? |
|----|-----------|--------|----------------|------------|
| AA-01 | [Assumption statement] | [User answer / SRS / inferred] | [What changes if this is wrong] | Yes / No |

---

## 3. Architectural Style & Patterns

### 3.1 Chosen Style

**Style:** [e.g., Modular monolith, Microservices, Serverless, Event-driven, Hybrid]

**Rationale:** [Why this style — linked to quality attributes and constraints]

**Trade-offs accepted:**
- [Positive trade-off: what we gain]
- [Negative trade-off: what we give up and why it's acceptable]

### 3.2 Key Patterns Applied

| Pattern | Where Applied | Problem It Solves | Reference |
|---------|--------------|-------------------|-----------|
| [e.g., Circuit Breaker] | [Component/boundary] | [Failure isolation for...] | [ADR-##] |

---

## 4. System Decomposition

### 4.1 High-Level Component Map

| Component | Responsibility | Interfaces | Dependencies |
|-----------|---------------|------------|--------------|
| [Component name] | [Single-responsibility statement] | [APIs exposed] | [Other components it depends on] |

### 4.2 Communication Patterns

| From | To | Pattern | Protocol | Failure Handling |
|------|----|---------|----------|-----------------|
| [Component A] | [Component B] | Sync / Async / Event | [HTTP/gRPC/AMQP/...] | [Retry/Circuit break/DLQ/...] |

### 4.3 Boundary Definitions

[Domain boundaries, data ownership, and the rationale for where the lines are drawn.]

---

## 5. Technology Stack

### 5.1 Languages & Frameworks

| Category | Choice | Rationale | Alternatives Considered |
|----------|--------|-----------|------------------------|
| [Backend language] | [e.g., Go 1.22] | [Performance, team skill, ecosystem] | [Node.js, Rust — why not] |

### 5.2 Databases & Storage

| Use Case | Technology | Model | Rationale |
|----------|-----------|-------|-----------|
| [Primary data] | [e.g., PostgreSQL 16] | Relational | [ACID, query flexibility, team familiarity] |

### 5.3 Infrastructure & Cloud Services

| Service | Provider | Purpose | Rationale |
|---------|----------|---------|-----------|
| [Compute] | [e.g., AWS ECS] | Container orchestration | [Cost, team experience, existing infra] |

### 5.4 Development & Build Tools

| Category | Choice | Rationale |
|----------|--------|-----------|
| [Build system] | [e.g., Gradle] | [Speed, ecosystem, multi-module support] |

---

## 6. Data Architecture

### 6.1 Storage Strategy

[Overview of data storage approach — polyglot persistence rationale, or single-database rationale.]

### 6.2 Data Flow Overview

[How data moves through the system — ingestion, processing, storage, retrieval, archival.]

### 6.3 Consistency & Replication

| Data Domain | Consistency Model | Rationale | SRS Requirement |
|-------------|------------------|-----------|-----------------|
| [e.g., User accounts] | Strong | [Financial/regulatory requirement] | [NFR-XX-##] |

### 6.4 Migration Plan

[If applicable — how existing data migrates into the new architecture. Schema evolution strategy.]

---

## 7. Integration Architecture

### 7.1 API Design Approach

**Style:** [REST / GraphQL / gRPC / Hybrid]
**Versioning strategy:** [URL path / Header / Content negotiation]
**Documentation:** [OpenAPI / GraphQL schema / Protobuf definitions]

### 7.2 Messaging & Event Patterns

| Pattern | Technology | Use Case | Guarantees |
|---------|-----------|----------|------------|
| [Pub/Sub] | [e.g., Kafka] | [Domain event propagation] | [At-least-once, ordered within partition] |

### 7.3 External System Integrations

| System | Protocol | Data Exchanged | Frequency | Owner | Contract Stability |
|--------|----------|----------------|-----------|-------|--------------------|
| [External system] | [REST/SFTP/...] | [What data] | [Real-time/batch/on-demand] | [Team] | [Stable/Volatile] |

---

## 8. Security Architecture

### 8.1 Authentication & Authorization Model

**Authentication:** [Mechanism — e.g., OAuth 2.0 + OIDC via Keycloak]
**Authorization:** [Model — e.g., RBAC with resource-level policies]

### 8.2 Data Protection

| Data Classification | At Rest | In Transit | Access Control |
|--------------------|---------|------------|----------------|
| [Confidential] | [AES-256] | [TLS 1.3] | [Role-restricted, audit-logged] |

### 8.3 Network Security

[Network segmentation, API gateway, WAF, zero-trust model — as applicable.]

### 8.4 Secrets Management

**Approach:** [e.g., HashiCorp Vault with auto-rotation]
**Injection method:** [Mounted files / environment variables / sidecar]

---

## 9. Deployment Architecture

### 9.1 Environment Strategy

| Environment | Purpose | Infra Parity | Access |
|------------|---------|-------------|--------|
| [dev] | Development & experimentation | Minimal | Engineering |
| [staging] | Pre-production validation | Production-like | Engineering + QA |
| [prod] | Live traffic | Full | Restricted |

### 9.2 CI/CD Pipeline

[Pipeline stages: build → test → security scan → deploy → validate. Automation level and gating criteria.]

### 9.3 Infrastructure as Code

**Tool:** [e.g., Terraform / Pulumi / CDK]
**Repository strategy:** [Mono-repo / separate infra repo]
**Change process:** [PR review → plan → apply]

### 9.4 Scaling Strategy

| Component | Scaling Type | Trigger Metric | Min/Max | SRS Requirement |
|-----------|-------------|----------------|---------|-----------------|
| [API servers] | Horizontal auto-scale | CPU > 70% | 2–10 | [NFR-XX-##] |

---

## 10. Cross-Cutting Concerns

### 10.1 Observability

| Pillar | Tool | Standard | Retention |
|--------|------|----------|-----------|
| Logging | [e.g., ELK Stack] | Structured JSON, correlation IDs | [30 days hot, 1 year cold] |
| Metrics | [e.g., Prometheus + Grafana] | RED/USE method | [90 days] |
| Tracing | [e.g., OpenTelemetry + Jaeger] | W3C Trace Context | [7 days] |

### 10.2 Error Handling Strategy

[System-wide approach to error classification, propagation, user-facing messages, and internal logging.]

### 10.3 Configuration Management

**Approach:** [e.g., Environment variables + config service for dynamic config]
**Environment overrides:** [How per-environment configuration works]

### 10.4 Feature Flags & Rollout Strategy

[If applicable — feature flag service, progressive rollout percentages, kill-switch mechanism.]

---

## 11. Architectural Decision Records

| ID | Decision | Context | Alternatives | Consequences |
|----|----------|---------|-------------|-------------|
| ADR-01 | [What was decided] | [Why it came up — link to SRS/driver] | [What else was considered and why not] | [Positive and negative consequences] |

---

## 12. Quality Attribute Strategies

| SRS NFR ID | Quality Attribute | Architectural Strategy | Fitness Function |
|------------|-------------------|----------------------|-----------------|
| [NFR-XX-##] | [e.g., Latency < 200ms] | [Caching layer + read replicas + CDN] | [p99 latency measured via APM, alert if > 200ms] |

---

## 13. Risk Register

| ID | Risk | Likelihood | Impact | Mitigation | Owner |
|----|------|-----------|--------|------------|-------|
| AR-01 | [Risk description] | High/Med/Low | High/Med/Low | [Mitigation strategy] | [TBD] |

---

## 14. Open Questions

| ID | Question | Impacts | Owner | Due Date |
|----|----------|---------|-------|----------|
| AQ-01 | [Unresolved question] | [Components/decisions affected] | [TBD] | [Target date] |

---

## 15. Traceability Matrix

| SRS Requirement | Architectural Decision | Component(s) | ADR |
|----------------|----------------------|-------------|-----|
| [FR-XX-## / NFR-XX-##] | [Decision summary] | [Components implementing it] | [ADR-##] |
```

## ID Convention

Use these patterns for IDs within the architecture document:

- `ADR-##` — Architectural Decision Records
- `AR-##` — Architectural Risks
- `AQ-##` — Architecture Open Questions
- `AA-##` — Architecture Assumptions

## Priority Definitions

- **Must**: Architecture cannot proceed without resolving this. Non-negotiable structural decision.
- **Should**: Significant risk or quality degradation without this. Expected for production architecture.
- **Could**: Desirable improvement. Can be deferred to a later design phase.
