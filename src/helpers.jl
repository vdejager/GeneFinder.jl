# General purposes methods supporting main functions
"""
    fasta_to_dna(input::String)

Converts a FASTA formatted file (even if it is a multi-fasta) to an array of `LongSequence{DNAAlphabet{4}}` objects.
"""
function fasta_to_dna(input::String)::Vector{LongSequence{DNAAlphabet{4}}{4}}
    FASTAReader(open(input)) do reader
        return [LongSequence{DNAAlphabet{4}}(sequence(record)) for record in reader]
    end
end

"""
    nucleotidefreqs(sequence::LongSequence{DNAAlphabet{4}}) -> Dict{DNA, Float64}

Calculate the frequency of each nucleotide in a DNA sequence.

# Arguments
- `sequence::LongSequence{DNAAlphabet{4}}`: A `LongSequence{DNAAlphabet{4}}` sequence.

# Returns
A dictionary with each nucleotide in the sequence as a key, and its frequency as a value.

# Example
``` 
seq = dna"CCTCCCGGACCCTGGGCTCGGGAC"

nucleotidefreqs(seq)

Dict{DNA, Float64} with 4 entries:
DNA_T => 0.125
DNA_A => 0.0833333
DNA_G => 0.333333
DNA_C => 0.458333
```
"""
function nucleotidefreqs(sequence::LongNucOrView{4})::Dict{DNA,Float64}
    counts = countmap(sequence)
    T = length(sequence)
    F = Dict(i => counts[i] / T for i in keys(counts))
    return F
end

"""
    hasprematurestop(sequence::LongNucOrView{4})::Bool

Determine whether the `sequence` of type `LongSequence{DNAAlphabet{4}}` contains a premature stop codon.

Returns a boolean indicating whether the `sequence` has more than one stop codon.
"""
function hasprematurestop(sequence::LongNucOrView{4})::Bool
    
    stopcodons = [dna"TAA", dna"TAG", dna"TGA"]  # Create a set of stop codons
    
    length(sequence) % 3 == 0 || error("The sequence is not divisible by 3")
    
    occursin(biore"T(AG|AA|GA)"dna, sequence[end-2:end]) || error("There is no stop codon at the end of the sequence")

    @inbounds for i in 1:3:length(sequence) - 4
        codon = sequence[i:i+2]
        if codon in stopcodons
            return true
        end
    end

    return false
end

"""
    dinucleotides(sequence::LongNucOrView{4})

Compute the transition counts of each dinucleotide in a given DNA sequence.

# Arguments
- `sequence::LongSequence{DNAAlphabet{4}}`: a `LongSequence{DNAAlphabet{4}}` object representing the DNA sequence.

# Keywords

- `extended_alphabet::Bool=false`: If true will pass the extended alphabet of DNA to search

# Returns
A dictionary with keys being `LongSequence{DNAAlphabet{4}}` objects representing
the dinucleotides, and values being the number of occurrences of each dinucleotide
in the sequence.

# Example
```
seq = dna"AGCTAGCTAGCT"

dinucleotides(seq)

Dict{LongSequence{DNAAlphabet{4}}, Int64} with 16 entries:
  GG => 0
  TC => 0
  GC => 3
  CG => 0
  CC => 0
  AG => 3
  TT => 0
  AC => 0
  TA => 2
  GT => 0
  GA => 0
  CT => 3
  CA => 0
  AT => 0
  AA => 0
  TG => 0
```
"""
function dinucleotides(sequence::LongNucOrView{4}; extended_alphabet::Bool = false)
    A = extended_alphabet ? collect(alphabet(DNA)) : [DNA_A, DNA_C, DNA_G, DNA_T]
    dinucleotides = vec([LongSequence{DNAAlphabet{4}}([n1, n2]) for n1 in A, n2 in A])

    counts = zeros(Int64, length(dinucleotides))
    for (index, pair) in enumerate(dinucleotides)
        count = 0
        @inbounds for i in 1:length(sequence)-1
            if sequence[i] == pair[1] && sequence[i+1] == pair[2]
                count += 1
            end
        end
        counts[index] = count
    end

    pairsdict = Dict{LongSequence{DNAAlphabet{4}},Int64}()
    for (index, pair) in enumerate(dinucleotides)
        pairsdict[pair] = counts[index]
    end

    return pairsdict
