# Inputs of the org.Nv.eg.db notebooks.
# The transcriptome is from Tsissios et al. (2024), GEO GSE236907 (GSE236907_NVir_transcriptome.fasta.gz).
# The Swiss-Prot hits are the author's own (Vdovin et al., under revision): TransDecoder ORFs searched with blastp against Swiss-Prot on Galaxy

library(Biostrings)
library(data.table)


# Myf5, Myog and Myf6 (Mrf4) are missing from the transcriptome. Their contigs and annotation come from the transcriptome of Abdullayev et al. (2013)
sandberg_mrf <- c(comp460329_c0_seq1  = "Myf5",
                  comp2268858_c0_seq1 = "Myf5",
                  comp799573_c0_seq1  = "Myog",
                  comp117581_c0_seq1  = "Myf6",
                  comp1095579_c0_seq1 = "Myf6")

sandberg_dir <- "sandberg_reference_realigned_bulk/Sandberg N.viridescence reference files"

sandberg_fasta <- readDNAStringSet(file.path(sandberg_dir, "reference_transcripts_v2.fa.gz"))
names(sandberg_fasta) <- sub(" .*", "", names(sandberg_fasta))

mrf_fasta <- sandberg_fasta[names(sandberg_mrf)]
names(mrf_fasta) <- paste(names(mrf_fasta), sandberg_mrf, "(Sandberg transcriptome, Abdullayev et al. 2013)")

writeXStringSet(mrf_fasta, "newt_a1_browser/org.Nv.eg.db/inst/extdata/myf5_myog_myf6.fasta.gz", compress = TRUE)

sandberg_annotation <- read.csv(file.path(sandberg_dir, "Nviridenscens_annotations.csv"), check.names = FALSE)
mrf_annotation <- sandberg_annotation[sandberg_annotation$target_id %in% names(sandberg_mrf), ]
mrf_annotation$SYMBOL_merged <- sandberg_mrf[mrf_annotation$target_id]

write.csv(mrf_annotation, "newt_a1_browser/build/input/sandberg_mrf/sandberg_mrf_annotation.csv", row.names = FALSE)


# The transcriptome with the five contigs appended: the reference of every step (856,461 transcripts)
transcriptome <- readDNAStringSet("Katia_Reference_OG/NVir_transcriptome_katia.fasta") # The GEO GSE236907 file

writeXStringSet(c(transcriptome, mrf_fasta), "newt_a1_browser/reference/Nvir_transcriptome_tsissios_mrf.fa.gz", compress = TRUE)


# Best Swiss-Prot hit of each transcript: accession, entry-name symbol, protein name, identity, E-value and bit score
swissprot <- fread("Nvir_Annotations/Nvir Latest Annotation Katia/Nvir_annotations_MT_Katia_final.csv",
                   select = c("txid", "stitle_SP", "Uniprot_SP", "Description_SP", "pident_SP", "evalue_SP", "bitscore_SP"))

swissprot <- swissprot[!is.na(stitle_SP)]
setnames(swissprot, c("txid", "accession", "entry_symbol", "protein", "pident", "evalue", "bitscore"))

dir.create("newt_a1_browser/build/input/swissprot", showWarnings = FALSE)
fwrite(swissprot, "newt_a1_browser/build/input/swissprot/swissprot_hits.csv.gz")
