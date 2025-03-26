# Pipeline Nextflow: FASTQ para VCF

Este pipeline transforma arquivos FASTQ emparelhados em arquivos VCF, usando bwa, samtools e bcftools.

## Como usar
É necessário ativar ambiente conda
Usar os arquivos do data e referencia 

### Requisitos
- Nextflow
- Conda

### Rodando o pipeline
nextflow run sabrina.nf -with-conda
