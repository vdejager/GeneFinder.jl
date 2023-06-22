# Structs associated with gene models 

abstract type Gene end

"""
    struct GeneFeatures
        seqname::String
        start::Int64
        stop::Int64
        score::Float64
        strand::Char
        frame::'.'
        attribute::
    end

This is the main Gene struct, based on the fields that could be found in a GFF3, still needs to be defined correctly,
    The idea is correct the frame and attributes that will have something like a possible list (id=Char;name=;locus_tag).
    The `write` and `get` functions should have a dedicated method for this struct.
"""
struct GeneFeatures
    seqname::String
    start::Int64
    stop::Int64
    score::Float64
    strand::Char
    frame::String
    attribute::String # Should be a Dict perhaps
end

"""
    struct ORF
        location::UnitRange{Int64}
        strand::Char
    end

The ORF struct represents an open reading frame in a DNA sequence. It has two fields: 

- `location`: which is a UnitRange{Int64} indicating the start and end locations of the ORF in the sequence
- `strand`:  is a Char type indicating whether the ORF is on the forward ('+') or reverse ('-') strand of the sequence.
"""
struct ORF <: Gene
    location::UnitRange{Int64} # Note that it is also called position for gene struct in GenomicAnotations
    strand::Char
end

"""
    struct CDS
        orf::ORF
        sequence::LongSubSeq{DNAAlphabet{4}}
    end

The `CDS` struct represents a coding sequence in a DNA sequence. It has three fields:

- `orf`: is the basic composible type (`location::UnitRange{Int}`, strand::Char) displaying the location of the ORF and the associate strand: forward ('+') or reverse ('-')
- `sequence`: a `LongSequence{DNAAlphabet{4}}` sequence representing the actual sequence of the CDS
"""
struct CDS <: Gene
    sequence::LongSubSeq{DNAAlphabet{4}} #LongSequence{DNAAlphabet{4}}
    orf::ORF
end

"""
    struct Protein
        sequence::LongSequence
        orf::ORF
    end
    
Similarly to the `CDS` struct, the `Protein` struct represents a encoded protein sequence in a DNA sequence. 
    It has three fields:

- `orf`: is the basic composible type (`location::UnitRange{Int}`, strand::Char) of the sequence
- `sequence`: a `LongSequence` sequence representing the actual translated sequence of the CDS
"""
struct Protein <: Gene
    sequence::LongSubSeq{AminoAcidAlphabet}
    orf::ORF
end


"""
    TCM(alphabet::Vector{DNA})

A data structure for storing a DNA Transition Count Matrix (TCM). The TCM is a square matrix where each row and column corresponds to a nucleotide in the given `alphabet`. The value at position (i, j) in the matrix represents the number of times that nucleotide i is immediately followed by nucleotide j in a DNA sequence. 

Fields:
- `order::Dict{DNA, Int64}`: A dictionary that maps each nucleotide in the `alphabet` to its corresponding index in the matrix.
- `counts::Matrix{Int64}`: The actual matrix of counts.

Internal function:
- `TCM(alphabet::Vector{DNA})`: Constructs a new `TCM` object with the given `alphabet`. This function initializes the `order` field by creating a dictionary that maps each nucleotide in the `alphabet` to its corresponding index in the matrix. It also initializes the `counts` field to a matrix of zeros with dimensions `len x len`, where `len` is the length of the `alphabet`.

Example usage:
```julia
alphabet = [DNA_A, DNA_C, DNA_G, DNA_T]
dtcm = TCM(alphabet)
```
"""
struct TCM
    order::Dict{DNA,Int64}
    counts::Matrix{Int64}

    function TCM(alphabet::Vector{DNA})

        len = length(alphabet)

        order = Dict{DNA,Int}()
        for (i, nucleotide) in enumerate(sort(alphabet))
            order[nucleotide] = i
        end
        counts = zeros(Int64, len, len)
        new(order, counts)
    end
end


