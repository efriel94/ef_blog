---
layout: post
title: "Breaking down PUF Analysis Metrics"
author: "Emmet Friel"
categories: Cryptography
image: crypto/what-the-hell-does-that-even-mean.jpg
---
<br>

# Introduction

Reading academic papers as a non-academic in a research area that you have (at the time of writing) little experience in is like, as my grandmother would say, "trying to read a doctor's prescription". To evaluate the performance and security of a PUF it is necessary have a solid grounding of PUF concepts, basic cryptography and statistical mathematics. The problem is that resources is far and few between in providing a simple breakdown of PUF evaluation metrics for us non-academics.<br>

This post serves to demistify PUF analysis from academic papers to provide a simple breakdown and reference of the evaluation metrics in layman terms. <br> 

To accurately evaluate the statistical performance and security of a PUF the following metrics is used:
-	Hamming Distance (HD)
-	Hamming Weight (HW)
-	Uniqueness
-	Min entropy
-	Correlation
-	CTW 
-	Uniformity
-	Reliability
-	Bit-aliasing

To help provide an illustration of the metrics and the mathematical equations that will follow, the images below will provide a reference:

<!-- Center image -->
![image]({{site.github.url}}/assets/img/crypto/puf_response.png){:style="display:block; margin-left:auto; margin-right:auto"}

<!-- Center image -->
![image]({{site.github.url}}/assets/img/crypto/puf_table.png){:style="display:block; margin-left:auto; margin-right:auto"}


## Hamming Distance
Arguably the most important metric of evaluating a PUF from a security standpoint is the Hamming distance which is a function computed over two binary strings of equal length that returns the number of bits that differ. There are two types of Hamming distance evaluations in the context of PUFs:
-	Intra-chip HD
-	Inter-chip HD

**Intra-chip HD**: Represents the reproducibility of each chip. This concerns with how repeatable we get the same output of bits given a certain challenge on a single device.<br>
**Inter-chip HD**: Represents the uniqueness of each output between a population of devices. For a well designed PUF each individual board should produce its own unique response for a given challenge. This metric evaluates the difference in the responses between devices.<br><br>
The ideal HD between devices in the context of PUF would have a value of 0.5 indicating that approximately half of the response bits are different between a pair of devices. Given two binary strings $R_i$ and $R_j$ the HD can be evaluated as:<br>

$$
HD(R_i,R_j) = \sum_{b=1}^n (R_{i,b} \oplus R_{j,b})
$$

 <!-- \int \mathcal{D}x(t) \exp(2\pi i S[x]/\hbar) -->

## Hamming Weight
The Hamming weight of a bit string is the number of non-zero values i.e the sum of all the logic 1's. Across a population of $m$ devices the Hamming weight of each bit can be evaluated as:<br>

$$
HW_b = \frac{1}{m} \sum_{i=1}^n (R_{i,b})
$$

## Uniqueness
Uniqueness metric evaluates the ability of a PUF to distinguish a device across an array of identical devices. Effectively its measuring the inter-chip HD across a group of $m$ devices. Ideally you want to evaluate that each response is seen to be unique across devices for a given challenge as this improves the main property of the PUF: unclonability, both from a mathematical perspective as well as physical. 
Assuming the uniqueness per bit $U_b$ is independent and identically distributed, the uniqueness of a PUF is given as:

$$
U = \frac{1}{n} \sum_{b=1}^{n} U_b
$$

Where $U_b$ is given as:

$$
U_b = \frac{2}{m(m-1)} \sum_{i=1}^{m-1} \sum_{j=i+1}^{m} HD(R_{i,b}, R{j,b})
$$


<!-- one must have, first of all, a solid grounding in the PUF design and implementation concepts, basic cryptography knowledge and the numerous statistical metrics associated, PUF co and resources are far and few in explaining those metrics in layman terms for us non-academics. To understand how to those metrics requires a basic understanding in statistical analysis, PUF concepts,     -->