end

function codons(sequence::LongNucOrView{4})
    A = [DNA_A, DNA_C, DNA_G, DNA_T]
    trinucleotides = vec([LongSequence{DNAAlphabet{4}}([n1, n2, n3]) for n1 in A, n2 in A, n3 in A])

    # counts = zeros(Int64, length(trinucleotides))
    counts = Array{Int64,1}(undef, 64)
    for (index, trio) in enumerate(trinucleotides)
        count = 0
        @inbounds for i in 1:length(sequence)-2
            if sequence[i:i+2] == trio
                count += 1
            end
        end
        counts[index] = count
    end

    codondict = Dict{LongSequence{DNAAlphabet{4}},Int64}()
    for (index, codon) in enumerate(trinucleotides)
        codondict[codon] = counts[index]
    end

    return codondict
end

"""
    transition_count_matrix(sequence::LongSequence{DNAAlphabet{4}})

Compute the transition count matrix (TCM) of a given DNA sequence.

# Arguments
- `sequence::LongSequence{DNAAlphabet{4}}`: a `LongSequence{DNAAlphabet{4}}` object representing the DNA sequence.

# Keywords

- `extended_alphabet::Bool=false`: If true will pass the extended alphabet of DNA to search

# Returns
A `TCM` object representing the transition count matrix of the sequence.

# Example
```
seq = dna"AGCTAGCTAGCT"

tcm = transition_count_matrix(seq)

GeneFinder.TCM{Dict{DNA, Int64}, Matrix{Int64}:
   A C G T
A  0 0 3 0
C  0 0 0 3
G  0 3 0 0
T  2 0 0 0

```
 """
function transition_count_matrix(
    sequence::LongNucOrView{4};
    extended_alphabet::Bool = false
)

    transitions = dinucleotides(sequence; extended_alphabet)

    A = extended_alphabet ? collect(alphabet(DNA)) : [DNA_A, DNA_C, DNA_G, DNA_T]

    dtcm = TCM(A)

    for (dinucleotide, count) in transitions
        nucleotide1 = dinucleotide[1]
        nucleotide2 = dinucleotide[2]
        i = dtcm.order[nucleotide1]
        j = dtcm.order[nucleotide2]
        dtcm.counts[i, j] = count
    end

    return dtcm
end

@doc raw"""
    transition_probability_matrix(sequence::LongSequence{DNAAlphabet{4}})

Compute the transition probability matrix (TPM) of a given DNA sequence. Formally it construct `` \hat{A}`` where: 
```math
a_{ij} = P(X_t = j \mid X_{t-1} = i) = \frac{{P(X_{t-1} = i, X_t = j)}}{{P(X_{t-1} = i)}}
```

# Arguments
- `sequence::LongSequence{DNAAlphabet{4}}`: a `LongSequence{DNAAlphabet{4}}` object representing the DNA sequence.
- `n::Int64=1`: The order of the Markov model. That is the `` \hat{A}^{n}``

# Keywords

- `extended_alphabet::Bool=false`: If true will pass the extended alphabet of DNA to search

# Returns
A `TPM` object representing the transition probability matrix of the sequence.

# Example
```
seq = dna"AGCTAGCTAGCT"

tpm = transition_probability_matrix(seq)

GeneFinder.tpm{Dict{DNA, Int64}, Matrix{Float64}:
   A   C   G   T
A  0.0 0.0 1.0 0.0
C  0.0 0.0 0.0 1.0
G  0.0 1.0 0.0 0.0
T  1.0 0.0 0.0 0.0
```
"""
function transition_probability_matrix(
    sequence::LongNucOrView{4},
    n::Int64 = 1;
    extended_alphabet::Bool = false
)
    dtcm = transition_count_matrix(sequence; extended_alphabet)
    rowsums = sum(dtcm.counts, dims = 2)
    freqs = dtcm.counts ./ rowsums

    freqs[isinf.(freqs)] .= 0.0
    freqs[isnan.(freqs)] .= 0.0

    return TPM(dtcm.order, freqs^(n))
end

@testitem "tpm" begin
    using BioSequences, GeneFinder
    seq = dna"CCTCCCGGACCCTGGGCTCGGGAC"
    tpm = transition_probability_matrix(seq)

    @test round.(tpm.probabilities, digits = 3) == [0.0 1.0 0.0 0.0; 0.0 0.5 0.2 0.3; 0.25 0.125 0.625 0.0; 0.0 0.667 0.333 0.0]
