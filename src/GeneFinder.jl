module GeneFinder

using BioSequences:
    DNA,
    NucleicAcidAlphabet,
    DNAAlphabet,
    AminoAcidAlphabet,
    LongDNA,
    LongAA,
    LongSequence,
    LongSubSeq,
    @biore_str,
    @dna_str,
    GeneticCode
using FASTX: FASTA, sequence
using IterTools: takewhile, iterated
# using MarkovChainHammer.Trajectory: generate
using PrecompileTools
using StatsBase: countmap
using TestItems: @testitem

include("types.jl")
export ORF, CDS, Protein, TCM, TPM, TransitionModel

include("algorithms/findorfs.jl")
export locationiterator, findorfs

include("findgenes.jl")
export cdsgenerator, proteingenerator, getcds, getproteins

include("io.jl")
export write_cds, write_proteins, write_bed, write_gff

include("helpers.jl")
export fasta_to_dna,
    transition_count_matrix,
    transition_probability_matrix,
    sequenceprobability,
    initial_distribution,
    dinucleotides,
    codons,
    hasprematurestop,
    iscoding

include("models/models.jl")
export ECOLICDS, ECOLINOCDS

include("extended.jl")

@setup_workload begin
    # Putting some things in `@setup_workload` instead of `@compile_workload` can reduce the size of the
    # precompile file and potentially make loading faster.
    using BioSequences
    seq = randdnaseq(10^6)
    @compile_workload begin
        # all calls in this block will be precompiled, regardless of whether
        # they belong to your package or not (on Julia 1.8 and higher)
        findorfs(seq)
        dinucleotides(seq)
    end
end

end
