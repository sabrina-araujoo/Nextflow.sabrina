# Pipeline Nextflow: FASTQ para VCF

Este pipeline transforma arquivos FASTQ emparelhados em arquivos VCF, usando bwa, samtools e bcftools.

## Como usar
- É necessário ativar ambiente conda
- "conda activate base"

- Usar os arquivos do data e referencia 

### Requisitos
- Nextflow
- Conda

### Rodando o pipeline
- Com o conda ativado é só rodar o coamndo a seguir: 
nextflow run sabrina.nf -with-conda -resume

