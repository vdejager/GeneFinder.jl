# export hasprematurestop
# General purposes methods supporting main functions

"""
    hasprematurestop(sequence::LongNucOrView{4})::Bool

Determine whether the `sequence` of type `LongSequence{DNAAlphabet{4}}` contains a premature stop codon.

Returns a boolean indicating whether the `sequence` has more than one stop codon.
"""
function hasprematurestop(sequence::NucleicSeqOrView{DNAAlphabet{N}})::Bool where {N}
    
    stopcodons = [LongDNA{4}("TAA"), LongDNA{4}("TAG"), LongDNA{4}("TGA")]  # Create a set of stop codons
    
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

@doc raw"""
    iscoding(
        sequence::LongSequence{DNAAlphabet{4}}, 
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
- `sequence::LongSequence{DNAAlphabet{4}}`: The DNA sequence to be evaluated.
- `codingmodel::BioMarkovChain`: The transition model for coding regions.
- `noncodingmodel::BioMarkovChain`: The transition model for non-coding regions.
- `η::Float64 = 1e-5`: The threshold value (eta) for the log-odds ratio (default: 1e-5).

# Returns
- `true` if the sequence is likely to be coding.
- `false` if the sequence is likely to be non-coding.

# Raises
- `ErrorException`: if the length of the sequence is not divisible by 3.
- `ErrorException`: if the sequence contains a premature stop codon.

# Example

```
sequence = LondDNA("ATGGCATCTAG")
codingmodel = BioMarkovChain()
noncodingmodel = BioMarkovChain()
iscoding(sequence, codingmodel, noncodingmodel)  # Returns: true
```
"""
# function iscoding(
#     sequence::LongNucOrView{4},
#     codingmodel::BioMarkovChain,
#     noncodingmodel::BioMarkovChain,
#     η::Float64 = 1e-5
# )
#     pcoding = dnaseqprobability(sequence, codingmodel)
#     pnoncoding = dnaseqprobability(sequence, noncodingmodel)

#     logodds = log(pcoding / pnoncoding)

#     length(sequence) % 3 == 0 || error("The sequence is not divisible by 3")

#     !hasprematurestop(sequence) || error("There is a premature stop codon in the sequence")

#     if logodds > η
#         return true
#     else
#         false
#     end
# end