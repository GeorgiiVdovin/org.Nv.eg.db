The *org.Nv.eg.db* package groups the transcripts of a published de novo transcriptome into genes and annotates
the genes. **The transcriptome was not reassembled, filtered or edited**: every sequence is used as
published. What is new is the transcript-to-gene mapping, made from the transcripts themselves, and
the annotation of the genes. The scripts are in `inst/scripts/`.

## Inputs

| input | |
|-------|--|
| transcriptome | the 856,456 transcripts of Tsissios et al. (2024), assembled with Trinity per condition and merged with DRAP (912 Mb, N50 1,310 bp, median 857 bp); GEO [GSE236907](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE236907), `GSE236907_NVir_transcriptome.fasta.gz` |
| Myf5, Myog, Myf6 | five contigs of the transcriptome of Abdullayev et al. (2013), `inst/extdata/myf5_myog_myf6.fasta.gz`. The three genes are missing from the transcriptome, also at the sequence level; MyoD is in neither |
| Swiss-Prot hits | the open reading frames of each transcript (TransDecoder) searched with blastp against Swiss-Prot on Galaxy, best hit per transcript at E <= 1e-5 (Vdovin et al., under revision): 96,448 transcripts (11.3 %) hit 23,499 Swiss-Prot entries |
| UniProt | primary gene names, GO terms and protein sequences of these entries, from the UniProt REST API (2026-10-11) |

`package_inputs.R` appends the five contigs to the transcriptome (856,461 transcripts, the
reference every step uses) and writes the table of Swiss-Prot hits. `fetch_uniprot_go.py` and
`fetch_uniprot_fasta.py` download the UniProt data.

## Transcript grouping procedure

The Tsissios de novo assembly represents most genes by several transcripts: fragments, isoforms and alleles.
In this transcriptome, 68 % of the transcripts have another one at 90 % identity or more. I reduce
redundancy in four steps (`5_gene_clusters.Rmd`):

1. An all-vs-all megablast (`blast_all_vs_all.sh`) links transcripts that align at 98 % identity
   or more, over 300 bp or more and at least 25 % of the shorter one. Linked transcripts form a
   gene. 98 % is where the identity of overlapping transcripts has its minimum, between alleles and
   fragments of one gene and paralogues.
2. Genes that join two transcripts below 97 % identity through a third one are split
   (complete-linkage clustering).
3. Fragments that do not overlap but align (blastx) to different parts of the same Swiss-Prot
   protein are joined.
4. The Myf5, Myog and Myf6 contigs form three genes.

Genes are numbered `NVG000001` onwards in transcript order. Symbols and gene names come from the
best Swiss-Prot hit of each gene (a second gene with the same hit becomes `.2`), GO terms from
UniProt for all hits of the gene (evidence ISS) (`6_cluster_annotation.Rmd`).
The package is built with AnnotationForge 1.52.0 (`7_org_package.Rmd`).

## Result

856,461 transcripts form 728,711 genes, 72,387 of them with several transcripts. 67,655 genes have
a gene symbol and 66,942 have GO terms.

## Trade-offs

- A lower identity threshold would join gene families (e.g. at 96% - all myosin heavy chains, LDHA with
  LDHB), a higher one leaves more genes split. 98% is the tested compromise.
- Fragments that neither overlap nor hit the same protein stay split.
- Paralogues more than 98 % identical and chimeric transcripts stay joined: about 900 genes hit two
  different proteins (e.g. Pcbp2 and Mknk2), and the MYH1, MYH2, MYH4, MYH6 and MYH13 hits form one
  gene. But they are anyway too similar for pseudoalignment to reliably assign without a proper isoform
  annotation, so I take this tradeoff. If you are interested in genes from closely related families, the tradeoff 
  would be a globally fragmented transcriptome; and you can consider using the annotation used in the paper under 
  https://github.com/GeorgiiVdovin/hypoxia_muscle_dediff.
- The split in step 2 can separate a transcript from its closest partner.
- GO terms are transferred from other species; genes without a Swiss-Prot hit have none.
- Grouping by shared reads (Corset, Grouper) would separate paralogues better, but this would require
  reprocessing from raw reads.

## References

- Tsissios G, Sallese A, Perez-Estrada JR, et al. (2024) Macrophages modulate fibrosis during newt lens regeneration. *Stem Cell Res Ther* 15:141. https://doi.org/10.1186/s13287-024-03740-1
- Abdullayev I, Kirkham M, Björklund ÅK, Simon A, Sandberg R (2013) A reference transcriptome and inferred proteome for the salamander *Notophthalmus viridescens*. *Exp Cell Res* 319:1187-1197. https://doi.org/10.1016/j.yexcr.2013.02.013
- Davidson NM, Oshlack A (2014) Corset: enabling differential gene expression analysis for de novo assembled transcriptomes. *Genome Biol* 15:410.
- Malik L, Almodaresi F, Patro R (2018) Grouper: graph-based clustering and annotation for improved de novo transcriptome analysis. *Bioinformatics* 34:3265-3272.
- Vdovin G et al. (under revision) Hypoxia inhibits cell cycle re-entry of newt skeletal muscle.
