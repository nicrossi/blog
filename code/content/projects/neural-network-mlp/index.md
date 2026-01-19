---
title: "Neural Network from Scratch: MLP Implementation"
description: "A pure NumPy implementation of a Multilayer Perceptron with custom backpropagation and swappable optimizers"
summary: "A pure NumPy implementation of a Multilayer Perceptron with custom backpropagation and swappable optimizers"
date: 2025-01-18T00:00:00-03:00
lastmod: 2025-01-18T00:00:00-03:00
draft: false
weight: 35
categories: []
tags: [Python, AI, Neural Networks, NumPy, Backpropagation, ITBA]
contributors: []
pinned: false
homepage: false
colorCardHeader: true
github_url: "https://github.com/nicrossi/neural-network-base"
seo:
  title: "Neural Network from Scratch: MLP Implementation"
  description: "A pure NumPy implementation of a Multilayer Perceptron with custom backpropagation and swappable optimizers"
  canonical: "https://nicorossi.net/projects/neural-network-mlp/"
  noindex: false
---

A pure NumPy implementation of a **Multilayer Perceptron (MLP)** with custom backpropagation,
exploring non-linearly separable problems from XOR to digit recognition. Features modular
architecture with swappable optimizers (SGD, Momentum, Adam), multiple activation functions,
and comprehensive training analytics—all without relying on high-level ML frameworks.

## Features

- **Hand-rolled Backpropagation**: Manual gradient computation for deep learning education
- **Optimizer Playground**: Compare SGD, Momentum, and Adam with built-in performance metrics
- **Config-Driven Experiments**: YAML-based architecture for reproducible ML experiments
- **Real Problems**: XOR gates, parity detection, and handwritten digit classification (MNIST-style)
- **Visual Analytics**: Confusion matrices, decision boundaries, and convergence analysis built-in

## Quick Start

```bash
  # Train on XOR problem
  python experiments/exercise_3/train_tp3.py xor_config.yaml

  # Run digit classification with noise robustness testing
  python experiments/exercise_3/train_tp3.py digit_classification_config.yaml
```

## Perfect For

- **Learning**: Understand backprop internals without framework magic
- **Research**: Experiment with optimizer behaviors and convergence patterns
- **Foundation**: Extensible architecture for custom ML experiments

*Built for the Artificial Intelligence Systems course at Buenos Aires Institute of Technology (ITBA).*

<div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
  <div>
    <a href="https://github.com/nicrossi/neural-network-base">
    <img src="https://img.shields.io/badge/GitHub-Repository-181717?style=for-the-badge&logo=github&logoColor=white" alt="GitHub Repo"></a>
  </div>
  <div>
    <img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python">
    <img src="https://img.shields.io/badge/NumPy-013243?style=for-the-badge&logo=numpy&logoColor=white" alt="NumPy">
    <img src="https://img.shields.io/badge/Matplotlib-11557c?style=for-the-badge&logo=python&logoColor=white" alt="Matplotlib">
    <img src="https://img.shields.io/badge/YAML-CB171E?style=for-the-badge&logo=yaml&logoColor=white" alt="YAML">
  </div>
</div>

---



