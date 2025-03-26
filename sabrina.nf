#!/usr/bin/env nextflow

params.reads = "/workspaces/training/nf-training/data/samples_sabrina/*_{1,2}.fastq"
params.ref   = "/workspaces/training/nf-training/data/referencia/referencia_pertenue.fna"

Channel.fromFilePairs(params.reads, flat: true)
       .set { read_pairs }

ref_ch = Channel.fromPath(params.ref)

process index_reference {
    conda = "/workspaces/training/nf-training/env.yml"

    input:
    path ref_path

    output:
    path "*.bwt"
    path "*.fai"
    path "*.amb"
    path "*.ann"
    path "*.pac"
    path "*.sa"

    script:
    """
    bwa index "$ref_path"
    samtools faidx "$ref_path"
    """
}

process print_pairs {

    // Desabilita herança do Conda global
    container = ''
    conda = null

    input:
    tuple val(sample), path(read1), path(read2)

    script:
    """
    echo "📦 Sample: $sample"
    echo "🔹 Read 1: $read1"
    echo "🔹 Read 2: $read2"
    """
}


process align_reads {
    conda = "/workspaces/training/nf-training/env.yml"

    input:
    tuple val(sample), path(reads), path(ref)

    output:
    path "${sample}.bam"

    script:
    """
    bwa mem "$ref" \${reads[0]} \${reads[1]} | \\
    samtools view -Sb - | \\
    samtools sort -o ${sample}.bam
    """
}

process index_bam {
    conda = "/workspaces/training/nf-training/env.yml"

    input:
    path bam

    output:
    path "${bam}.bai"

    script:
    """
    samtools index $bam
    """
}

process call_variants {
    conda = "/workspaces/training/nf-training/env.yml"

    input:
    tuple path(bam), path(bai), path(ref)

    output:
    path "${bam.baseName}.vcf"

    script:
    """
    bcftools mpileup -f "$ref" "$bam" | \
    bcftools call -mv -Ov -o ${bam.baseName}.vcf
    """
}

workflow {
    ref_index = index_reference(ref_ch)
    read_pairs = Channel.fromFilePairs(params.reads, flat: true)
    read_pairs.view()
    read_pairs | print_pairs

    aligned = read_pairs.map { sample, read1, read2 ->
    tuple(sample, [read1, read2], params.ref)
} | align_reads

    indexed = aligned | index_bam

    aligned.combine(indexed).map { a, b -> tuple(a, b, params.ref) } | call_variants
}
