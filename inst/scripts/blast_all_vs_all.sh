#!/bin/bash
# All-vs-all megablast of the transcriptome (BLAST+ 2.12). nvir.fa is the transcriptome, with a nucleotide BLAST database of the same name (makeblastdb -dbtype nucl)
blastn -task megablast -query nvir.fa -db nvir.fa -num_threads 14 -perc_identity 90 -evalue 1e-20 -max_target_seqs 100 -max_hsps 1 \
  -outfmt "6 qseqid sseqid pident length qlen slen qstart qend sstart send bitscore" > all_hits.tsv

# Hits to other transcripts at >= 95 % identity over >= 100 bp (the gene edges), and at 90-95 % over >= 300 bp (for the conflict split)
awk '$1 != $2 && $3 >= 95 && $4 >= 100' all_hits.tsv | gzip > all_hits_95.tsv.gz
awk '$1 != $2 && $3 >= 90 && $3 < 95 && $4 >= 300' all_hits.tsv | gzip > all_hits_90_95_300bp.tsv.gz
