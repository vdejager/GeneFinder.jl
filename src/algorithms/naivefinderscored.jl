
# uses _locationiterator
export naivefinderscored, isnaivecoding



@doc raw"""
    naivefinderscored(sequence::NucleicSeqOrView{DNAAlphabet{N}}; alternative_start=false, min_len=6) where {N}

Find open reading frames (ORFs) in a nucleic acid sequence using a naive scoring algorithm. In this method the scoring is a log-odds ratio score defines as:

```math
S(x) = \sum_{i=1}^{L} \beta_{x_{i}x} = \sum_{i=1} \log \frac{a^{\mathscr{m}_{1}}_{i-1} x_i}{a^{\mathscr{m}_{2}}_{i-1} x_i}
```

## Arguments
- `sequence`: The nucleic acid sequence to search for ORFs.
- `alternative_start`: A boolean indicating whether to consider alternative start codons. Default is `false`.
- `min_len`: The minimum length of an ORF to be considered. Default is `6`.

## Returns
A sorted vector of `ORF` objects representing the identified open reading frames.

"""
function naivefinderscored(
    sequence::NucleicSeqOrView{DNAAlphabet{N}};
    alternative_start::Bool = false,
    min_len::Int64 = 6
) where {N}
    seqlen = length(sequence)
    framedict = Dict(0 => 3, 1 => 1, 2 => 2)
    orfs = Vector{ORF}()

    for strand in ('+', '-')
        seq = strand == '-' ? reverse_complement(sequence) : sequence

        @inbounds for location in @views _locationiterator(seq; alternative_start)
            if length(location) >= min_len
                frame = strand == '+' ? framedict[location.start % 3] : framedict[(seqlen - location.stop + 1) % 3]
                start = strand == '+' ? location.start : seqlen - location.stop + 1
                stop = start + length(location) - 1
                score = log_odds_ratio_score(sequence[start:stop], ECOLICDS)
                push!(orfs, ORF(start:stop, strand, frame, score))
            end
        end
    end
    return sort(orfs)
end

@doc raw"""
    isnaivecoding(
        sequence::LongSequence{DNAAlphabet{4}};
        codingmodel::BioMarkovChain,
        noncodingmodel::BioMarkovChain,
        η::Float64 = 1e-5
        )

Check if a given DNA sequence is likely to be coding based on a log-odds ratio.
    The log-odds ratio is a statistical measure used to assess the likelihood of a sequence being coding or non-coding. It compares the probability of the sequence generated by a coding model to the probability of the sequence generated by a non-coding model. If the log-odds ratio exceeds a given threshold (`η`), the sequence is considered likely to be coding.
    It is formally described as a decision rule:

```math
S(X) = \log \left( \frac{{P_C(X_1=i_1, \ldots, X_T=i_T)}}{{P_N(X_1=i_1, \ldots, X_T=i_T)}} \right) \begin{cases} > \eta & \Rightarrow \text{{coding}} \\ < \eta & \Rightarrow \text{{noncoding}} \end{cases}
```

# Arguments
- `sequence::NucleicSeqOrView{DNAAlphabet{N}}`: The DNA sequence to be evaluated.

## Keyword Arguments
- `codingmodel::BioMarkovChain`: The transition model for coding regions, (default: `ECOLICDS`).
- `noncodingmodel::BioMarkovChain`: The transition model for non-coding regions, (default: `ECOLINOCDS`)
- `η::Float64 = 1e-5`: The threshold value (eta) for the log-odds ratio (default: 1e-5).

# Returns
- `true` if the sequence is likely to be coding.
- `false` if the sequence is likely to be non-coding.

# Raises
- `ErrorException`: if the length of the sequence is not divisible by 3.
- `ErrorException`: if the sequence contains a premature stop codon.

# Example

```
sequence = dna"ATGGCATCTAG"
iscoding(sequence)  # Returns: true or false
```
"""
function isnaivecoding(
    sequence::NucleicSeqOrView{DNAAlphabet{N}};
    codingmodel::BioMarkovChain = ECOLICDS,
    noncodingmodel::BioMarkovChain = ECOLINOCDS,
    η::Float64 = 1e-5
) where {N}
    pcoding = dnaseqprobability(sequence, codingmodel)
    pnoncoding = dnaseqprobability(sequence, noncodingmodel)

    logodds = log(pcoding / pnoncoding)

    length(sequence) % 3 == 0 || error("The sequence is not divisible by 3")

    !hasprematurestop(sequence) || error("There is a premature stop codon in the sequence")

    if logodds > η
        return true
    else
        false
    end
end