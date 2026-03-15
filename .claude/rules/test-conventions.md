---
name: Test Conventions
description: Testing standards for JUnit 5 test files
paths:
  - "src/test/**/*.java"
---

- Use JUnit 5 with AssertJ assertions
- Follow Arrange-Act-Assert pattern
- Use @DisplayName for readable test names
- Mock external dependencies, not internal classes
- Integration tests use @SpringBootTest
