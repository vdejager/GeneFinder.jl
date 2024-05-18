@testset "findorfs" begin
    # cd(@__DIR__)

    # A random seq to start
    seq01 = dna"ATGATGCATGCATGCATGCTAGTAACTAGCTAGCTAGCTAGTAA"
    orfs01 = findorfs(seq01, NaiveFinder())

    @test orfs01 == [ORF{NaiveFinder}(ORF1, 1:33, +, 1, nothing), ORF{NaiveFinder}(ORF2, 4:33, +, 1, nothing), ORF{NaiveFinder}(ORF3, 8:22, +, 2, nothing), ORF{NaiveFinder}(ORF4, 12:29, +, 3, nothing), ORF{NaiveFinder}(ORF5, 16:33, +, 1, nothing)]
    @test length(orfs01) == 5

    # > 180195.SAMN03785337.LFLS01000089 -> finds only 1 gene in Prodigal (from Pyrodigal tests)
    seq02 = dna"AACCAGGGCAATATCAGTACCGCGGGCAATGCAACCCTGACTGCCGGCGGTAACCTGAACAGCACTGGCAATCTGACTGTGGGCGGTGTTACCAACGGCACTGCTACTACTGGCAACATCGCACTGACCGGTAACAATGCGCTGAGCGGTCCGGTCAATCTGAATGCGTCGAATGGCACGGTGACCTTGAACACGACCGGCAATACCACGCTCGGTAACGTGACGGCACAAGGCAATGTGACGACCAATGTGTCCAACGGCAGTCTGACGGTTACCGGCAATACGACAGGTGCCAACACCAACCTCAGTGCCAGCGGCAACCTGACCGTGGGTAACCAGGGCAATATCAGTACCGCAGGCAATGCAACCCTGACGGCCGGCGACAACCTGACGAGCACTGGCAATCTGACTGTGGGCGGCGTCACCAACGGCACGGCCACCACCGGCAACATCGCGCTGACCGGTAACAATGCACTGGCTGGTCCTGTCAATCTGAACGCGCCGAACGGCACCGTGACCCTGAACACAACCGGCAATACCACGCTGGGTAATGTCACCGCACAAGGCAATGTGACGACTAATGTGTCCAACGGCAGCCTGACAGTCGCTGGCAATACCACAGGTGCCAACACCAACCTGAGTGCCAGCGGCAATCTGACCGTGGGCAACCAGGGCAATATCAGTACCGCGGGCAATGCAACCCTGACTGCCGGCGGTAACCTGAGC"
    orfs02 = findorfs(seq02, NaiveFinder())

    @test length(orfs02) == 12
    @test orfs02 == [ORF{NaiveFinder}(ORF1, 29:40, +, 2, nothing), ORF{NaiveFinder}(ORF2, 137:145, +, 2, nothing), ORF{NaiveFinder}(ORF3, 164:184, +, 2, nothing), ORF{NaiveFinder}(ORF4, 173:184, +, 2, nothing), ORF{NaiveFinder}(ORF5, 236:241, +, 2, nothing), ORF{NaiveFinder}(ORF6, 248:268, +, 2, nothing), ORF{NaiveFinder}(ORF7, 362:373, +, 2, nothing), ORF{NaiveFinder}(ORF8, 470:496, +, 2, nothing), ORF{NaiveFinder}(ORF9, 551:574, +, 2, nothing), ORF{NaiveFinder}(ORF10, 569:574, +, 2, nothing), ORF{NaiveFinder}(ORF11, 581:601, +, 2, nothing), ORF{NaiveFinder}(ORF12, 695:706, +, 2, nothing)]

    # From pyrodigal issue #13 link: https://github.com/althonos/pyrodigal/blob/1f939b0913b48dbaa55d574b20e124f1b8323825/pyrodigal/tests/test_orf_finder.py#L271
    # Pyrodigal predicts 2 genes from this sequence:
    # 1) An alternative start codon (GTG) sequence at 48:347
    # 2) A common start codon sequence at 426:590
    # On the other hand, the NCBI ORFfinder program predicts 9 ORFs whose length is greater than 75 nt, from which one has an "outbound" stop
    seq03 = dna"TTCGTCAGTCGTTCTGTTTCATTCAATACGATAGTAATGTATTTTTCGTGCATTTCCGGTGGAATCGTGCCGTCCAGCATAGCCTCCAGATATCCCCTTATAGAGGTCAGAGGGGAACGGAAATCGTGGGATACATTGGCTACAAACTTTTTCTGATCATCCTCGGAACGGGCAATTTCGCTTGCCATATAATTCAGACAGGAAGCCAGATAACCGATTTCATCCTCACTATCGACCTGAAATTCATAATGCATATTACCGGCAGCATACTGCTCTGTGGCATGAGTGATCTTCCTCAGAGGAATATATACGATCTCAGTGAAAAAGATCAGAATGATCAGGGATAGCAGGAACAGGATTGCCAGGGTGATATAGGAAATATTCAGCAGGTTGTTACAGGATTTCTGAATATCATTCATATCAGTATGGATGACTACATAGCCTTTTACCTTGTAGTTGGAGGTAATGGGAGCAAATACAGTAAGTACATCCGAATCAAAATTACCGAAGAAATCACCAACAATGTAATAGGAGCCGCTGGTTACGGTCGAATCAAAATTCTCAATGACAACCACATTCTCCACATCTAAGGGACTATTGGTATCCAGTACCAGTCGTCCGGAGGGATTGATGATGCGAATCTCGGAATTCAGGTAGACCGCCAGGGAGTCCAGCTGCATTTTAACGGTCTCCAAAGTTGTTTCACTGGTGTACAATCCGCCGGCATAGGTTCCGGCGATCAGGGTTGCTTCGGAATAGAGACTTTCTGCCTTTTCCCGGATCAGATGTTCTTTGGTCATATTGGGAACAAAAGTTGTAACAATGATGAAACCAAATACACCAAAAATAAAATATGCGAGTATAAATTTTAGATAAAGTGTTTTTTTCATAACAAATCCTGCTTTTGGTATGACTTAATTACGTACTTCGAATTTATAGCCGATGCCCCAGATGGTGCTGATCTTCCAGTTGGCATGATCCTTGATCTTCTC"
    orfs03 = findorfs(seq03, NaiveFinder(), min_len=75)
    @test length(orfs03) == 9
    @test orfs03 == [ORF{NaiveFinder}(ORF1, 37:156, +, 1, nothing), ORF{NaiveFinder}(ORF9, 194:268, -, 2, nothing), ORF{NaiveFinder}(ORF8, 194:283, -, 2, nothing), ORF{NaiveFinder}(ORF2, 249:347, +, 3, nothing), ORF{NaiveFinder}(ORF3, 426:590, +, 3, nothing), ORF{NaiveFinder}(ORF4, 565:657, +, 1, nothing), ORF{NaiveFinder}(ORF7, 650:727, -, 2, nothing), ORF{NaiveFinder}(ORF5, 786:872, +, 3, nothing), ORF{NaiveFinder}(ORF6, 887:976, -, 2, nothing)]
                                                                                                           #|->  This occured in Pyrodigal
    # Lambda phage tests
    # Compare to https://github.com/jonas-fuchs/viral_orf_finder/blob/master/orf_finder.py 
    # Salisbury and Tsorukas (2019) paper used the Lambda phage genome with 73 CDS and 545 non-CDS ORFs (a total of 618) to compare predictions between several Gene Finder programs
    # For a minimal length of 75 nt the following ORFs are predicted: 
    # orf_finder.py --> 885 (222 complete)
    # findorfs (GeneFinder.jl) --> 885
    # NCBI ORFfinder --> 375 ORFs
    # orfipy --> 375 (`orfipy NC_001416.1.fasta --start ATG --include-stop --min 75`)
    NC_001416 = fasta_to_dna("data/NC_001416.1.fasta")[1]
    NC_001416_orfs = findorfs(NC_001416, NaiveFinder(), min_len=75)
    @test length(NC_001416_orfs) == 885
end

@testset "getorfs" begin

    seq01 = dna"ATGATGCATGCATGCATGCTAGTAACTAGCTAGCTAGCTAGTAA"
    orfseqs = getorfs(seq01, DNAAlphabet{4}(), NaiveFinder())

    @test length(orfseqs) == 5
    @test orfseqs[1] == dna"ATGATGCATGCATGCATGCTAGTAACTAGCTAG"
end

@testset "getorfs" begin

    seq01 = dna"ATGATGCATGCATGCATGCTAGTAACTAGCTAGCTAGCTAGTAA"
    aas = getorfs(seq01, AminoAcidAlphabet(), NaiveFinder())

    @test length(aas) == 5
    @test aas[1] == aa"MMHACMLVTS*"
end