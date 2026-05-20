---
configured: true
interval: 1
timeout: 30
description: "My squad work loop"
---


# Squad Work Loop

## Loop Instructions

1. **Model Selection**
	- All agents and sub-agents must use `claude-opus-4.7-xhigh` as their default model.
	- Exception: Ralph and Scribe retain their default model assignments.
	- Override models only when a specific task requires a different model for performance or cost reasons.

2. **Build & Test**
	- Use `build.sh` as the canonical build script. All builds and tests must run through this script.
	- Treat all warnings as errors. The build must fail on any warning.
	- Follow test-driven development (TDD): write or update tests before implementing new features or fixes.

3. **iOS App Location**
	- All iOS app code and assets must reside in the `app/` directory.

4. **Iterative Work**
	- Keep looping on work items until the backlog is empty.
	- At the start of each cycle, compare implemented behavior against the approved design and user flows.
	- Create explicit work items for every missing or mismatched feature found in that design gap analysis.
	- Prioritize and execute work items one feature at a time until the backlog is empty.
	- At the end of each loop, do a parallel pass with all squad members to review if anything was missed based on the goals.

5. **Feature Delivery Workflow**
	- For each completed feature work item, open a merge request (MR) with implementation + tests.
	- Run CI/CD for the MR and require a fully green pipeline.
	- Merge the MR into `main` only when CI/CD is green.
	- If CI/CD fails, fix the issue, update tests, and re-run until green.

6. **Goals Checklist**
	- [ ] Working app
	- [ ] UI/UX approved
	- [ ] User scenarios captured
	- [ ] Expert approved
	- [ ] Code tested and validated — includes a green sign-off on `.squad/files/iris-contrast-qa-checklist.md` (WCAG contrast) **and** `.squad/files/iris-launch-readiness-checklist.md` (polarized-OLED outdoor readability) within the current build cycle.

7. **Review**
	- After all work items are complete, each squad member reviews the project in parallel to ensure all goals are met and nothing is missed.

8. **Continuous Improvement**
	- If any gaps are found during review, add them as new work items and repeat the loop.


## Tips

- Be specific and action-oriented in each loop.
- All code changes must be tested and validated before merging.
- UI/UX and expert reviews are required before marking the app as complete.
- Document user scenarios as you go.

---
