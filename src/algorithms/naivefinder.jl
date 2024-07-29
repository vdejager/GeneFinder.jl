export NaiveFinder

abstract type GeneFinderMethod end

struct NaiveFinder <: GeneFinderMethod end

"""
    _locationiterator(sequence::NucleicSeqOrView{DNAAlphabet{N}}; alternative_start::Bool=false) where {N}

This is an iterator function that uses regular expressions to search the entire ORF (instead of start and stop codons) in a `LongSequence{DNAAlphabet{4}}` sequence.
    It uses an anonymous function that will find the first regularly expressed ORF. Then using this anonymous function it creates an iterator that will apply it until there is no other CDS.

!!! note
    As a note of the implementation we want to expand on how the ORFs are found:

    The expression `(?:[N]{3})*?` serves as the boundary between the start and stop codons. 
    Within this expression, the character class `[N]{3}` captures exactly three occurrences of any character (representing nucleotides using IUPAC codes). 
    This portion functions as the regular codon matches. 
    Since it is enclosed within a non-capturing group `(?:)` and followed by `*?`, it allows for the matching of intermediate codons,
    but with a preference for the smallest number of repetitions. 
    
    In summary, the regular expression `ATG(?:[N]{3})*?T(AG|AA|GA)` identifies patterns that start with "ATG," followed by any number of three-character codons (represented by "N" in the IUPAC code), and ends with a stop codon "TAG," "TAA," or "TGA." This pattern is commonly used to identify potential protein-coding regions within genetic sequences.

    See more about the discussion [here](https://discourse.julialang.org/t/how-to-improve-a-generator-to-be-more-memory-efficient-when-it-is-collected/92932/8?u=camilogarciabotero)

"""
function _locationiterator(
    seq::NucleicSeqOrView{DNAAlphabet{N}};
    alternative_start::Bool = false
) where {N}
    regorf = alternative_start ? biore"NTG(?:[N]{3})*?T(AG|AA|GA)"dna : biore"ATG(?:[N]{3})*?T(AG|AA|GA)"dna
    # regorf = alternative_start ? biore"DTG(?:[N]{3})*?T(AG|AA|GA)"dna : biore"ATG([N]{3})*T(AG|AA|GA)?"dna # an attempt to make it non PCRE non-determinsitic
    finder(x) = findfirst(regorf, seq, first(x) + 1) # + 3
    itr = takewhile(!isnothing, iterated(finder, findfirst(regorf, seq)))
    return itr
end

@doc raw"""
    NaiveFinder(sequence::NucleicSeqOrView{DNAAlphabet{N}}; kwargs...) -> Vector{ORF} where {N}

A simple implementation that finds ORFs in a DNA sequence.

The `NaiveFinder` method takes a LongSequence{DNAAlphabet{4}} sequence and returns a Vector{ORF} containing the ORFs found in the sequence. 
    It searches entire regularly expressed CDS, adding each ORF it finds to the vector. The function also searches the reverse complement of the sequence, so it finds ORFs on both strands.
        Extending the starting codons with the `alternative_start = true` will search for ATG, GTG, and TTG.
    Some studies have shown that in *E. coli* (K-12 strain), ATG, GTG and TTG are used 83 %, 14 % and 3 % respectively.
!!! note
    This function has neither ORFs scoring scheme by default nor length constraints. Thus it might consider `aa"M*"` a posible encoding protein from the resulting ORFs.

 
# Required Arguments

- `sequence::NucleicSeqOrView{DNAAlphabet{N}}`: The nucleic acid sequence to search for ORFs.

# Keywords Arguments

- `alternative_start::Bool`: If true will pass the extended start codons to search. This will increase 3x the execution time. Default is `false`.
- `minlen::Int64=6`:  Length of the allowed ORF. Default value allow `aa"M*"` a posible encoding protein from the resulting ORFs.
- `scheme::Function`: The scoring scheme to use for scoring the sequence from the ORF. Default is `nothing`.

!!! note
    As the scheme is generally a scoring function that at least requires a sequence, one simple scheme is the log-odds ratio score. This score is a log-odds ratio that compares the probability of the sequence generated by a coding model to the probability of the sequence generated by a non-coding model:
    ```math
    S(x) = \sum_{i=1}^{L} \beta_{x_{i}x} = \sum_{i=1} \log \frac{a^{\mathscr{m}_{1}}_{i-1} x_i}{a^{\mathscr{m}_{2}}_{i-1} x_i}
    ```
    If the log-odds ratio exceeds a given threshold (`η`), the sequence is considered likely to be coding. See [`lordr`](@ref) for more information about coding creteria.

"""
function NaiveFinder(
    seq::NucleicSeqOrView{DNAAlphabet{N}};
    alternative_start::Bool = false,
    minlen::Int64 = 6,
    kwargs...
) where {N}
    seqlen = length(seq)
    orfs = Vector{ORF{N,NaiveFinder}}()
    
    # Handle the sequence name
    seqname = _varname(seq)
    if seqname === nothing
        seqname = "unnamedseq"
    end

    @inbounds for strand in (STRAND_POS, STRAND_NEG)
        s = strand == STRAND_NEG ? reverse_complement(seq) : seq
        @inbounds for location in @views _locationiterator(s; alternative_start)
            if length(location) >= minlen
                #main fields
                start = strand == STRAND_POS ? location.start : seqlen - location.stop + 1
                stop = start + length(location) - 1
                frm = start % 3 == 0 ? 3 : start % 3
                fts = NamedTuple()

                push!(orfs, ORF{N,NaiveFinder}(seqname, start, stop, strand, frm, @view(s[location.start:location.stop]), fts)) #seq scheme
            end
        end
    end
    return sort!(orfs)
end

# oseq = strand == STRAND_POS ? @view(seq[start:stop]) : reverse_complement(@view(seq[start:stop]))

# a = 1