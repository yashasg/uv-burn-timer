# Decision: Default Model Selection for Squad Agents

**Date:** 2026-05-20  
**Status:** Proposed  
**Audience:** All squad agents and team coordinators

## Problem

Squad agents were using inconsistent models, leading to:
- Variable performance across tasks
- Unpredictable costs
- Difficulty in predicting behavior and quality

## Decision

Establish `claude-opus-4.7-xhigh` as the default model for all squad agents and sub-agents, with explicit exceptions for Ralph and Scribe.

### Trade-offs

**Pros:**
- **Consistency:** Unified behavior across the team
- **Quality:** Opus 4.7 XHigh provides superior reasoning for architectural decisions
- **Predictability:** Team can reason about capabilities uniformly

**Cons:**
- **Cost:** Opus 4.7 XHigh is more expensive than other models
- **Latency:** Slower inference compared to Haiku/Sonnet
- **Not optimal for all tasks:** Task-specific models (e.g., Haiku for fast searches) may be more efficient

### Exceptions

- **Ralph:** Retains existing model assignment (specialized for specific workflows)
- **Scribe:** Retains existing model assignment (specialized for specific workflows)

Task-specific model overrides are permitted when documented rationale exists (performance, cost, or capability requirements).

## Implementation

- Updated `loop.md` Section 1: Model Selection
- Effective for all new agent launches
- Does not retroactively change running agents

## Related Files

- `loop.md` (Section 1: Model Selection)
