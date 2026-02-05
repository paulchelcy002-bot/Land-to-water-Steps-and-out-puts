#!/bin/bash

############################################
# PATHS (F12 – Hippopotamus as query)
############################################
BASE_DIR="$HOME/Dissertation"
GENOMES_DIR="$BASE_DIR/GENOMES"   # ✅ FIXED
QUERY="$BASE_DIR/GENE/F12/Hippopotamus/hippo_f12_exons.fasta"
RESULTS_DIR="$BASE_DIR/RESULTS/F12/Hippopotamus"

THREADS=8

mkdir -p "$RESULTS_DIR"

############################################
# PART 1: Create BLAST databases (if missing)
############################################
for dir in "$GENOMES_DIR"/*; do
    [ -d "$dir" ] || continue
    species=$(basename "$dir")

    echo "===================================="
    echo "Processing species: $species"
    echo "===================================="

    if [[ -f "$dir/${species}.nin" ]]; then
        echo "✅ BLAST DB already exists for $species"
    else
        if ls "$dir"/*.fna 1>/dev/null 2>&1; then
            echo "Creating BLAST DB for $species"
            makeblastdb \
              -in "$dir"/*.fna \
              -dbtype nucl \
              -parse_seqids \
              -out "$dir/$species"
        else
            echo "⚠️ No .fna file found for $species — skipping"
            continue
        fi
    fi
done

############################################
# PART 2: blastn-short (outfmt 3)
############################################
for dir in "$GENOMES_DIR"/*; do
    [ -d "$dir" ] || continue
    species=$(basename "$dir")

    blastn \
      -task blastn-short \
      -query "$QUERY" \
      -db "$dir/$species" \
      -outfmt 3 \
      -evalue 0.001 \
      -dust no \
      -num_threads $THREADS \
      -out "$RESULTS_DIR/HippoF12_vs_${species}_blastn_short.txt"
done

############################################
# PART 3: blastn-short (outfmt 6)
############################################
for dir in "$GENOMES_DIR"/*; do
    [ -d "$dir" ] || continue
    species=$(basename "$dir")

    blastn \
      -task blastn-short \
      -query "$QUERY" \
      -db "$dir/$species" \
      -outfmt "6 qseqid sseqid pident length evalue bitscore" \
      -evalue 0.001 \
      -dust no \
      -num_threads $THREADS \
      -out "$RESULTS_DIR/HippoF12_vs_${species}_blastn_short.tsv"
done

############################################
# PART 4: dc-megablast (outfmt 6)
############################################
for dir in "$GENOMES_DIR"/*; do
    [ -d "$dir" ] || continue
    species=$(basename "$dir")

    blastn \
      -task dc-megablast \
      -query "$QUERY" \
      -db "$dir/$species" \
      -outfmt "6 qseqid sseqid pident length evalue bitscore stitle" \
      -evalue 0.001 \
      -dust no \
      -num_threads $THREADS \
      -out "$RESULTS_DIR/HippoF12_vs_${species}_dcmegablast.tsv"
done

############################################
# PART 5: dc-megablast (outfmt 3)
############################################
for dir in "$GENOMES_DIR"/*; do
    [ -d "$dir" ] || continue
    species=$(basename "$dir")

    blastn \
      -task dc-megablast \
      -query "$QUERY" \
      -db "$dir/$species" \
      -outfmt 3 \
      -evalue 0.001 \
      -dust no \
      -num_threads $THREADS \
      -out "$RESULTS_DIR/HippoF12_vs_${species}_dcmegablast.txt"
done

echo "✅ F12 Hippopotamus BLAST pipeline completed successfully"

