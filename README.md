<p align="center">
  <img src="docs/src/assets/logo.svg" height="150"><br/>
  <i>A Gene Finder framework for Julia.</i><br/><br/>
  <a href="https://camilogarciabotero.github.io/GeneFinder.jl/dev/">
    <img src="https://img.shields.io/badge/documentation-online-blue.svg?logo=Julia&logoColor=white">
  </a>
  <a href="https://github.com/camilogarciabotero/GeneFinder.jl/releases/latest"> 
  <img src="https://img.shields.io/github/release/camilogarciabotero/GeneFinder.jl.svg">
    <a href="https://doi.org/10.5281/zenodo.7519184"><img src="https://zenodo.org/badge/DOI/10.5281/zenodo.7519184.svg" alt="DOI"></a>
  </a>
  <a href="https://app.travis-ci.com/camilogarciabotero/GeneFinder.jl">
    <img src="https://app.travis-ci.com/camilogarciabotero/GeneFinder.jl.svg?branch=main">
   <a href="https://github.com/camilogarciabotero/GeneFinder.jl/actions/workflows/CI.yml">
    <img src="https://github.com/camilogarciabotero/GeneFinder.jl/actions/workflows/CI.yml/badge.svg">
  <a href="https://github.com/camilogarciabotero/GeneFinder.jl/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-green.svg">
  </a>
  <a href="https://www.repostatus.org/#wip">
    <img src="https://www.repostatus.org/badges/latest/wip.svg">
  </a>
</p>

***

