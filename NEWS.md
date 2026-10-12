# org.Nv.eg.db 1.0.0

* First version. The transcriptome of Tsissios et al. (2024; GEO GSE236907) is used as
  published, not reassembled; the package adds a transcript-to-gene mapping in which a gene is a cluster of
  transcripts that overlap at 98 % identity or more, resolved for conflicts (members below 97 %
  identity, or covering the same protein region without nucleotide similarity, are separated) and
  completed by joining non-overlapping fragments through their alignments to the same Swiss-Prot
  protein. Myf5, Myog and Myf6 come from the transcriptome of Abdullayev et al. (2013).
* Keys: GID, SYMBOL, GENENAME, UNIPROT, GO, GOALL and TXID (every transcript).
* Gene names and GO terms are from Swiss-Prot annotation of the transcriptome
  (TransDecoder ORFs, blastp; Vdovin et al., under revision): GO terms of the hit entries from
  UniProt (fetched 2026-10-11; evidence ISS), no electronic annotation. Built with AnnotationForge
  1.52.0 and GO.db 3.22.0 (GO release 2025-07-22).
* The five Myf5, Myog and Myf6 contigs are part of the package in `inst/extdata`, and can be appended to the 
  published transcriptome from Tsissios.
