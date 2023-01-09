# # this will be the main functions taking all the algorithms

"""
    locationgenerator(sequence::LongDNA)

Generate the locations of ORFs in the given DNA `sequence`.

This function searches the sequence for start codons, and generates ranges of indices corresponding to the locations of ORFs in the `sequence`. 
    The ORFs are generated by iterating over the start codon indices and searching for the first stop codon that follows each start codon. 
        ORFs that contain premature stop codons are filtered out using the `hasprematurestop` function. 
            The `sequence` argument must be a `LongDNA` object, which is a type of DNA sequence with a longer maximum length than the `DNA` type.

Returns:
    A generator expression that yields ranges of indices corresponding to the locations of ORFs in the `sequence`.
"""
function locationgenerator(sequence::LongDNA; alternative_start::Bool=false)
    seqbound = length(sequence) - 2
    if alternative_start == false
        start_codon_indices = findall(startcodon, sequence)
        @inbounds begin
            (i.start:j+2 for i in start_codon_indices for j in i.start:3:seqbound if sequence[j:j+2] ∈ stopcodons && !hasprematurestop(sequence[i.start:j+2]))
        end
    else
        start_codon_indices = findall(extended_startcodons, sequence)
        @inbounds begin
            (i:j+2 for i in start_codon_indices for j in i:3:seqbound if sequence[j:j+2] ∈ stopcodons && !hasprematurestop(sequence[i:j+2]))
        end
    end
end

"""
    orfgenerator(sequence::LongDNA; alternative_start::Bool=false)

Generate ORFs from the given DNA `sequence`.

This function generates ORFs from the forward and reverse complement strands of the `sequence` using the `locationgenerator` function. 
    It generates an ORF object for each range of indices returned by `locationgenerator`, and includes a `'+'` or `'-'` strand label 
        to indicate the strand from which the ORF was generated. The `sequence` argument must be a `LongDNA` object, which is a type 
        of DNA sequence with a longer maximum length than the `DNA` type.

Returns:
    A generator expression that yields `ORF` objects corresponding to the ORFs in the `sequence`.
"""
function orfgenerator(sequence::LongDNA; alternative_start::Bool=false, min_len = 6)
    revseq = reverse_complement(sequence)
    @inbounds begin
        orfs = (ORF(location, strand) for strand in ['+', '-'] for location in locationgenerator(strand == '+' ? sequence : revseq; alternative_start) if length(location) >= min_len)
    end
    return orfs
end

@testitem "orfgenerator test" begin
    using BioSequences

    # A random seq to start
    seq01 = dna"ATGATGCATGCATGCATGCTAGTAACTAGCTAGCTAGCTAGTAA"
    orfs01 = collect(orfgenerator(seq01))

    @test collect(orfgenerator(seq01)) == [ORF(1:33, '+'), ORF(4:33, '+'), ORF(8:22, '+'), ORF(12:29, '+'), ORF(16:33, '+')]
    @test length(orfs01) == 5

    # > 180195.SAMN03785337.LFLS01000089 -> finds only 1 gene in Prodigal (from Pyrodigal tests)
    seq02 = dna"AACCAGGGCAATATCAGTACCGCGGGCAATGCAACCCTGACTGCCGGCGGTAACCTGAACAGCACTGGCAATCTGACTGTGGGCGGTGTTACCAACGGCACTGCTACTACTGGCAACATCGCACTGACCGGTAACAATGCGCTGAGCGGTCCGGTCAATCTGAATGCGTCGAATGGCACGGTGACCTTGAACACGACCGGCAATACCACGCTCGGTAACGTGACGGCACAAGGCAATGTGACGACCAATGTGTCCAACGGCAGTCTGACGGTTACCGGCAATACGACAGGTGCCAACACCAACCTCAGTGCCAGCGGCAACCTGACCGTGGGTAACCAGGGCAATATCAGTACCGCAGGCAATGCAACCCTGACGGCCGGCGACAACCTGACGAGCACTGGCAATCTGACTGTGGGCGGCGTCACCAACGGCACGGCCACCACCGGCAACATCGCGCTGACCGGTAACAATGCACTGGCTGGTCCTGTCAATCTGAACGCGCCGAACGGCACCGTGACCCTGAACACAACCGGCAATACCACGCTGGGTAATGTCACCGCACAAGGCAATGTGACGACTAATGTGTCCAACGGCAGCCTGACAGTCGCTGGCAATACCACAGGTGCCAACACCAACCTGAGTGCCAGCGGCAATCTGACCGTGGGCAACCAGGGCAATATCAGTACCGCGGGCAATGCAACCCTGACTGCCGGCGGTAACCTGAGC"
    orfs02 = collect(orfgenerator(seq02, alternative_start=false))

    @test length(orfs02) == 12
    @test collect(orfgenerator(seq02)) == [ORF(29:40, '+'), ORF(137:145, '+'), ORF(164:184, '+'), ORF(173:184, '+'), ORF(236:241, '+'), ORF(248:268, '+'), ORF(362:373, '+'), ORF(470:496, '+'), ORF(551:574, '+'), ORF(569:574, '+'), ORF(581:601, '+'), ORF(695:706, '+')]
end

function cdsgenerator(sequence::LongDNA; alternative_start::Bool=false, min_len=6)
    revseq = reverse_complement(sequence)
    @inbounds begin
        cds = (i.strand == '+' ? sequence[i.location] : revseq[i.location] for i in orfgenerator(sequence; alternative_start, min_len))
    end
    return cds
end

function cdsgenerator(sequence::String; alternative_start::Bool=false, min_len=6)
    sequence = LongDNA{4}(sequence)
    revseq = reverse_complement(sequence)
    @inbounds begin
        cds = (i.strand == '+' ? sequence[i.location] : revseq[i.location] for i in orfgenerator(sequence; alternative_start, min_len))
    end
    return cds
end

function proteingenerator(sequence::LongDNA; alternative_start::Bool=false, code::GeneticCode = BioSequences.standard_genetic_code, min_len=6)
    revseq = reverse_complement(sequence)
    @inbounds begin
        proteins = (i.strand == '+' ? translate(sequence[i.location]; alternative_start, code) : translate(revseq[i.location]; alternative_start, code) for i in orfgenerator(sequence; alternative_start, min_len))
    end
    return proteins
end

function proteingenerator(sequence::String; alternative_start::Bool=false, code::GeneticCode = BioSequences.standard_genetic_code, min_len=6)
    sequence = LongDNA{4}(sequence)
    revseq = reverse_complement(sequence)
    @inbounds begin
        proteins = (i.strand == '+' ? translate(sequence[i.location]; alternative_start, code) : translate(revseq[i.location]; alternative_start, code) for i in orfgenerator(sequence; alternative_start, min_len))
    end
    return proteins
end

# """
# FindGene struct
# """
# mutable struct FindGene{S1,S2}
#     a::GeneFinderAlgorithm{S1}
#     b::LongDNA
#     c::GeneticCode
# end

# function findgenes(::SimpleFinder, sequence::LongDNA) # type::GeneticCode
#     orfs = simplefinder(sequence)
#     seqs = Vector{CDS}()


# end