<!-- [![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl) -->

## Overview

>This is a species-agnostic, algorithm extensible, sequence-anonymous (genome, metagenomes) *gene finder* library framework for the Julia Language.

The main goal of `GeneFinder` is to create a versatile module that enables apply different implemented algorithm to DNA sequences. See, for instance, BioAlignment implementations of different sequence alignment algorithms (local, global, edit-distance).

## Installation

You can install GeneFinder from the julia REPL. Press `]` to enter pkg mode, and enter the following:

```julia
add GeneFinder
```

If you are interested in the cutting edge of the development, please check out
the master branch to try new features before release.

## Finding complete and internal (overlapped) ORFs

The first implemented function is `findorfs` a very non-restrictive ORF finder function that will catch all ORFs in a dedicated structure. Note that this will catch random ORFs not necesarily genes since it has no ORFs size or overlapping condition contraints. Thus it might consider `aa"M*"` a posible encoding protein from the resulting ORFs.

```julia
using BioSequences, GeneFinder

# > 180195.SAMN03785337.LFLS01000089 -> finds only 1 gene in Prodigal (from Pyrodigal tests)
seq = dna"AACCAGGGCAATATCAGTACCGCGGGCAATGCAACCCTGACTGCCGGCGGTAACCTGAACAGCACTGGCAATCTGACTGTGGGCGGTGTTACCAACGGCACTGCTACTACTGGCAACATCGCACTGACCGGTAACAATGCGCTGAGCGGTCCGGTCAATCTGAATGCGTCGAATGGCACGGTGACCTTGAACACGACCGGCAATACCACGCTCGGTAACGTGACGGCACAAGGCAATGTGACGACCAATGTGTCCAACGGCAGTCTGACGGTTACCGGCAATACGACAGGTGCCAACACCAACCTCAGTGCCAGCGGCAACCTGACCGTGGGTAACCAGGGCAATATCAGTACCGCAGGCAATGCAACCCTGACGGCCGGCGACAACCTGACGAGCACTGGCAATCTGACTGTGGGCGGCGTCACCAACGGCACGGCCACCACCGGCAACATCGCGCTGACCGGTAACAATGCACTGGCTGGTCCTGTCAATCTGAACGCGCCGAACGGCACCGTGACCCTGAACACAACCGGCAATACCACGCTGGGTAATGTCACCGCACAAGGCAATGTGACGACTAATGTGTCCAACGGCAGCCTGACAGTCGCTGGCAATACCACAGGTGCCAACACCAACCTGAGTGCCAGCGGCAATCTGACCGTGGGCAACCAGGGCAATATCAGTACCGCGGGCAATGCAACCCTGACTGCCGGCGGTAACCTGAGC"
```
Now lest us find the ORFs

```julia
findorfs(seq)

12-element Vector{ORF}:
 ORF(29:40, '+', 2)
 ORF(137:145, '+', 2)
 ORF(164:184, '+', 2)
 ORF(173:184, '+', 2)
 ORF(236:241, '+', 2)
 ORF(248:268, '+', 2)
 ORF(362:373, '+', 2)
 ORF(470:496, '+', 2)
 ORF(551:574, '+', 2)
 ORF(569:574, '+', 2)
 ORF(581:601, '+', 2)
 ORF(695:706, '+', 2)
```

Two other functions (`getorfdna` and `getorfaa`) pass the sequence to `findorfs` take the ORFs and act as generators of the sequence, so this way the can be `collect`ed in the REPL as an standard output or writteen into a file more conviniently using the `FASTX` IO system:

```julia
getorfdna(seq)

12-element Vector{LongSubSeq{DNAAlphabet{4}}}:
 ATGCAACCCTGA
 ATGCGCTGA
 ATGCGTCGAATGGCACGGTGA
 ATGGCACGGTGA
 ATGTGA
 ATGTGTCCAACGGCAGTCTGA
 ATGCAACCCTGA
 ATGCACTGGCTGGTCCTGTCAATCTGA
 ATGTCACCGCACAAGGCAATGTGA
 ATGTGA
 ATGTGTCCAACGGCAGCCTGA
 ATGCAACCCTGA
```

```julia
getorfaa(seq)

12-element Vector{LongSubSeq{AminoAcidAlphabet}}:
 MQP*
 MR*
 MRRMAR*
 MAR*
 M*
 MCPTAV*
 MQP*
 MHWLVLSI*
 MSPHKAM*
 M*
 MCPTAA*
 MQP*
```

### Writting cds, proteins fastas, bed and gffs whether from a `LongSeq` or from a external fasta file.

```julia
write_cds("cds.fasta", seq)
```

```bash
cat cds.fasta

>location=29:40 strand=+ frame=2
ATGCAACCCTGA
>location=137:145 strand=+ frame=2
ATGCGCTGA
>location=164:184 strand=+ frame=2
ATGCGTCGAATGGCACGGTGA
>location=173:184 strand=+ frame=2
ATGGCACGGTGA
>location=236:241 strand=+ frame=2
ATGTGA
>location=248:268 strand=+ frame=2
ATGTGTCCAACGGCAGTCTGA
>location=362:373 strand=+ frame=2
ATGCAACCCTGA
>location=470:496 strand=+ frame=2
ATGCACTGGCTGGTCCTGTCAATCTGA
>location=551:574 strand=+ frame=2
ATGTCACCGCACAAGGCAATGTGA
>location=569:574 strand=+ frame=2
ATGTGA
>location=581:601 strand=+ frame=2
ATGTGTCCAACGGCAGCCTGA
>location=695:706 strand=+ frame=2
ATGCAACCCTGA
```

### Combining `FASTX` for reading and writing fastas

```julia
using FASTX

write_proteins("test/data/NC_001884.fasta", "proteins.fasta")
```

```bash
head proteins.fasta

>location=41:145 strand=- frame=2
MTQKRKGPIPAQFEITPILRFNFIFDLTATNSFH*
>location=41:172 strand=- frame=2
MVLKDVIVNMTQKRKGPIPAQFEITPILRFNFIFDLTATNSFH*
>location=41:454 strand=- frame=2
MSEHLSQKEKELKNKENFIFDKYESGIYSDELFLKRKAALDEEFKELQNAKNELNGLQDTQSEIDSNTVRNNINKIIDQYHIESSSEKKNELLRMVLKDVIVNMTQKRKGPIPAQFEITPILRFNFIFDLTATNSFH*
>location=41:472 strand=- frame=2
MKTKKQMSEHLSQKEKELKNKENFIFDKYESGIYSDELFLKRKAALDEEFKELQNAKNELNGLQDTQSEIDSNTVRNNINKIIDQYHIESSSEKKNELLRMVLKDVIVNMTQKRKGPIPAQFEITPILRFNFIFDLTATNSFH*
>location=41:505 strand=- frame=2
MLSKYEDDNSNMKTKKQMSEHLSQKEKELKNKENFIFDKYESGIYSDELFLKRKAALDEEFKELQNAKNELNGLQDTQSEIDSNTVRNNINKIIDQYHIESSSEKKNELLRMVLKDVIVNMTQKRKGPIPAQFEITPILRFNFIFDLTATNSFH*
```

## Creating transtion models out of DNA sequences

An important step beofore developing several of the gene finding algorithms, consist of having a Markov chain representation of the DNA. To do so, we implement a the `transtion_model` method that will capture the initials and transition probabilities of a DNA sequence (`LongSequence`) and will create a dedicated object storing relevant information of a DNA Makov chain. Here an example:

Let us use the Lambda phage genome and get a random orf from it:

```julia
lambda = fasta_to_dna("test/data/NC_001416.1.fasta")[1]
dna = getorfdna(lambda, min_len=75)[1]
```
If we translate it, we get a 127aa sequence:

```julia
translate(dna)
```

```
127aa Amino Acid Sequence:
MAFVLNSSWLEICLAGLPQFFNLPAQLFVLNFSIPFGIP…SFHGQKQRKETTEAKKPRFQHLSFPFFSEGILNKNIKL*
```

Now supposing I do want to see how transitions are occuring in this ORF sequence, the I can use the `transtion_model` method and tune it to 2nd-order Markov chain:



```julia
transition_model(dna, 2)
```

```
TransitionModel:
  - Transition Probability Matrix (Size: 4 × 4):
    0.246	0.277	0.212	0.266
    0.244	0.274	0.208	0.274
    0.248	0.279	0.205	0.268
    0.214	0.286	0.197	0.303
  - Initials (Size: 1 × 4):
    0.237	0.279	0.205	0.279
  - order: 2
```
This is very useful to latter crete HMMs and calculate sequence probability based on a given model, for instance we now have the *E. coli* CDS and No-CDS transition models implemented:

```julia
ECOLICDS
```
```
TransitionModel:
  - Transition Probability Matrix (Size: 4 × 4):
    0.31	0.224	0.199	0.268
    0.251	0.215	0.313	0.221
    0.236	0.308	0.249	0.207
    0.178	0.217	0.338	0.267
  - Initials (Size: 1 × 4):
    0.245	0.243	0.273	0.239
  - order: 1
```

What is then the probability of the previos random Lambda phage DNA sequence, given this model?

```julia
sequenceprobability(dna, ECOLICDS)
```

```
1.6727204374520648e-230
```

This is of course not very informative, but we can later use different criteeria to then classify new ORFs. For a more detailed explanation see the [docs](https://camilogarciabotero.github.io/GeneFinder.jl/dev/markovchains/)

## Algorithms

### Coding genes (CDS - ORFs)

- [x] [findorfs](https://camilogarciabotero.github.io/GeneFinder.jl/dev/simplefinder/)
- [ ] EasyGene
- [ ] ORPHEUS
- [ ] GLIMER3
- [ ] Prodigal - Pyrodigal
- [ ] PHANOTATE
- [ ] k-mer based gene finders (?)
- [ ] Augustus (?)

### Non-coding genes (RNA)

- [ ] Infernal
- [ ] tRNAscan

## Contributing

## Citing

See [`CITATION.bib`](CITATION.bib) for the relevant reference(s).
