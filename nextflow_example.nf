#!/usr/bin/env nextflow

TRIMMOMATIC = "${HOME}/tools/Trimmomatic-0.39/trimmomatic-0.39.jar"
ADAPTERS = "${HOME}/tools/Trimmomatic-0.39/adapters/NexteraPE-PE.fa"


Channel
    .fromFilePairs( params.reads, flat: true )
    .ifEmpty { error "Cannot find any reads matching: ${params.reads}" }
    .set { read_pairs }


process QualityControl {
    tag {dataset_id}
    
    publishDir "${params.output}/QualityControl"
    
    input:
        set dataset_id, file(forward), file(reverse) from read_pairs
    output:
        file "${dataset_id}_paired_R1.fastq"
        file "${dataset_id}_paired_R2.fastq"
    
    """
    java -jar ${TRIMMOMATIC} PE $forward $reverse \
      ${dataset_id}_paired_R1.fastq \
      ${dataset_id}_unpaired_R1.fastq \
      ${dataset_id}_paired_R2.fastq \
      ${dataset_id}_unpaired_R2.fastq \
      ILLUMINACLIP:${ADAPTERS}:2:30:10:3:TRUE \
      LEADING:3 \
      TRAILING:3 \
      SLIDINGWINDOW:4:15 \
      MINLEN:36
 
    """
}


