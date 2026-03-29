* The use of the `any` type is generally prohibited.
* In principle, type conversion using `as unknown as T` is prohibited.
* Functions are defined using the function expression.
* Be sure to include the type definitions for function arguments and return values
* Prefer `type` over `interface`
* When writing an if statement, always use `{}`
* Do not use Class, but it is allowed if the existing source code is Class-based.
* Processes and type definitions should be organized with collocation in mind, placing related elements close together.
* Centralize all environment variable access (e.g., `process.env`) in a dedicated file such as `env.ts`. Never access environment variables directly outside of that file.
* Do not `export` functions or type definitions that are not imported anywhere.
* Do not create dedicated `types.ts` or `constants.ts` files. Co-locate types and constants in the same file as the implementation that uses them.
* Always use arrow functions for callbacks passed to `map`, `filter`, `find`, and similar array methods.
