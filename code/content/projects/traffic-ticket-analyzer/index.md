---
title: "Distributed Traffic Ticket Analyzer"
description: "A distributed MapReduce system built on Hazelcast that processes millions of parking tickets"
summary: ""
date: 2025-01-18T00:00:00-03:00
lastmod: 2025-01-18T00:00:00-03:00
draft: false
weight: 60
categories: []
tags: [Java, Hazelcast, MapReduce, Distributed Systems, Big Data]
contributors: []
pinned: false
homepage: false
colorCardHeader: true
github_url: "https://github.com/nicrossi/pod-traffic-tickets"
seo:
  title: "Distributed Traffic Ticket Analyzer"
  description: "A distributed MapReduce system built on Hazelcast that processes millions of parking tickets"
  canonical: "https://nicorossi.net/projects/pod-traffic-tickets/"
  noindex: false
---

A distributed MapReduce system built on Hazelcast that processes millions of parking tickets from NYC and Chicago in parallel.
The architecture leverages a client-server model with custom mappers, reducers, and collators to execute analytical
queries—ranging from revenue aggregation by agency to time-series trend analysis—across a horizontally scalable cluster.

*Built for the Distributed object-oriented programming course at Buenos Aires Institute of Technology (ITBA).*

<div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
  <div>
    <a href="https://github.com/nicrossi/pod-traffic-tickets">
    <img src="https://img.shields.io/badge/GitHub-Repository-181717?style=for-the-badge&logo=github&logoColor=white" alt="GitHub Repo"></a>
  </div>
  <div>
    <img src="https://img.shields.io/badge/Java-17-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white" alt="Java">
    <img src="https://img.shields.io/badge/Hazelcast-3.8-00A3E0?style=for-the-badge&logo=hazelcast&logoColor=white" alt="Hazelcast">
    <img src="https://img.shields.io/badge/Maven-C71A36?style=for-the-badge&logo=apache-maven&logoColor=white" alt="Maven">
    <img src="https://img.shields.io/badge/Log4j-2.18-D22128?style=for-the-badge&logo=apache&logoColor=white" alt="Log4j">
  </div>
</div>

---


