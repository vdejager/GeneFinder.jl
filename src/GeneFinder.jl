module GeneFinder

using BioSequences:
    DNA,
    DNA_Gap, DNA_A, DNA_C, DNA_M, DNA_G, DNA_R, DNA_S, DNA_V, DNA_T, DNA_W, DNA_Y, DNA_H, DNA_K, DNA_D, DNA_B, DNA_N,
    
    Alphabet,
    BioRegex,
    NucleicAcidAlphabet,
    DNAAlphabet,
    AminoAcidAlphabet,
    LongDNA,
    LongAA,
    LongSequence,
    LongSubSeq,
    NucleicSeqOrView,
    @biore_str,
    @dna_str,
    GeneticCode,
    reverse_complement,
    randdnaseq,
    ncbi_trans_table,
    translate,
    gc_content

using BioMarkovChains: BioMarkovChain, ECOLICDS, ECOLINOCDS, log_odds_ratio_score
using FASTX: FASTAReader, sequence
using IterTools: takewhile, iterated
using GenomicFeatures: GenomicFeatures, AbstractGenomicInterval, GenomicInterval, Strand, summary, groupname, strand, metadata, STRAND_POS, STRAND_NEG, STRAND_BOTH, STRAND_NA, leftposition, rightposition, length

# Finder Algorithms
include("algorithms/naivefinder.jl")
include("algorithms/naivecollector.jl")

# Coding Criteria
include("criteria/lordr.jl")

# Main functions
include("types.jl")
include("findorfs.jl")
include("iscoding.jl")
include("io.jl")

# Utils and extended functions
include("utils.jl")
include("extended.jl")

include("workload.jl")

end