---
name: Java Conventions
description: Java 21 coding standards for all Java source files
paths:
  - "**/*.java"
---

- Use Java 21 features: records, sealed classes, pattern matching, virtual threads where appropriate
- Follow Google Java Style Guide
- Always use constructor injection over field injection for Spring beans
- Write Javadoc for all public methods
- Prefer `var` for local variables when type is obvious from RHS
