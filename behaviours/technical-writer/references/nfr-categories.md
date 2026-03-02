# NFR Categories & Probing Questions

Use this taxonomy to systematically challenge the user's request. Not every category applies to every system — select the relevant ones based on context.

## 1. Performance & Efficiency

**Core concern:** Response times, throughput, resource utilization under expected and peak loads.

**Probing questions:**
- What are the expected response time targets for critical operations? (e.g., <200ms for API calls, <3s for page loads)
- What is the expected throughput? (requests/sec, transactions/min, messages/hour)
- Are there batch processing requirements? What volumes and time windows?
- What are the resource budget constraints? (CPU, memory, bandwidth)
- Are there latency-sensitive paths that require special optimization?

## 2. Scalability

**Core concern:** System's ability to handle growth in users, data, transactions, or features.

**Probing questions:**
- What is the expected growth trajectory? (users, data volume, transaction rate over 1/3/5 years)
- Should the system scale horizontally (more instances), vertically (bigger instances), or both?
- Are there hard scaling limits imposed by third-party services, licenses, or infrastructure?
- What is the cost model for scaling? Is there a budget ceiling?
- Are there seasonal or event-driven traffic spikes? What magnitude?

## 3. Reliability & Availability

**Core concern:** System uptime, fault tolerance, disaster recovery, data durability.

**Probing questions:**
- What is the target availability? (99.9%, 99.99%, etc.) What does that mean in practice for your users?
- What happens when the system goes down? What is the business impact per hour of downtime?
- What is the acceptable Recovery Time Objective (RTO) and Recovery Point Objective (RPO)?
- Are there components that must remain available even during partial failures?
- What failure modes are most likely? (network partition, data center outage, dependency failure)

## 4. Security

**Core concern:** Confidentiality, integrity, authentication, authorization, audit, compliance posture.

**Probing questions:**
- What data classification levels exist? (public, internal, confidential, restricted)
- What authentication and authorization models are required? (SSO, RBAC, ABAC, MFA)
- Are there regulatory requirements? (GDPR, HIPAA, SOC2, PCI-DSS)
- What is the threat model? Who are the adversaries and what are they after?
- What audit and traceability requirements exist? (who did what, when, from where)
- Are there data residency or sovereignty requirements?

## 5. Maintainability

**Core concern:** Ease of modification, debugging, extending, and understanding the system over time.

**Probing questions:**
- What is the expected team size and skill level of maintainers?
- How frequently will the system change? What kinds of changes are most common?
- Are there modularity or decoupling requirements to support independent team velocity?
- What is the expected system lifespan? (1 year prototype vs. 10+ year platform)
- What testing strategy is required? (unit, integration, e2e, contract, performance)
- Are there documentation or knowledge-transfer requirements?

## 6. Usability & Developer Experience

**Core concern:** End-user experience quality, API ergonomics, developer onboarding, accessibility.

**Probing questions:**
- Who are the users? What is their technical sophistication?
- Are there accessibility requirements? (WCAG level, assistive technology support)
- What is the target time-to-first-value for new users or developers?
- Are there internationalization/localization requirements?
- If an API: what are the ergonomics expectations? (consistency, discoverability, error clarity)
- What devices, browsers, or platforms must be supported?

## 7. Portability & Compatibility

**Core concern:** Ability to run across environments, migrate between platforms, integrate with existing systems.

**Probing questions:**
- Must the system run on multiple cloud providers or on-premise?
- Are there existing systems this must integrate with? What protocols/formats?
- Are there backward/forward compatibility requirements for APIs or data formats?
- What deployment environments are in scope? (dev, staging, prod, edge, air-gapped)
- Are there vendor lock-in concerns that must be mitigated?

## 8. Operability & Observability

**Core concern:** Monitoring, alerting, logging, debugging in production, deployment automation.

**Probing questions:**
- What monitoring and alerting capabilities are required?
- What is the expected deployment frequency? (daily, weekly, continuous)
- Are there zero-downtime deployment requirements?
- What logging and tracing standards must be followed?
- What is the expected mean time to detect (MTTD) and mean time to resolve (MTTR)?
- Are there runbook or incident response requirements?

## 9. Compliance & Regulatory

**Core concern:** Legal, regulatory, industry-standard, and contractual obligations.

**Probing questions:**
- What regulatory frameworks apply? (GDPR, HIPAA, SOX, PCI-DSS, FedRAMP)
- Are there data retention and deletion policies?
- Are there licensing constraints on technology choices?
- What audit trail requirements exist?
- Are there contractual SLA obligations with customers or partners?

## 10. Data Management

**Core concern:** Data lifecycle, consistency, integrity, migration, archival, and governance.

**Probing questions:**
- What are the consistency requirements? (strong, eventual, causal)
- What data volumes are expected and how will they grow?
- Are there data migration requirements from existing systems?
- What backup and archival policies are needed?
- Who owns the data? What governance model applies?
- Are there data quality or validation requirements?

## 11. Cost & Resource Efficiency

**Core concern:** Infrastructure costs, licensing costs, operational overhead, total cost of ownership.

**Probing questions:**
- What is the budget for infrastructure and operations?
- Are there cost-per-transaction or cost-per-user targets?
- What is the acceptable trade-off between cost and performance/availability?
- Are there constraints on technology choices driven by existing licenses or contracts?
- What is the operational staffing model? (dedicated ops team, developer-operated, managed services)
