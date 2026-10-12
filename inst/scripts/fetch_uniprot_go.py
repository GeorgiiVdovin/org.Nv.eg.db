# Gene names and GO terms of the Swiss-Prot proteins hit by the transcriptome, from the UniProt REST API (downloaded 2026-10-11).
import csv, gzip, urllib.parse, urllib.request

# The hit accessions (package_inputs.R), and those of Myf5, Myog and Myf6
accessions = {row["accession"] for row in csv.DictReader(gzip.open("swissprot/swissprot_hits.csv.gz", "rt"))}
accessions |= {row["UNIPROT_swissp"] for row in csv.DictReader(open("sandberg_mrf/sandberg_mrf_annotation.csv"))}
accessions = sorted(accessions)

out = open("uniprot/uniprot_go.tsv", "w")
out.write("accession\tgene_primary\tgo_ids\treviewed\n")

# 100 accessions per request; fetch first line (header)
for i in range(0, len(accessions), 100):
    query = " OR ".join("accession:" + a for a in accessions[i:i + 100])
    url = ("https://rest.uniprot.org/uniprotkb/search?query=" + urllib.parse.quote(query) +
           "&fields=accession,gene_primary,go_id,reviewed&format=tsv&size=500")
    lines = urllib.request.urlopen(url).read().decode().strip().split("\n")[1:]
    out.write("".join(line + "\n" for line in lines))

out.close()
