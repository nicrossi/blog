---
title: "Neural Network AutoEncoders"
description: "A fully custom implementation of AutoEncoders and Variational AutoEncoders built from the ground up in NumPy"
summary: "A fully custom implementation of AutoEncoders and Variational AutoEncoders built from the ground up in NumPy"
date: 2025-11-25T00:00:00-03:00
lastmod: 2025-11-25T00:00:00-03:00
draft: false
weight: 37
categories: []
tags: [Python, AI, AutoEncoders, VAE, Neural Networks, NumPy, ITBA]
contributors: []
pinned: false
homepage: false
colorCardHeader: true
github_url: "https://github.com/EzequielVijande/AutoEncoders/"
seo:
  title: "Neural Network AutoEncoders"
  description: "A fully custom implementation of AutoEncoders and Variational AutoEncoders built from the ground up in NumPy"
  canonical: "https://nicorossi.net/projects/autoencoders/"
  noindex: false
---

A fully custom implementation of **AutoEncoders** and **Variational AutoEncoders (VAE)** built
from the ground up in NumPy—no TensorFlow, no PyTorch. Features a modular architecture with
encoder-decoder symmetry, stochastic sampling layers for VAEs, and support for multiple optimizers
(SGD, Momentum, Adam) with comprehensive loss functions (MSE, MAE, Cross-Entropy).

## Highlights

-  **Custom backpropagation engine** with dropout regularization
-  **Font character reconstruction** & latent space visualization
-  **Stochastic layer implementation** for VAE reparameterization trick
-  **Modular activation functions** (ReLU, Sigmoid, Tanh) via Strategy pattern
-  **Complete with unit tests** and training metrics tracking

## Features

- **AutoEncoder Architecture**: Encoder-decoder symmetry with configurable hidden layers
- **Variational AutoEncoder (VAE)**: Full implementation with KL divergence loss and reparameterization trick
- **Multiple Optimizers**: SGD, Momentum, and Adam with adaptive learning rates
- **Loss Functions**: MSE, MAE, and Cross-Entropy for flexible training objectives
- **Regularization**: Dropout layers for preventing overfitting
- **Visualization Tools**: Latent space exploration and reconstruction quality analysis

*Built for the Artificial Intelligence Systems course at Buenos Aires Institute of Technology (ITBA).*

<div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
  <div>
    <a href="https://github.com/EzequielVijande/AutoEncoders/">
    <img src="https://img.shields.io/badge/GitHub-Repository-181717?style=for-the-badge&logo=github&logoColor=white" alt="GitHub Repo"></a>
  </div>
  <div>
    <img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python">
    <img src="https://img.shields.io/badge/NumPy-013243?style=for-the-badge&logo=numpy&logoColor=white" alt="NumPy">
    <img src="https://img.shields.io/badge/Matplotlib-11557c?style=for-the-badge&logo=python&logoColor=white" alt="Matplotlib">
    <img src="https://img.shields.io/badge/scikit--image-F7931E?style=for-the-badge&logo=scikit-learn&logoColor=white" alt="scikit-image">
  </div>
</div>

---



