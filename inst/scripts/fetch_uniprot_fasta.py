# Protein sequences of the Swiss-Prot proteins hit by the transcriptome, from the UniProt REST API (downloaded 2026-10-11), for the blastx database.
import csv, urllib.parse, urllib.request

accessions = sorted({row["accession"] for row in csv.DictReader(open("uniprot/uniprot_go.tsv"), delimiter="\t")})

out = open("uniprot/swissprot_hits.fa", "w")

# 100 accessions per request
for i in range(0, len(accessions), 100):
    query = " OR ".join("accession:" + a for a in accessions[i:i + 100])
    url = "https://rest.uniprot.org/uniprotkb/stream?query=" + urllib.parse.quote(query) + "&format=fasta"
    out.write(urllib.request.urlopen(url).read().decode())

out.close()
