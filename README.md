# org.Nv.eg.db

Gene annotation for the eastern newt, *Notophthalmus viridescens*, as an R `OrgDb`
package. It works with the AnnotationDbi `select()` interface and with clusterProfiler
like `org.Hs.eg.db` or `org.Mm.eg.db`, and carries the transcript-to-gene table for
tximport.

## Install

```r
install.packages("remotes")
remotes::install_github("GeorgiiVdovin/org.Nv.eg.db")   # also installs AnnotationDbi from Bioconductor
```

## Use

```r
library(org.Nv.eg.db)

columns(org.Nv.eg.db)
select(org.Nv.eg.db, keys = c("Pax7", "Myf5", "Hif3a"), keytype = "SYMBOL",
       columns = c("GID", "GENENAME", "UNIPROT"))

# The gene of a transcript
select(org.Nv.eg.db, keys = "2_12041898", keytype = "TXID", columns = c("GID", "SYMBOL"))

# GO enrichment of a gene list against the expressed genes
library(clusterProfiler)
enrichGO(genes, OrgDb = org.Nv.eg.db, keyType = "GID", ont = "BP", universe = expressed)

# Transcript to gene table for tximport (salmon or kallisto against the same transcriptome)
tx2gene <- read.csv(system.file("extdata", "tx2gene_nvir_clusters.csv.gz", package = "org.Nv.eg.db"))
```

| key | |
|-----|--|
| `GID` | the gene, `NVG000001` to `NVG728711` |
| `SYMBOL`, `GENENAME` | gene name and protein name of the best Swiss-Prot hit (`Hif3a`; a second gene with the same best hit is `Hif3a.2`) |
| `UNIPROT` | the Swiss-Prot accessions hit by the gene's transcripts |
| `GO`, `EVIDENCE`, `ONTOLOGY`; `GOALL`, `EVIDENCEALL`, `ONTOLOGYALL` | GO terms, and GO terms with all their ancestors |
| `TXID` | the transcripts of the gene |

## The transcriptome

The genes are built on the de novo transcriptome of Tsissios et al. (2024), published with GEO
series [GSE236907](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE236907)
(`GSE236907_NVir_transcriptome.fasta.gz`), plus the five contigs of Myf5, Myog and Myf6 from
Abdullayev et al. (2013), which are included in this package. If you are interested in adding 
more genes - get in touch. To quantify against the same 856,461 transcripts:

```r
options(timeout = 3600)   # 260 MB
download.file("https://ftp.ncbi.nlm.nih.gov/geo/series/GSE236nnn/GSE236907/suppl/GSE236907_NVir_transcriptome.fasta.gz",
              "nvir_transcriptome.fasta.gz", mode = "wb")
file.append("nvir_transcriptome.fasta.gz",
            system.file("extdata", "myf5_myog_myf6.fasta.gz", package = "org.Nv.eg.db"))
```
This assembles the transcriptome that this annotation is written for. You can then index 
`nvir_transcriptome.fasta.gz` with salmon or kallisto, and summarise the transcript
counts per gene with tximport and the tx2gene table above.

## What a gene is

The transcriptome is the de novo assembly of Tsissios et al. (2024): 856,456 transcripts,
assembled per condition with Trinity and merged with DRAP, so most genes are represented by
several overlapping fragments, alleles and isoforms. **The transcriptome was not reassembled,
filtered or edited**: every transcript is used as published, and salmon or kallisto quantify
against the same sequences. What this package adds is a new **transcript-to-gene mapping**,
made from the transcripts themselves:

1. An all-vs-all megablast of the transcripts. Two transcripts are linked when they align at
   98 % identity or more, over at least 300 bp and 25 % of the shorter one; the connected
   groups are the genes. 
2. Groups that chain together two transcripts below 97 % identity (through a third one that
   matches both) are split by complete-linkage clustering, so that every aligned pair inside
   a gene is at least 97 % identical.
3. Fragments of one gene that do not overlap are joined when they align (blastx) to different,
   non-overlapping parts of the same Swiss-Prot protein.

Myf5, Myog and Myf6 (Mrf4) are missing from this transcriptome, also at the sequence level.
Their contigs were added from the transcriptome of Abdullayev et al. (2013), as three genes.
MyoD is in neither.

|  | genes |
|--|------:|
| all (856,461 transcripts) | 728,711 |
| with a Swiss-Prot hit and a gene symbol | 67,655 (15,140 names) |
| with GO terms | 66,942 |

The annotation is from Vdovin et al. (under revision): the open reading frames of
every transcript (TransDecoder) were searched with blastp against Swiss-Prot, and each gene takes
its name from the best hit among its transcripts. 

## How it was built

`METHODS.md` describes every step. The scripts are in `inst/scripts/`: `package_inputs.R` prepares the 
inputs, the BLAST and UniProt scripts make the alignments and download the protein data, 
`5_gene_clusters.Rmd` makes the genes, `6_cluster_annotation.Rmd` annotates them and `7_org_package.Rmd` 
builds the database with AnnotationForge 1.52.0. The package files (`DESCRIPTION`, `NAMESPACE`, `R/zzz.R`, `man/`) 
follow the AnnotationForge template; `R/zzz.R` adds the unpacking step.

## Sources
If you use this package, please cite Vdovin G et al. (under revision). Hypoxia inhibits cell 
cycle re-entry of newt skeletal muscle. (Swiss-Prot annotation of the transcriptome), as well 
as the two source data transcriptomes:
- Tsissios G, Sallese A, Perez-Estrada JR, et al. (2024). Macrophages modulate fibrosis
  during newt lens regeneration. *Stem Cell Res Ther* 15, 141.
  https://doi.org/10.1186/s13287-024-03740-1 (transcriptome)
- Abdullayev I, Kirkham M, Björklund ÅK, Simon A, Sandberg R (2013). A reference
  transcriptome and inferred proteome for the salamander *Notophthalmus viridescens*.
  *Exp Cell Res* 319, 1187-1197. https://doi.org/10.1016/j.yexcr.2013.02.013 (Myf5, Myog, Myf6)
- UniProtKB/Swiss-Prot (gene names, accessions and GO) and the Gene Ontology.

## License

The code is MIT-licensed (see `LICENSE.md`). The gene names and GO terms come from UniProt and the Gene Ontology, both under CC BY 4.0.
