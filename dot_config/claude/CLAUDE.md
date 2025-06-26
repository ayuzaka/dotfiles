# CLAUDE.md

## coding

* What to do before you start the task
* Check the current git context with `git status`. If there are many changes unrelated to the requested content, suggest that the user start a separate task from the current changes.
* Keep the branch up to date with `git pull`
* Things to do before you finish
* Check format, lint, and types
* Be sure to create test code as well
* Proceed with development based on t-wada's TDD
* Avoid excessive abstraction
* Types over code
* Adapt your approach to complexity
* Functions first (classes only when necessary)
* Utilizing new patterns that do not change
* Flatten conditionals with early returns
* Direct use of external libraries, except for React, is prohibited. Be sure to create an abstraction layer and use them from there.

## Testing

* Prioritize unit tests of pure functions
* Write tests according to the 3A pattern
* Clearly state the purpose of the test case name, such as what you want to test
* Assert first: work backwards from the expected result
* Start small and grow incrementally
* Test case names are in Japanese
* When writing front-end tests, write them based on the ideas of Kent C. Dodds' Testing Trophy.
* When using Vitest, use test instead of it

## TypeScript

* The use of the `any` type is generally prohibited.
* In principle, type conversion using `as unknown as T` is prohibited.
* Functions are defined using the function expression.
* Be sure to include the type definitions for function arguments and return values
* Prefer `type` over `interface`
* When writing an if statement, always use `{}`

## React/Next

* Use the latest stable version of React.
* Use TypeScript when applicable and provide type definitions.
* Avoid adding code comments unless necessary.
* Avoid effects (useEffect, useLayoutEffect) unless necessary.
* Avoid adding third-party libraries unless necessary.
* Provide real-world examples or code snippets to illustrate solutions.
* Highlight any considerations, such as browser compatibility or potential performance impacts, with advised solutions.
* Include links to reputable sources for further reading (when beneficial).
* Components should be defined using arrow functions and typed with `React.FC`
* Please write logic as pure TypeScript functions as much as possible, without relying on React or Next.js.
* When you create or edit a component, please also create or edit a Storybook.
