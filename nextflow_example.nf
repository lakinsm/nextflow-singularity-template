#!/usr/bin/env nextflow

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
        set dataset_id, file("${dataset_id}_paired_R1.fastq"), file("${dataset_id}_paired_R2.fastq") into (assembly_input)
    
    """
    java -jar ${TRIMMOMATIC} PE $forward $reverse \
      ${dataset_id}_paired_R1.fastq \
      ${dataset_id}_unpaired_R1.fastq \
      ${dataset_id}_paired_R2.fastq \
      ${dataset_id}_unpaired_R2.fastq \
      ILLUMINACLIP:${ADAPTERS}:2:30:10:3:TRUE \
      LEADING:${params.leading} \
      TRAILING:${params.trailing} \
      SLIDINGWINDOW:${params.slidingwindow} \
      MINLEN:${params.minlen}
 
    """
}

process Assembly {
	tag {dataset_id}
	
	publishDir "${params.output}/Assembly"

	input:
		set dataset_id, file(trimmed_forward), file(trimmed_reverse) from assembly_input
	output:
		file "${dataset_id}_example"


	"""
	touch "${dataset_id}_example"
	"""
}
