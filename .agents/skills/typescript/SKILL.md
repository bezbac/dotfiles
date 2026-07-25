---
name: typescript
description: General guidance for writing TypeScript code. Use this whenever creating or editing .ts or .tsx files.
---

# Defining Functions

Do not add explicit return types to functions. TypeScript can infer them, and adding them creates extra maintenance burden and often leads to inaccurate types. Prefer using `as const` if required.
There are two exceptions to this rule:

- A highly critical function where you want to explicitly guarantee the return type and catch any accidental changes. In this case, add an explicit return type and ensure it is correct. This should be a rare exception.

Arguments to functions should by default be required and not have default values. Only if a function is called in **many** places and it would have a large benefit to ergonomics, should you make it optional. Use your best judgment here, but be conservative and prefer required arguments.

# Defining Types

- If defining a type that is only used in one place, define it inline where it is used.
- If defining a type that is based on an existing type but with some modifications, use advanced TypeScript features like `Omit`, `Pick`, `Extract`, `Exclude` etc instead of creating a new type. (See: https://www.typescriptlang.org/docs/handbook/utility-types.html for a full list of utility types.)

# Exhaustiveness Checking

When using union types, always ensure that you have an exhaustive check for all possible cases. My preferred way of doing this is to use a lookup table, if that does not work use `if` statements and then add a `assertUnreachable` function call in the last case.

# Code Style

- Never use `switch` / `case` statements, always prefer `if` statements or lookup tables.
