# Skill: Post-Squash-Merge Conflict Resolution

**First seen:** 2026-05-21T08:25:00Z  
**Author:** Kwame  
**Context:** MR !29 squash-merged to `main`; MR !30 (`feature/main-screen-cleanup`) auto-retargeted and conflicted.

---

## The Pattern

When a feature branch (`feature/B`) was branched after `feature/A`, and `feature/A` is squash-merged to `main`, `feature/B` sees a conflict because:

- `feature/B` has `feature/A`'s *individual commits* as ancestors
- `main` only has the *squash commit* as ancestor
- Git cannot reconcile these as the "same" changes — they have different SHAs and parents

This produces conflicts even when both branches' changes are **logically compatible** and touch different areas.

---

## Resolution Algorithm

### Step 1 — Classify each conflict region by ownership

For each `<<<<<<< HEAD ... ======= ... >>>>>>> origin/main` block, ask:

> "Which WI/PR authored this code, and what was its intent?"

- **HEAD** = the current feature branch's additions  
- **origin/main** = the squash commit that landed on main

### Step 2 — Apply the merge rules

| HEAD content | origin/main content | Resolution |
|---|---|---|
| Has unique new code | Is empty (HEAD added) | Take HEAD |
| Is empty | Has unique new code | Take origin/main |
| Both have code, non-overlapping | Different additions | Take both |
| Both have same code | Duplicate from common ancestor | Take either, deduplicate |
| Both have code, logically conflicting | One overrides the other | Use WI intent to decide |

### Step 3 — Handle the "large block" conflict

When one side of a conflict is a large block of new code and the other side is empty, check:

- Does the "empty" side (HEAD) already have that code **outside** the conflict region?
- If yes: take the origin/main block (close the function, add new code), then remove the duplicate block that HEAD placed outside the conflict.

This happens because the squash commit inserted new lines at the same position where HEAD's ancestry had them.

### Step 4 — Deduplication

After resolving all conflict markers, search for:
```
grep -n "private var <symbolName>" <file>
```
If any computed property / function appears twice, remove the duplicate (prefer the version from the branch doing the intentional work — usually origin/main for WI code, HEAD for cleanup code).

### Step 5 — Verify the add/add test file conflict

For `both added` conflicts on test files:
```bash
git diff origin/main HEAD -- <file>   # should show no diff if truly identical
git checkout --ours <file>
git add <file>
```

---

## Anti-patterns to Avoid

- **Don't blindly accept all HEAD**: HEAD may have duplicate WI code from ancestry.
- **Don't blindly accept all origin/main**: origin/main may lack cleanup-branch additions (new chips, new toolbar buttons, etc.).
- **Don't trust line numbers alone**: After partial resolution, line numbers shift. Use symbol names.

---

## Verification Checklist

- [ ] No `<<<<<<< HEAD`, `=======`, `>>>>>>> origin/main` markers remain
- [ ] No duplicated `private var` / `private func` symbols
- [ ] Build succeeds with no new warnings
- [ ] All unit tests pass
- [ ] All UI smoke tests pass
- [ ] `git log --oneline -3` shows a clean merge commit

---

## Example (this project, 2026-05-21)

| Conflict | HEAD | origin/main | Decision |
|---|---|---|---|
| `.sheet(isPresented: $showSkinTypeEdit)` | Had it | Didn't | Kept HEAD |
| `LocationRationaleCard` block | Intentionally removed | Had it | Kept HEAD (empty) |
| WI #7 computed props + `photosensitizationBanner` | Duplicate props + unique 3-chip `mainInputsRow` | New props + `photosensitizationBanner` | Took origin/main props (no banner), dedup'd HEAD props, kept HEAD's `skinTypeChip`/`mainInputsRow` |

Result: 69 unit tests ✅, 5 UI smoke tests ✅, merge commit `4b9afc0`.
