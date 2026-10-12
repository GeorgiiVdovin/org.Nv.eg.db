\name{org.Nv.eg.db}
\alias{org.Nv.eg.db}
\alias{org.Nv.eg}
\title{Bioconductor annotation data package}
\description{

  Welcome to the org.Nv.eg.db annotation Package. This is an organism
  specific package for the eastern newt, Notophthalmus viridescens. A gene
  is a cluster of transcripts of the Tsissios et al. (2024) de novo
  transcriptome that overlap at >= 98 \% identity, with non-overlapping
  fragments of one gene joined through their alignments to the same
  Swiss-Prot protein; Myf5, Myog and Myf6 were added from the Abdullayev
  et al. (2013) transcriptome. The cluster IDs (GID) can be mapped to
  SYMBOL, GENENAME, UNIPROT, GO (also GOALL, with ancestors) and TXID (the
  transcripts). Gene names and GO terms come from the Swiss-Prot hits of
  the transcripts (TransDecoder ORFs, blastp; Vdovin et al., in
  preparation); GO terms are transferred from the hit entries (ISS).

  To learn more about this package, users are encouraged to learn about
  the select, columns, keys and keytypes methods.  These are described
  in a walkthrough on the bioconductor website as well as in the manual
  pages and vignettes in the AnnotationDbi package.
}
\examples{
columns(org.Nv.eg.db)
select(org.Nv.eg.db, keys = c("Pax7", "Myf5"), keytype = "SYMBOL",
       columns = c("GENENAME", "UNIPROT"))
}
\keyword{datasets}
