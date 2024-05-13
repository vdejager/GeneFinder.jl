# Test the write_orfs_* methods
@testset "write_orfs_f* " begin
    
    # seq01 = dna"ATGATGCATGCATGCATGCTAGTAACTAGCTAGCTAGCTAGTAA"
    # seq02 = dna"AACCAGGGCAATATCAGTACCGCGGGCAATGCAACCCTGACTGCCGGCGGTAACCTGAACAGCACTGGCAATCTGACTGTGGGCGGTGTTACCAACGGCACTGCTACTACTGGCAACATCGCACTGACCGGTAACAATGCGCTGAGCGGTCCGGTCAATCTGAATGCGTCGAATGGCACGGTGACCTTGAACACGACCGGCAATACCACGCTCGGTAACGTGACGGCACAAGGCAATGTGACGACCAATGTGTCCAACGGCAGTCTGACGGTTACCGGCAATACGACAGGTGCCAACACCAACCTCAGTGCCAGCGGCAACCTGACCGTGGGTAACCAGGGCAATATCAGTACCGCAGGCAATGCAACCCTGACGGCCGGCGACAACCTGACGAGCACTGGCAATCTGACTGTGGGCGGCGTCACCAACGGCACGGCCACCACCGGCAACATCGCGCTGACCGGTAACAATGCACTGGCTGGTCCTGTCAATCTGAACGCGCCGAACGGCACCGTGACCCTGAACACAACCGGCAATACCACGCTGGGTAATGTCACCGCACAAGGCAATGTGACGACTAATGTGTCCAACGGCAGCCTGACAGTCGCTGGCAATACCACAGGTGCCAACACCAACCTGAGTGCCAGCGGCAATCTGACCGTGGGCAACCAGGGCAATATCAGTACCGCGGGCAATGCAACCCTGACTGCCGGCGGTAACCTGAGC"

    # Test case 1

    # From pyrodigal issue #13 link: https://github.com/althonos/pyrodigal/blob/1f939b0913b48dbaa55d574b20e124f1b8323825/pyrodigal/tests/test_orf_finder.py#L271
    # Pyrodigal predicts 2 genes from this sequence:
    # 1) An alternative start codon (GTG) sequence at 48:347
    # 2) A common start codon sequence at 426:590
    # On the other hand, the NCBI ORFfinder program predicts 9 ORFs whose length is greater than 75 nt, from which one has an "outbound" stop
    seq03 = dna"TTCGTCAGTCGTTCTGTTTCATTCAATACGATAGTAATGTATTTTTCGTGCATTTCCGGTGGAATCGTGCCGTCCAGCATAGCCTCCAGATATCCCCTTATAGAGGTCAGAGGGGAACGGAAATCGTGGGATACATTGGCTACAAACTTTTTCTGATCATCCTCGGAACGGGCAATTTCGCTTGCCATATAATTCAGACAGGAAGCCAGATAACCGATTTCATCCTCACTATCGACCTGAAATTCATAATGCATATTACCGGCAGCATACTGCTCTGTGGCATGAGTGATCTTCCTCAGAGGAATATATACGATCTCAGTGAAAAAGATCAGAATGATCAGGGATAGCAGGAACAGGATTGCCAGGGTGATATAGGAAATATTCAGCAGGTTGTTACAGGATTTCTGAATATCATTCATATCAGTATGGATGACTACATAGCCTTTTACCTTGTAGTTGGAGGTAATGGGAGCAAATACAGTAAGTACATCCGAATCAAAATTACCGAAGAAATCACCAACAATGTAATAGGAGCCGCTGGTTACGGTCGAATCAAAATTCTCAATGACAACCACATTCTCCACATCTAAGGGACTATTGGTATCCAGTACCAGTCGTCCGGAGGGATTGATGATGCGAATCTCGGAATTCAGGTAGACCGCCAGGGAGTCCAGCTGCATTTTAACGGTCTCCAAAGTTGTTTCACTGGTGTACAATCCGCCGGCATAGGTTCCGGCGATCAGGGTTGCTTCGGAATAGAGACTTTCTGCCTTTTCCCGGATCAGATGTTCTTTGGTCATATTGGGAACAAAAGTTGTAACAATGATGAAACCAAATACACCAAAAATAAAATATGCGAGTATAAATTTTAGATAAAGTGTTTTTTTCATAACAAATCCTGCTTTTGGTATGACTTAATTACGTACTTCGAATTTATAGCCGATGCCCCAGATGGTGCTGATCTTCCAGTTGGCATGATCCTTGATCTTCTC"
    
    seq03fna = "data/out-seq03.fna"
    open(seq03fna, "w") do io
        write_orfs_fna(seq03, io, NaiveFinder())
    end

    seq03fnarecords = open(collect, FASTAReader, "data/out-seq03.fna")

    @test seq03fnarecords[1] == FASTX.FASTA.Record("ORF01 id=01 start=5 stop=22 strand=- frame=2", "ATGAAACAGAACGACTGA")
    @test length(seq03fnarecords) == 32
    @test identifier(seq03fnarecords[1]) == "ORF01"
    @test description(seq03fnarecords[1]) == "ORF01 id=01 start=5 stop=22 strand=- frame=2"
    @test sequence(seq03fnarecords[1]) == "ATGAAACAGAACGACTGA"

    # Test case 2

    seq03faa = "data/out-seq03.faa"
    open(seq03faa, "w") do io
        write_orfs_faa(seq03, io, NaiveFinder())
    end

    seq03faarecords = open(collect, FASTAReader, "data/out-seq03.faa")

    @test seq03faarecords[2] == FASTX.FASTA.Record("ORF02 id=02 start=37 stop=156 strand=+ frame=1", "MYFSCISGGIVPSSIASRYPLIEVRGERKSWDTLATNFF*")
    @test length(seq03faarecords) == 32
    @test identifier(seq03faarecords[2]) == "ORF02"
    @test description(seq03faarecords[2]) == "ORF02 id=02 start=37 stop=156 strand=+ frame=1"
    @test sequence(seq03faarecords[2]) == "MYFSCISGGIVPSSIASRYPLIEVRGERKSWDTLATNFF*"

    # Test case 3 

    @test seq03faarecords[3] == FASTX.FASTA.Record("ORF03 id=03 start=107 stop=136 strand=- frame=2", "MYPTISVPL*")

end
