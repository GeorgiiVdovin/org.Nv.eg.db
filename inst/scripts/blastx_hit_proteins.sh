#!/bin/bash
# blastx of the 96,448 transcripts with a Swiss-Prot hit (sp_hit_tx.fa) against their 23,486 hit proteins (BLAST+ 2.12): where on its protein each transcript lies.
# swissprot_hits is a protein BLAST database of ../uniprot/swissprot_hits.fa (fetch_uniprot_fasta.py).
# -mt_mode 1 splits the queries over the threads; by default BLAST splits the small database and runs on one thread
blastx -task blastx-fast -mt_mode 1 -query sp_hit_tx.fa -db swissprot_hits -num_threads 10 -evalue 1e-10 -max_target_seqs 5 -max_hsps 1 \
  -outfmt "6 qseqid sseqid pident length qstart qend sstart send slen evalue bitscore" > blastx_hits.tsv

gzip -k blastx_hits.tsv
