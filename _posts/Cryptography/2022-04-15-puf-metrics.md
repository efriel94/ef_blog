---
layout: post
title: "Breaking down PUF Analysis Metrics"
author: "Emmet Friel"
categories: Cryptography
image: crypto/what-the-hell-does-that-even-mean.jpg
---
<br>

# Introduction

Reading academic papers as a non-academic in a research area that you have (at the time of writing) little experience in is like, as my grandmother would say, "trying to read a doctor's prescription".<br>

This post outlines a simple breakdown of PUF evaluation metrics with the mathematical equations attached to each one. It requires only a fundamental understanding of PUF, statistical mathematics and cryptography. <br> 

To accurately evaluate the statistical performance and security of a PUF the following metrics are used:
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
U_b = \frac{2}{m(m-1)} \sum_{i=1}^{m-1} \sum_{j=i+1}^{m} HD(R_{i,b}, R_{j,b})
$$

If different PUF chips produce similar responses to the same challenge, then an adversary may predict PUF responses using modelling attacks.<br>

## Minimum Entropy
When using PUFs in applications minimum entropy estimation is essential. Entropy is a measure of the unpredictability in PUF responses, and the minimum entropy is an evaluation of the worst-case scenario. In the context of security evaluation, worst-case analysis is preferable to best case. Using the test suite of the National Institute of Standards and Technology (NIST) specification (SP) 800-90B is currently considered the best method for estimating the min-entropy of PUF responses.<br>

Interestingly, there has been ongoing research into problems using NIST SP 800-90B when evaluating it for two-dimensional data structures such as SRAM PUFs:

> First, NIST SP 800-90B is an entropy estimation suite for RNGs that assumes sequential data input. PUFs with an evaluator can intentionally control the ordering of PUF responses by using PUF challenges. Next, the entropy estimation suite of NIST SP 800-90B is known to be unsuitable for two-dimensional memory-based PUFs such as SRAM PUF. The entropy estimation suite is basically designed to operate on one-dimensional data, such as RNGs. There are spatial correlations between responses in PUFs, especially two-dimensional PUFs (e.g., SRAM PUF). Therefore, the approach that concatenates PUF responses obfuscates the spatial correlations and may cause overestimation of PUF entropy.

See paper for more info: **[Entropy Estimation of PUFs with Offset Error](https://eprint.iacr.org/2020/1284.pdf)**

The n-bit responses of m devices have an occurrence probability at bit of $p1$ (logic 1) and $p0$ (logic 0) where:

$$
p1 = \frac{HW_b}{m}
$$

$$
p0 = 1- \frac{HW_b}{m}
$$

Where $HW_b$ is the number of 1’s in m devices. Therefore, the minimum entropy $\widetilde{H}_{min}$ of the design:

$$
\widetilde{H}_{min} = \frac{1}{n} \sum_{b=1}^{n}\widetilde{H}_{min,b}
$$

Where the minimum entropy per bit $\widetilde{H}_{min,b}$:


$$
\widetilde{H}_{min,b} = - log_{2}(pb_max)$
$$

Where the maximum probability, $pb_{max}=max⁡(p_0,p_1)$
The ideal case is where $$\widetilde{H}_{min} = 1$$, indicating the probability of a given bit being equal to 0 or 1 is equal $$pb_{max}=0.5$$. 

GitHub Link: [NIST SP800-90B suite](https://github.com/usnistgov/SP800-90B_EntropyAssessment)




<!-- one must have, first of all, a solid grounding in the PUF design and implementation concepts, basic cryptography knowledge and the numerous statistical metrics associated, PUF co and resources are far and few in explaining those metrics in layman terms for us non-academics. To understand how to those metrics requires a basic understanding in statistical analysis, PUF concepts,     -->