end

function initial_distribution(sequence::LongNucOrView{4}) ## π̂ estimates of the initial probabilies
    initials = Vector{Float64}()
    counts = transition_count_matrix(sequence).counts
    initials = sum(counts, dims = 1) ./ sum(counts)
    return initials
end

@doc raw"""
    sequenceprobability(sequence::LongNucOrView{4}, tpm::Matrix{Float64}, initials=Vector{Float64})

Compute the probability of a given sequence using a transition probability matrix and the initial probabilities distributions.

```math
P(X_1 = i_1, \ldots, X_T = i_T) = \pi_{i_1}^{T-1} \prod_{t=1}^{T-1} a_{i_t, i_{t+1}}
```

# Arguments
- `sequence::LongNucOrView{4}`: The input sequence of nucleotides.
- `tpm::Matrix{Float64}`: The transition probability matrix.
- `initials=Vector{Float64}`: Optional initial state probabilities. Default is an empty vector.

# Returns
- `probability::Float64`: The probability of the input sequence.

# Example

```
tpm = transition_probability_matrix(dna"CCTCCCGGACCCTGGGCTCGGGAC")
    
    4×4 Matrix{Float64}:
    0.0   1.0    0.0    0.0
    0.0   0.5    0.2    0.3
    0.25  0.125  0.625  0.0
    0.0   0.667  0.333  0.0

initials = initial_distribution(dna"CCTCCCGGACCCTGGGCTCGGGAC")

    1×4 Matrix{Float64}:
    0.0869565  0.434783  0.347826  0.130435

sequence = dna"CCTG"

    4nt DNA Sequence:
    CCTG

sequenceprobability(sequence, tpm, initials)
    
    0.0217
```
"""
function sequenceprobability(
    sequence::LongNucOrView{4},
    model::TransitionModel
    # tpm::Matrix{Float64},
    # initials::Matrix{Float64}
)

    nucleotideindexes = Dict(DNA_A => 1, DNA_C => 2, DNA_G => 3, DNA_T => 4)

    dinueclotideindexes = Dict(
        dna"AA" => [1, 1],
        dna"AC" => [1, 2],
        dna"AG" => [1, 3],
        dna"AT" => [1, 4],
        dna"CA" => [2, 1],
        dna"CC" => [2, 2],
        dna"CG" => [2, 3],
        dna"CT" => [2, 4],
        dna"GA" => [3, 1],
        dna"GC" => [3, 2],
        dna"GG" => [3, 3],
        dna"GT" => [3, 4],
        dna"TA" => [4, 1],
        dna"TC" => [4, 2],
        dna"TG" => [4, 3],
        dna"TT" => [4, 4],
    )

    init = model.initials[nucleotideindexes[sequence[1]]]

    probability = init

    for t in 1:length(sequence)-1

        pair = LongSequence{DNAAlphabet{4}}([sequence[t], sequence[t+1]])

        i = dinueclotideindexes[pair][1]
        j = dinueclotideindexes[pair][2]

        probability *= model.tpm[i, j]
    end
    return probability
end


