# Architecture Concerns & Probing Questions

Use this taxonomy to systematically challenge the user's architectural decisions. Not every category applies to every system — select the relevant ones based on the SRS and the system's complexity profile.

## 1. Architectural Style & Patterns

**Core concern:** The fundamental structural approach — monolith vs. microservices vs. serverless, event-driven vs. request-response, layered vs. hexagonal — and how it aligns with quality attributes and team structure.

**Probing questions:**
- What is the system's primary communication model — synchronous request-response, asynchronous event-driven, or a hybrid? What drives that choice?
- Is there a reason to decompose into independently deployable services now, or would a modular monolith better match the current team size and domain understanding?
- Which quality attribute dominates the architectural style decision — scalability, maintainability, time-to-market, or operational simplicity?
- Are there existing architectural constraints (e.g., legacy systems, platform mandates) that limit style choices?
- How does the team's experience with the candidate architecture affect risk? Have they operated this style in production before?
- What patterns (CQRS, event sourcing, saga, circuit breaker) are genuinely needed vs. adopted preemptively?

## 2. System Decomposition

**Core concern:** Domain boundaries, service granularity, communication patterns between components, and the coupling/cohesion trade-off.

**Probing questions:**
- What are the natural domain boundaries? Which bounded contexts have emerged from requirements analysis?
- Where does data ownership sit — which component is the system of record for each entity?
- What is the expected rate of independent change for each component? Do deployment cadences justify separate services?
- What communication patterns exist between components — synchronous calls, events, shared database, or file exchange? What are the failure implications of each?
- How will you handle cross-cutting transactions that span multiple components? (Saga, two-phase commit, eventual consistency with compensation?)
- What is the team topology — does the decomposition align with team boundaries and Conway's Law?

## 3. Technology Selection

**Core concern:** Languages, frameworks, databases, cloud providers, and build tools — evaluated against real constraints including team skills, licensing, ecosystem maturity, and long-term viability.

**Probing questions:**
- What languages and frameworks does the team have production experience with? What is the cost of introducing something new?
- Are there licensing constraints (open source requirements, commercial budget, compliance restrictions) that limit choices?
- How mature is the ecosystem for the candidate technologies? Are there known gaps in tooling, documentation, or community support?
- What is the expected technology lifespan — will this stack still be well-supported in 3-5 years?
- Are there performance or operational characteristics that rule out specific technologies? (e.g., garbage collection pauses, cold start latency, memory footprint)
- How does the technology choice affect hiring and onboarding?

## 4. Data Architecture

**Core concern:** Storage strategy (relational, document, graph, time-series), consistency model (strong, eventual, causal), data flows, replication, and migration paths.

**Probing questions:**
- What are the dominant access patterns — read-heavy, write-heavy, mixed? Do different entities have different patterns?
- What consistency model does each data domain require? Where can you tolerate eventual consistency, and where is strong consistency non-negotiable?
- What is the expected data volume at launch and at projected scale? How does this affect storage technology choice?
- Are there data relationships that are best modeled relationally, as documents, as graphs, or as time-series?
- How will schema evolution be managed? What is the migration strategy for breaking changes?
- What data needs to be shared across service boundaries, and how will that sharing work without tight coupling?

## 5. Integration & Communication

**Core concern:** API design (REST, GraphQL, gRPC), messaging (queues, topics, streams), external system contracts, protocol choices, and contract evolution.

**Probing questions:**
- What API style best serves the consumers — REST for broad compatibility, GraphQL for flexible querying, gRPC for performance-critical internal communication?
- Which integrations are synchronous (need immediate response) vs. asynchronous (can tolerate latency)?
- What external systems must be integrated? Who owns the contract, and how stable are their APIs?
- How will you handle versioning and backward compatibility of APIs as the system evolves?
- What happens when an integration partner is unavailable — retry, circuit break, degrade gracefully, or fail fast?
- Are there message ordering, deduplication, or exactly-once delivery requirements?

## 6. Security Architecture

**Core concern:** Authentication model, authorization strategy, encryption at rest and in transit, network segmentation, secrets management, and threat model alignment with SRS security requirements.

**Probing questions:**
- What is the authentication model — centralized identity provider, federated SSO, API keys, mutual TLS, or a combination?
- How granular does authorization need to be — role-based, attribute-based, resource-level, or field-level?
- What data requires encryption at rest? What key management strategy supports rotation and access control?
- How is the network segmented — are services in private subnets, behind API gateways, with zero-trust between services?
- Where are secrets stored and how are they injected — vault, environment variables, mounted files, cloud-native secret managers?
- What are the top 3 threats from the threat model, and how does the architecture specifically mitigate each?

## 7. Deployment & Operations

**Core concern:** Environment strategy, CI/CD pipeline design, infrastructure-as-code, container orchestration, scaling strategy, and deployment patterns (blue-green, canary, rolling).

**Probing questions:**
- How many environments are needed and what is the promotion path? (dev → staging → prod, or more granular?)
- What is the target deployment frequency, and what level of automation is needed to sustain it?
- What infrastructure-as-code approach will be used? How will infrastructure changes be reviewed and rolled back?
- What scaling strategy applies — horizontal auto-scaling, vertical scaling, or pre-provisioned capacity? What metrics trigger scaling?
- How will deployments be validated — canary analysis, blue-green switchover, feature flags, or progressive rollout?
- What is the disaster recovery strategy? What is the RTO/RPO, and has it been tested?

## 8. Evolution & Governance

**Core concern:** Change strategy over time — how the architecture evolves, fitness functions that detect drift, ADR practices, team autonomy vs. consistency, and technology upgrade paths.

**Probing questions:**
- How will architectural decisions be documented and communicated? Will you use ADRs, architecture guilds, or another mechanism?
- What fitness functions or automated checks will detect architectural drift? (e.g., dependency analysis, contract tests, coupling metrics)
- How much autonomy do teams have to make local technology choices vs. following platform standards?
- What is the upgrade path for major framework or platform version changes? How will you avoid falling behind?
- How will you evaluate whether the current architecture still fits as requirements and scale change?
- What governance mechanisms prevent ad-hoc decisions that bypass architectural principles?