"""
    TPM(alphabet::Vector{DNA})

A data structure for storing a DNA Transition Probability Matrix (TPM). The TPM is a square matrix where each row and column corresponds to a nucleotide in the given `alphabet`. The value at position (i, j) in the matrix represents the probability of transitioning from nucleotide i to nucleotide j in a DNA sequence. 

Fields:
- `order::Dict{DNA, Int64}`: A dictionary that maps each nucleotide in the `alphabet` to its corresponding index in the matrix.
- `probabilities::Matrix{Float64}`: The actual matrix of probabilities.

Example usage:
```julia
alphabet = [DNA_A, DNA_C, DNA_G, DNA_T]
dtpm = TPM(alphabet)
```
"""
struct TPM
    order::Dict{DNA,Int64}
    probabilities::Matrix{Float64}
end

"""
    struct TransitionModel

The `TransitionModel` struct represents a transition model with coding and noncoding matrices,
and coding and noncoding initial distributions.

# Fields
- `coding::Matrix{Float64}`: The coding matrix representing transition probabilities.
- `noncoding::Matrix{Float64}`: The noncoding matrix representing transition probabilities.
- `codinginits::Matrix{Float64}`: The coding initial distribution.
- `noncodinginits::Matrix{Float64}`: The noncoding initial distribution.

# Constructors
- `TransitionModel(coding::Matrix{Float64}, noncoding::Matrix{Float64}, codinginits::Matrix{Float64}, noncodinginits::Matrix{Float64})`: Create a `TransitionModel` instance with the specified coding and noncoding matrices and initial distributions.
- `TransitionModel(codingseq, noncodingseq)`: Create a `TransitionModel` instance by computing the transition probabilities and initial distributions from the given coding and noncoding sequences.

"""
struct TransitionModel
    coding::Matrix{Float64}
    noncoding::Matrix{Float64}
    codinginits::Matrix{Float64}
    noncodinginits::Matrix{Float64}

    function TransitionModel(coding::Matrix{Float64}, noncoding::Matrix{Float64}, codinginits::Matrix{Float64}, noncodinginits::Matrix{Float64})
        new(coding, noncoding, codinginits, noncodinginits)
    end

    function TransitionModel(codingseq, noncodingseq)
        coding = transition_probability_matrix(codingseq)
        noncoding = transition_probability_matrix(noncodingseq)
        codinginits = initial_distribution(codingseq)
        noncodinginits = initial_distribution(noncodingseq)
        new(coding, noncoding, codinginits, noncodinginits)
    end
end
const LongNucOrView{N} = Union{
     LongSequence{<:NucleicAcidAlphabet{N}},
     LongSubSeq{<:NucleicAcidAlphabet{N}}
 }


##### The following implementation is from https://biojulia.dev/BioSequences.jl/stable/interfaces/ #####
# """
#     Codon <: BioSequence{DNAAlphabet{2}}

# A `Struct` representing a codon, which is a subtype of `BioSequence` with
# an `Alphabet` of type `DNAAlphabet{2}`. It has a single field `x` of type
# `UInt8`. This was implemente in The following implementation is from https://biojulia.dev/BioSequences.jl/stable/interfaces/
# """
# struct Codon <: BioSequence{DNAAlphabet{2}}
#     x::UInt8

#     function Codon(iterable)
#         length(iterable) == 3 || error("Must have length 3")
#         x = zero(UInt)
#         for (i, nt) in enumerate(iterable)
#             x |= BioSequences.encode(Alphabet(Codon), convert(DNA, nt)) << (6 - 2i)
#         end
#         new(x % UInt8)
#     end 
# end

# Base.copy(seq::Codon) = Codon(seq.x)
# Base.count(codon::Codon, sequence::LongSequence{DNAAlphabet{4}}) = count(codon, sequence)
# Base.length(::Codon) = 3

# function Base.count(codons::Vector{Codon}, sequence::LongSequence{DNAAlphabet{4}})
#     a = 0
#     @inbounds for i in codons
#         a += count(i, sequence)
#     end
#     return a
# end

# # has_interface(BioSequence, Codon, [DNA_C, DNA_T, DNA_G], false)

# function extract_encoded_element(x::Codon, i::Int)
#     ((x.x >>> (6 - 2i)) & 3) % UInt
# end

# function translate(
#     ntseq::Codon;
#     code::GeneticCode = standard_genetic_code,
#     allow_ambiguous_codons = true,
#     alternative_start = false,
# )   
#     translate(ntseq; code, allow_ambiguous_codons, alternative_start)
# end

##### ---------------------------------------- #####
