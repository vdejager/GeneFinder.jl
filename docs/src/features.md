## Scoring ORFs

The `ORFI` type is designed to be flexible and can store various types of information about ORFs. A very neat feature is that stores a view of the sequence that the ORF represents. Since the the ORFI sequence is stored in the struct, then any method that can be applied to a sequence can be applied to the ORF sequence. This is useful for scoring the ORFs by overloading a method that calculates a score for a `BioSequence`. For instance the `lors` function from the [BioMarkovChains.jl](https://camilogarciabotero.github.io/BioMarkovChains.jl/dev/) package can be used to calculate a score of the ORFs predicted for the phi genome.

Take the following example:

```julia
phi = dna"GTGTGAGGTTATAACGCCGAAGCGGTAAAAATTTTAATTTTTGCCGCTGAGGGGTTGACCAAGCGAAGCGCGGTAGGTTTTCTGCTTAGGAGTTTAATCATGTTTCAGACTTTTATTTCTCGCCATAATTCAAACTTTTTTTCTGATAAGCTGGTTCTCACTTCTGTTACTCCAGCTTCTTCGGCACCTGTTTTACAGACACCTAAAGCTACATCGTCAACGTTATATTTTGATAGTTTGACGGTTAATGCTGGTAATGGTGGTTTTCTTCATTGCATTCAGATGGATACATCTGTCAACGCCGCTAATCAGGTTGTTTCTGTTGGTGCTGATATTGCTTTTGATGCCGACCCTAAATTTTTTGCCTGTTTGGTTCGCTTTGAGTCTTCTTCGGTTCCGACTACCCTCCCGACTGCCTATGATGTTTATCCTTTGAATGGTCGCCATGATGGTGGTTATTATACCGTCAAGGACTGTGTGACTATTGACGTCCTTCCCCGTACGCCGGGCAATAACGTTTATGTTGGTTTCATGGTTTGGTCTAACTTTACCGCTACTAAATGCCGCGGATTGGTTTCGCTGAATCAGGTTATTAAAGAGATTATTTGTCTCCAGCCACTTAAGTGAGGTGATTTATGTTTGGTGCTATTGCTGGCGGTATTGCTTCTGCTCTTGCTGGTGGCGCCATGTCTAAATTGTTTGGAGGCGGTCAAAAAGCCGCCTCCGGTGGCATTCAAGGTGATGTGCTTGCTACCGATAACAATACTGTAGGCATGGGTGATGCTGGTATTAAATCTGCCATTCAAGGCTCTAATGTTCCTAACCCTGATGAGGCCGCCCCTAGTTTTGTTTCTGGTGCTATGGCTAAAGCTGGTAAAGGACTTCTTGAAGGTACGTTGCAGGCTGGCACTTCTGCCGTTTCTGATAAGTTGCTTGATTTGGTTGGACTTGGTGGCAAGTCTGCCGCTGATAAAGGAAAGGATACTCGTGATTATCTTGCTGCTGCATTTCCTGAGCTTAATGCTTGGGAGCGTGCTGGTGCTGATGCTTCCTCTGCTGGTATGGTTGACGCCGGATTTGAGAATCAAAAAGAGCTTACTAAAATGCAACTGGACAATCAGAAAGAGATTGCCGAGATGCAAAATGAGACTCAAAAAGAGATTGCTGGCATTCAGTCGGCGACTTCACGCCAGAATACGAAAGACCAGGTATATGCACAAAATGAGATGCTTGCTTATCAACAGAAGGAGTCTACTGCTCGCGTTGCGTCTATTATGGAAAACACCAATCTTTCCAAGCAACAGCAGGTTTCCGAGATTATGCGCCAAATGCTTACTCAAGCTCAAACGGCTGGTCAGTATTTTACCAATGACCAAATCAAAGAAATGACTCGCAAGGTTAGTGCTGAGGTTGACTTAGTTCATCAGCAAACGCAGAATCAGCGGTATGGCTCTTCTCATATTGGCGCTACTGCAAAGGATATTTCTAATGTCGTCACTGATGCTGCTTCTGGTGTGGTTGATATTTTTCATGGTATTGATAAAGCTGTTGCCGATACTTGGAACAATTTCTGGAAAGACGGTAAAGCTGATGGTATTGGCTCTAATTTGTCTAGGAAATAACCGTCAGGATTGACACCCTCCCAATTGTATGTTTTCATGCCTCCAAATCTTGGAGGCTTTTTTATGGTTCGTTCTTATTACCCTTCTGAATGTCACGCTGATTATTTTGACTTTGAGCGTATCGAGGCTCTTAAACCTGCTATTGAGGCTTGTGGCATTTCTACTCTTTCTCAATCCCCAATGCTTGGCTTCCATAAGCAGATGGATAACCGCATCAAGCTCTTGGAAGAGATTCTGTCTTTTCGTATGCAGGGCGTTGAGTTCGATAATGGTGATATGTATGTTGACGGCCATAAGGCTGCTTCTGACGTTCGTGATGAGTTTGTATCTGTTACTGAGAAGTTAATGGATGAATTGGCACAATGCTACAATGTGCTCCCCCAACTTGATATTAATAACACTATAGACCACCGCCCCGAAGGGGACGAAAAATGGTTTTTAGAGAACGAGAAGACGGTTACGCAGTTTTGCCGCAAGCTGGCTGCTGAACGCCCTCTTAAGGATATTCGCGATGAGTATAATTACCCCAAAAAGAAAGGTATTAAGGATGAGTGTTCAAGATTGCTGGAGGCCTCCACTATGAAATCGCGTAGAGGCTTTGCTATTCAGCGTTTGATGAATGCAATGCGACAGGCTCATGCTGATGGTTGGTTTATCGTTTTTGACACTCTCACGTTGGCTGACGACCGATTAGAGGCGTTTTATGATAATCCCAATGCTTTGCGTGACTATTTTCGTGATATTGGTCGTATGGTTCTTGCTGCCGAGGGTCGCAAGGCTAATGATTCACACGCCGACTGCTATCAGTATTTTTGTGTGCCTGAGTATGGTACAGCTAATGGCCGTCTTCATTTCCATGCGGTGCACTTTATGCGGACACTTCCTACAGGTAGCGTTGACCCTAATTTTGGTCGTCGGGTACGCAATCGCCGCCAGTTAAATAGCTTGCAAAATACGTGGCCTTATGGTTACAGTATGCCCATCGCAGTTCGCTACACGCAGGACGCTTTTTCACGTTCTGGTTGGTTGTGGCCTGTTGATGCTAAAGGTGAGCCGCTTAAAGCTACCAGTTATATGGCTGTTGGTTTCTATGTGGCTAAATACGTTAACAAAAAGTCAGATATGGACCTTGCTGCTAAAGGTCTAGGAGCTAAAGAATGGAACAACTCACTAAAAACCAAGCTGTCGCTACTTCCCAAGAAGCTGTTCAGAATCAGAATGAGCCGCAACTTCGGGATGAAAATGCTCACAATGACAAATCTGTCCACGGAGTGCTTAATCCAACTTACCAAGCTGGGTTACGACGCGACGCCGTTCAACCAGATATTGAAGCAGAACGCAAAAAGAGAGATGAGATTGAGGCTGGGAAAAGTTACTGTAGCCGACGTTTTGGCGGCGCAACCTGTGACGACAAATCTGCTCAAATTTATGCGCGCTTCGATAAAAATGATTGGCGTATCCAACCTGCAGAGTTTTATCGCTTCCATGACGCAGAAGTTAACACTTTCGGATATTTCTGATGAGTCGAAAAATTATCTTGATAAAGCAGGAATTACTACTGCTTGTTTACGAATTAAATCGAAGTGGACTGCTGGCGGAAAATGAGAAAATTCGACCTATCCTTGCGCAGCTCGAGAAGCTCTTACTTTGCGACCTTTCGCCATCAACTAACGATTCTGTCAAAAACTGACGCGTTGGATGAGGAGAAGTGGCTTAATATGCTTGGCACGTTCGTCAAGGACTGGTTTAGATATGAGTCACATTTTGTTCATGGTAGAGATTCTCTTGTTGACATTTTAAAAGAGCGTGGATTACTATCTGAGTCCGATGCTGTTCAACCACTAATAGGTAAGAAATCATGAGTCAAGTTACTGAACAATCCGTACGTTTCCAGACCGCTTTGGCCTCTATTAAGCTCATTCAGGCTTCTGCCGTTTTGGATTTAACCGAAGATGATTTCGATTTTCTGACGAGTAACAAAGTTTGGATTGCTACTGACCGCTCTCGTGCTCGTCGCTGCGTTGAGGCTTGCGTTTATGGTACGCTGGACTTTGTGGGATACCCTCGCTTTCCTGCTCCTGTTGAGTTTATTGCTGCCGTCATTGCTTATTATGTTCATCCCGTCAACATTCAAACGGCCTGTCTCATCATGGAAGGCGCTGAATTTACGGAAAACATTATTAATGGCGTCGAGCGTCCGGTTAAAGCCGCTGAATTGTTCGCGTTTACCTTGCGTGTACGCGCAGGAAACACTGACGTTCTTACTGACGCAGAAGAAAACGTGCGTCAAAAATTACGTGCGGAAGGAGTGATGTAATGTCTAAAGGTAAAAAACGTTCTGGCGCTCGCCCTGGTCGTCCGCAGCCGTTGCGAGGTACTAAAGGCAAGCGTAAAGGCGCTCGTCTTTGGTATGTAGGTGGTCAACAATTTTAATTGCAGGGGCTTCGGCCCCTTACTTGAGGATAAATTATGTCTAATATTCAAACTGGCGCCGAGCGTATGCCGCATGACCTTTCCCATCTTGGCTTCCTTGCTGGTCAGATTGGTCGTCTTATTACCATTTCAACTACTCCGGTTATCGCTGGCGACTCCTTCGAGATGGACGCCGTTGGCGCTCTCCGTCTTTCTCCATTGCGTCGTGGCCTTGCTATTGACTCTACTGTAGACATTTTTACTTTTTATGTCCCTCATCGTCACGTTTATGGTGAACAGTGGATTAAGTTCATGAAGGATGGTGTTAATGCCACTCCTCTCCCGACTGTTAACACTACTGGTTATATTGACCATGCCGCTTTTCTTGGCACGATTAACCCTGATACCAATAAAATCCCTAAGCATTTGTTTCAGGGTTATTTGAATATCTATAACAACTATTTTAAAGCGCCGTGGATGCCTGACCGTACCGAGGCTAACCCTAATGAGCTTAATCAAGATGATGCTCGTTATGGTTTCCGTTGCTGCCATCTCAAAAACATTTGGACTGCTCCGCTTCCTCCTGAGACTGAGCTTTCTCGCCAAATGACGACTTCTACCACATCTATTGACATTATGGGTCTGCAAGCTGCTTATGCTAATTTGCATACTGACCAAGAACGTGATTACTTCATGCAGCGTTACCATGATGTTATTTCTTCATTTGGAGGTAAAACCTCTTATGACGCTGACAACCGTCCTTTACTTGTCATGCGCTCTAATCTCTGGGCATCTGGCTATGATGTTGATGGAACTGACCAAACGTCGTTAGGCCAGTTTTCTGGTCGTGTTCAACAGACCTATAAACATTCTGTGCCGCGTTTCTTTGTTCCTGAGCATGGCACTATGTTTACTCTTGCGCTTGTTCGTTTTCCGCCTACTGCGACTAAAGAGATTCAGTACCTTAACGCTAAAGGTGCTTTGACTTATACCGATATTGCTGGCGACCCTGTTTTGTATGGCAACTTGCCGCCGCGTGAAATTTCTATGAAGGATGTTTTCCGTTCTGGTGATTCGTCTAAGAAGTTTAAGATTGCTGAGGGTCAGTGGTATCGTTATGCGCCTTCGTATGTTTCTCCTGCTTATCACCTTCTTGAAGGCTTCCCATTCATTCAGGAACCGCCTTCTGGTGATTTGCAAGAACGCGTACTTATTCGCCACCATGATTATGACCAGTGTTTCCAGTCCGTTCAGTTGTTGCAGTGGAATAGTCAGGTTAAATTTAATGTGACCGTTTATCGCAATCTGCCGACCACTCGCGATTCAATCATGACTTCGTGATAAAAGATTGA"

phiorfs = findorfs(phi, finder=NaiveFinder, minlen=75)

124-element Vector{ORFI{4, NaiveFinder}}:
 ORFI{NaiveFinder}(9:101, '-', 3)
 ORFI{NaiveFinder}(100:627, '+', 1)
 ORFI{NaiveFinder}(223:447, '-', 1)
 ORFI{NaiveFinder}(248:436, '+', 2)
 ORFI{NaiveFinder}(257:436, '+', 2)
 ORFI{NaiveFinder}(283:627, '+', 1)
 ORFI{NaiveFinder}(344:436, '+', 2)
 ORFI{NaiveFinder}(532:627, '+', 1)
 ORFI{NaiveFinder}(636:1622, '+', 3)
 ORFI{NaiveFinder}(687:1622, '+', 3)
 ORFI{NaiveFinder}(774:1622, '+', 3)
 ORFI{NaiveFinder}(781:1389, '+', 1)
 ORFI{NaiveFinder}(814:1389, '+', 1)
 ORFI{NaiveFinder}(829:1389, '+', 1)
 ORFI{NaiveFinder}(861:1622, '+', 3)
 ⋮
 ORFI{NaiveFinder}(4671:5375, '+', 3)
 ORFI{NaiveFinder}(4690:4866, '+', 1)
 ORFI{NaiveFinder}(4728:5375, '+', 3)
 ORFI{NaiveFinder}(4741:4866, '+', 1)
 ORFI{NaiveFinder}(4744:4866, '+', 1)
 ORFI{NaiveFinder}(4777:4866, '+', 1)
 ORFI{NaiveFinder}(4806:5375, '+', 3)
 ORFI{NaiveFinder}(4863:5258, '-', 3)
 ORFI{NaiveFinder}(4933:5019, '+', 1)
 ORFI{NaiveFinder}(4941:5375, '+', 3)
 ORFI{NaiveFinder}(5082:5375, '+', 3)
 ORFI{NaiveFinder}(5089:5325, '+', 1)
 ORFI{NaiveFinder}(5122:5202, '-', 1)
 ORFI{NaiveFinder}(5152:5325, '+', 1)
 ORFI{NaiveFinder}(5164:5325, '+', 1)
```

We can now calculate a score using the `lors` (`logg_odds_ratio_score`) scoring scheme (see [lors](https://github.com/camilogarciabotero/BioMarkovChains.jl/blob/533e53d97cf5951f1ca050454bce1423ec8d7c36/src/transitions.jl#L179) from the [BioMarkovChains.jl](https://camilogarciabotero.github.io/BioMarkovChains.jl/dev/) package).

```julia
lors.(phiorfs)

204-element Vector{Float64}:
  -3.002461366087374
   0.1063473191426695
 -10.814621287968222
   0.0015932011596656963
  -2.635307521118871
  -5.344187934894264
  -1.35785984913167
  -1.316724559874126
  -1.796631200562138
   0.4895532892313278
  -3.2651518608269856
  -1.4019264441082822
  -0.32264884956233186
  -0.6695213802037128
   1.1023617306499074
   ⋮
  -5.40624241726446
  -0.8080572222081075
  -5.571494087742448
   0.8307089386780881
  -4.882156920421228
  -5.639670353834974
  -0.8764121443326865
  -4.308687693802273
  -4.459423419810693
   0.5077309777574499
  -2.2808971022330824
  -2.138892671183213
   0.6106494455192994
   1.1981063545591812
   0.7566845754226063
```

Briefly, a sequence of DNA could be scored using a Markov model of the transition probabilities of a known sequence. This could be done using a *log-odds ratio score*, which is the logarithm of the ratio of the transition probabilities of the sequence given two models. The log-odds ratio score is defined as:

```math
\begin{align}
S(x) = \sum_{i=1}^{L} \beta_{x_{i}x} = \sum_{i=1} \log \frac{a^{\mathscr{m}_{1}}_{i-1} x_i}{a^{\mathscr{m}_{2}}_{i-1} x_i}
\end{align}
```

Where the ``a^{\mathscr{m}_{1}}_{i-1} x_i`` is the transition probability of the first model (in this case the calculated for the given sequence) from the state ``x_{i-1}`` to the state ``x_i`` and ``a^{\mathscr{m}_{2}}_{i-1} x_i`` is the transition probability of the second model from the state ``x_{i-1}`` to the state ``x_i``. The score is the sum of the log-odds ratio of the transition probabilities of the sequence given the two models.

In the `lors` case, the two models are the coding and non-coding models of the *E. coli* genome. The coding model is a Markov model of the transition probabilities of the coding regions of the *E. coli* genome, and the non-coding model is a Markov model of the transition probabilities of the non-coding regions of the *E. coli* genome.

## Analysing Lambda ORFs

As mentioned above the `lors` calculates the log odds ratio of the ORFI sequence given two Markov models (by default: [ECOLICDS](https://github.com/camilogarciabotero/BioMarkovChains.jl/blob/533e53d97cf5951f1ca050454bce1423ec8d7c36/src/models.jl#L3) and [ECOLINOCDS](https://github.com/camilogarciabotero/BioMarkovChains.jl/blob/533e53d97cf5951f1ca050454bce1423ec8d7c36/src/models.jl#L16)), one for the coding region and one for the non-coding region. By default the `lors` function return the base 2 logarithm of the odds ratio, so it is analogous to the bits of information that the ORFI sequence is coding.

Now we can even analyse how is the distribution of the ORFIs' scores as a function of their lengths compared to random sequences.

```julia
using FASTX, CairoMakie

lambdafile = "test/data/NC_001416.1.fasta"

# read the lambda genome as a `BioSequence`
open(FASTA.Reader, lambdafile) do reader
    lambdaseq = FASTX.sequence(LongDNA{4}, collect(reader)[1])
end

# find the ORFs in the lambda genome
lambaorfs = findorfs(lambdaseq, finder=NaiveFinder, minlen=100)

lambdascores = lors.(lambaorfs)
lambdalengths = length.(lambaorfs)

## get some random sequences of variable lengths
vseqs = LongDNA[]
for i in 1:708
    push!(vseqs, randdnaseq(rand(100:2500)))
end

## get the lengths and scores of the random generated sequences
randlengths = length.(vseqs)
randscores = lors.(vseqs)

## plot the scores as a function of the lengths
f = Figure()
ax = Axis(f[1, 1], xlabel="Length", ylabel="Log-odds ratio (Bits)")

scatter!(ax,
    randlengths,
    randscores,
    marker = :circle, 
    markersize = 6, 
    color = :black, 
    label = "Random sequences"
)
scatter!(ax,
    lambdalengths, 
    lambdascores, 
    marker = :rect, 
    markersize = 6, 
    color = :blue, 
    label = "Lambda ORFs"
)

axislegend(ax)

f
```

![](assets/lors-lambda.png)

What this plot shows is that the ORFs in the lambda genome have a higher scores than random sequences of the same length. The score is a measure of how likely a sequence given the coding model is compared to the non-coding model. In other words, the higher the score the more likely the sequence is coding. So, the plot shows that the ORFs in the lambda genome are more likely to be coding regions than random sequences. It also shows that the longer the ORFI the higher the score, which is expected since longer ORFs are more likely to be coding regions than shorter ones.
