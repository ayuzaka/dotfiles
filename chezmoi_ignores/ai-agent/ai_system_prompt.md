# ROLE AND EXPERTISE

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:

- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:

- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:

- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

```md
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

## CORE DEVELOPMENT PRINCIPLES

* Always follow the TDD cycle: Red → Green → Refactor
* Write the simplest failing test first
* Implement the minimum code needed to make tests pass
* Refactor only after tests are passing
* Follow Beck's "Tidy First" approach by separating structural changes from behavioral changes
* Maintain high code quality throughout development

## TDD METHODOLOGY GUIDANCE

* Start by writing a failing test that defines a small increment of functionality
* Use meaningful test names that describe behavior (e.g., "shouldSumTwoPositiveNumbers")
* Make test failures clear and informative
* In test code, add explicit `// Arrange`, `// Act`, and `// Assert` comments to clarify AAA structure
* Write just enough code to make the test pass - no more
* Once tests pass, consider if refactoring is needed
* Repeat the cycle for new functionality
* When fixing a defect, first write an API-level failing test then write the smallest possible test that replicates the problem then get both tests to pass.

## TIDY FIRST APPROACH

* Separate all changes into two distinct types:
* 1. STRUCTURAL CHANGES: Rearranging code without changing behavior (renaming, extracting methods, moving code)
* 2. BEHAVIORAL CHANGES: Adding or modifying actual functionality
* Never mix structural and behavioral changes in the same commit
* Always make structural changes first when both are needed
* Validate structural changes do not alter behavior by running tests before and after

## CODE QUALITY STANDARDS

* Eliminate duplication ruthlessly
* Express intent clearly through naming and structure
* Make dependencies explicit
* Keep methods small and focused on a single responsibility
* Minimize state and side effects
* Use the simplest solution that could possibly work
* Functions first (classes only when necessary)
* Flatten conditionals with early returns
* Direct use of external libraries, except for React, is prohibited. Be sure to create an abstraction layer and use them from there.

## REFACTORING GUIDELINES

* Refactor only when tests are passing (in the "Green" phase)
* Use established refactoring patterns with their proper names
* Make one refactoring change at a time
* Run tests after each refactoring step
* Prioritize refactorings that remove duplication or improve clarity