@doc raw"""
    iscoding(
        sequence::LongSequence{DNAAlphabet{4}}, 
        codingmodel::TransitionModel, 
        noncodingmodel::TransitionModel,
        η::Float64 = 1e-5
        )

Check if a given DNA sequence is likely to be coding based on a log-odds ratio.
    The log-odds ratio is a statistical measure used to assess the likelihood of a sequence being coding or non-coding. It compares the probability of the sequence generated by a coding model to the probability of the sequence generated by a non-coding model. If the log-odds ratio exceeds a given threshold (`η`), the sequence is considered likely to be coding.
    It is formally described as a decision rule:

```math
S(X) = \log \left( \frac{{P_C(X_1=i_1, \ldots, X_T=i_T)}}{{P_N(X_1=i_1, \ldots, X_T=i_T)}} \right) \begin{cases} > \eta & \Rightarrow \text{{coding}} \\ < \eta & \Rightarrow \text{{noncoding}} \end{cases}
```

# Arguments
- `sequence::LongSequence{DNAAlphabet{4}}`: The DNA sequence to be evaluated.
- `codingmodel::TransitionModel`: The transition model for coding regions.
- `noncodingmodel::TransitionModel`: The transition model for non-coding regions.
- `η::Float64 = 1e-5`: The threshold value for the log-odds ratio (default: 1e-5).

# Returns
- `true` if the sequence is likely to be coding.
- `false` if the sequence is likely to be non-coding.

# Raises
- `ErrorException`: if the length of the sequence is not divisible by 3.
- `ErrorException`: if the sequence contains a premature stop codon.

# Example

```
sequence = LongSequence{DNAAlphabet{4}}("ATGGCATCTAG")
codingmodel = TransitionModel()
noncodingmodel = TransitionModel()
iscoding(sequence, codingmodel, noncodingmodel)  # Returns: true
```
"""
function iscoding(
    sequence::LongNucOrView{4},
    codingmodel::TransitionModel,
    noncodingmodel::TransitionModel,
    η::Float64 = 1e-5
)
    pcoding = sequenceprobability(sequence, codingmodel)
    pnoncoding = sequenceprobability(sequence, noncodingmodel)

    logodds = log(pcoding / pnoncoding)

    length(sequence) % 3 == 0 || error("The sequence is not divisible by 3")

    !hasprematurestop(sequence) || error("There is a premature stop codon in the sequence")

    if logodds > η
        return true
    else
        false
    end
end

function _int_to_dna(index::Int64; extended_alphabet::Bool = false)
    A = extended_alphabet ? collect(alphabet(DNA)) : [DNA_A, DNA_C, DNA_G, DNA_T]
    return LongSequence{DNAAlphabet{4}}([A[index]])
end

function _dna_to_int(nucleotide::DNA; extended_alphabet::Bool = false)
    A = extended_alphabet ? collect(alphabet(DNA)) : [DNA_A, DNA_C, DNA_G, DNA_T]
    return findfirst(nucleotide, LongSequence{DNAAlphabet{4}}(A))
end

function perronfrobenius(sequence::LongNucOrView{4}, n::Int64=1)
    tpm = transition_probability_matrix(sequence, n).probabilities
    pf = transpose(tpm)
    return copy(pf)
end

function generatednaseq(pf::Matrix{Float64}, steps::Int64; extended_alphabet::Bool = false)
    newseq = LongDNA{4}()
    # pf = transpose(tpm) # The Perron-Frobenius matrix
    trajectory = generate(pf, steps)
    for i in trajectory
        newseq = append!(newseq, _int_to_dna(i; extended_alphabet))
    end
    return newseq
end

# """
#     eachcodon(sequence::LongSequence{DNAAlphabet{4}})

# Iterate through the codons in the `sequence` of type `LongSequence{DNAAlphabet{4}}`.

# Returns an iterator yielding `Codon` objects for each codon in the `sequence`.
# """
# function eachcodon(sequence::LongSequence{DNAAlphabet{4}})
#     seqbound = length(sequence) - 2
#     return (sequence[i:i+2] for i = 1:3:seqbound)
# end

# @testitem "eachcodon test" begin
#     using BioSequences

#     seq = dna"ATGGCGTA"

#     @test collect(eachcodon(seq)) == [Codon("ATG"), Codon("GCG")]
# end


# function hasprematurestop(sequence::LongSequence{DNAAlphabet{4}})::Bool
#     stop_codon_count = 0
#     @inbounds for codon in eachcodon(sequence)
#         if codon == dna"TAA" || codon == dna"TAG" || codon == dna"TGA"
#             println("Found stop codon: ", codon)
#             stop_codon_count += 1
#         end
#     end
#     stop_codon_count > 1 
# end


# @testitem "hasprematurestop test" begin
#     using BioSequences

#     seq01 = dna"ATGGCGTA"
#     @test hasprematurestop(seq01) == false

#     seq02 = dna"ATGTCGTAATAA"
#     @test hasprematurestop(seq02) == true
# end

# function count_codons(seq::LongSequence{DNAAlphabet{4}})
#     codons = Vector{Codon}()
#     for i in 1:3:length(seq)
#         if i+2 <= length(seq)
#             codon = Codon(seq[i:i+2])
#             push!(codons, codon)
#         end
#     end
#     codons
# end
