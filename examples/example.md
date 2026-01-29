---
title: "Example Document"
subtitle: "Mermaid Diagrams with Pandoc and mmdr"
titlepage: true
---

# Introduction

This document demonstrates rendering Mermaid diagrams in Pandoc using
[mmdr](https://github.com/1jehuang/mermaid-rs-renderer), a fast
Rust-based Mermaid renderer that requires no Chromium or Node.js.

# Flowchart

A simple processing pipeline:

```mermaid
graph LR
    A[Input] --> B[Parse]
    B --> C[Validate]
    C --> D[Transform]
    D --> E[Output]
```

# Sequence Diagram

A request/response sequence:

```mermaid
sequenceDiagram
    participant Client
    participant Server
    participant Database

    Client->>Server: HTTP Request
    Server->>Database: Query
    Database-->>Server: Results
    Server-->>Client: HTTP Response
```

# Class Diagram

A simple class hierarchy:

```mermaid
classDiagram
    class Animal {
        +String name
        +int age
        +makeSound()
    }
    class Dog {
        +fetch()
    }
    class Cat {
        +purr()
    }
    Animal <|-- Dog
    Animal <|-- Cat
```

# Gantt Chart

A project timeline:

```mermaid
gantt
    title Project Plan
    dateFormat YYYY-MM-DD
    section Design
        Requirements :a1, 2025-01-01, 7d
        Prototype    :a2, after a1, 5d
    section Development
        Backend  :b1, after a2, 14d
        Frontend :b2, after a2, 14d
    section Testing
        QA       :c1, after b1, 7d
```

# Pie Chart

Distribution of languages in a project:

```mermaid
pie title Codebase Composition
    "Rust" : 45
    "Lua" : 25
    "Dockerfile" : 15
    "Makefile" : 10
    "YAML" : 5
```

# Journey

A user experience journey:

```mermaid
journey
    title User Onboarding
    section Sign Up
        Visit website: 5: User
        Fill in form: 3: User
        Verify email: 2: User
    section First Use
        Read tutorial: 4: User
        Create first project: 5: User
```

# Mindmap

A topic breakdown:

```mermaid
mindmap
  root((Documentation))
    Formats
      PDF
      HTML
      EPUB
    Tools
      Pandoc
      mmdr
      LaTeX
    Diagrams
      Flowchart
      Sequence
      Class
```

# Git Graph

A branching workflow:

```mermaid
gitGraph
    commit
    commit
    branch feature
    checkout feature
    commit
    commit
    checkout main
    merge feature
    commit
```

# Conclusion

All diagrams above were rendered at build time by `mmdr` and
embedded directly into the output. No browser engine was involved.
