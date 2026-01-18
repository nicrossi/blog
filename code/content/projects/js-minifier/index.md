---
title: "Compiler-Based JavaScript Minifier"
description: "A Javascript minifier written in C, using a Flex-Bison Compiler."
summary: ""
date: 2025-06-23T23:10:00-03:00
lastmod: 2025-06-23T23:10:00-03:00
draft: false
weight: 50
categories: []
tags: [C, Flex, Bison, Compiler, JavaScript, Minifier]
contributors: []
pinned: false
homepage: false
colorCardHeader: true
github_url: "https://github.com/nicrossi/js-minifier"
seo:
  title: "Compiler-Based JavaScript Minifier in C using Flex and Bison"
  description: "A Javascript minifier written in C, using a Flex-Bison Compiler."
  canonical: "https://nicorossi.net/projects/js-minifier/"
  noindex: false
---

A not-so-smart Javascript minifier built from scratch in C using Flex and Bison,
implementing a complete compiler pipeline with lexical analysis, syntactic parsing,
semantic validation, and code generation. The project showcases a custom symbol
table with hash-based scope management and intelligent variable renaming using
base-26 encoding—transforming verbose JavaScript into compact, optimized output
while maintaining semantic correctness.

<div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
  <div>
    <a href="https://github.com/nicrossi/js-minifier">
    <img src="https://img.shields.io/badge/GitHub-Repository-181717?style=for-the-badge&logo=github&logoColor=white" alt="GitHub Repo"></a>
  </div>
  <div>
    <img src="https://img.shields.io/badge/C-00599C?style=for-the-badge&logo=c&logoColor=white" alt="C">
    <img src="https://img.shields.io/badge/Flex-2C2255?style=for-the-badge&logo=gnu&logoColor=white" alt="Flex">
    <img src="https://img.shields.io/badge/Bison-A42E2B?style=for-the-badge&logo=gnu&logoColor=white" alt="Bison">
    <img src="https://img.shields.io/badge/CMake-064F8C?style=for-the-badge&logo=cmake&logoColor=white" alt="CMake">
    <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker">
  </div>
</div>

---

