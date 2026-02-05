#!/bin/bash

############################################
# PATHS
############################################
BASE_DIR="$HOME/Dissertation"
GENOMES_DIR="$BASE_DIR/GENOMES"
GENE_DIR="$BASE_DIR/GENE"
RESULTS_DIR="$BASE_DIR/RESULTS"

QUERY="$GENE_DIR/renamed_exons.fasta"
THREADS=8

mkdir -p "$RESULTS_DIR"

############################################
# PART 1: Create BLAST databases
############################################
for dir in "$GENOMES_DIR"/*/; do
    species=$(basename "$dir")

    echo "===================================="
    echo "Creating BLAST database for: $species"
    echo "===================================="

    cd "$dir" || continue

    if ls *.fna 1>/dev/null 2>&1; then
        makeblastdb \
            -in *.fna \
            -dbtype nucl \
            -parse_seqids \
            -out "$species"
    else
        echo "⚠️  No .fna file found in $species"
    fi
done

############################################
# PART 2: blastn-short (outfmt 3)
############################################
for dir in "$GENOMES_DIR"/*/; do
    species=$(basename "$dir")

    echo "Running blastn-short (outfmt 3) for $species"

    blastn \
      -task blastn-short \
      -query "$QUERY" \
      -db "$dir/$species" \
      -outfmt 3 \
      -evalue 0.001 \
      -dust no \
      -num_threads $THREADS \
      -out "$RESULTS_DIR/Human_vs_${species}_blastn_short.txt"
done

############################################
# PART 3: blastn-short (outfmt 6)
############################################
for dir in "$GENOMES_DIR"/*/; do
    species=$(basename "$dir")

    echo "Running blastn-short (outfmt 6) for $species"

    blastn \
      -task blastn-short \
      -query "$QUERY" \
      -db "$dir/$species" \
      -outfmt "6 qseqid sseqid pident length evalue bitscore" \
      -evalue 0.001 \
      -dust no \
      -num_threads $THREADS \
      -out "$RESULTS_DIR/Human_vs_${species}_blastn_short.tsv"
done

############################################
# PART 4: dc-megablast (outfmt 6)
############################################
for dir in "$GENOMES_DIR"/*/; do
    species=$(basename "$dir")

    echo "Running dc-megablast (outfmt 6) for $species"

    blastn \
      -task dc-megablast \
      -query "$QUERY" \
      -db "$dir/$species" \
      -outfmt "6 qseqid sseqid pident length evalue bitscore stitle" \
      -evalue 0.001 \
      -dust no \
      -num_threads $THREADS \
      -out "$RESULTS_DIR/Human_vs_${species}_dcmegablast.tsv"
done

############################################
# PART 5: dc-megablast (outfmt 3)
############################################
for dir in "$GENOMES_DIR"/*/; do
    species=$(basename "$dir")

    echo "Running dc-megablast (outfmt 3) for $species"

    blastn \
      -task dc-megablast \
      -query "$QUERY" \
      -db "$dir/$species" \
      -outfmt 3 \
      -evalue 0.001 \
      -dust no \
      -num_threads $THREADS \
      -out "$RESULTS_DIR/Human_vs_${species}_dcmegablast.txt"
done

echo "✅ PIPELINE COMPLETED SUCCESSFULLY"
