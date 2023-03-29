params.outdir = "results"

process INDEX {
    
    input:
    path transcriptome 
     
    output:
    path 'index'

    script:       
    """
    salmon index --threads $task.cpus -t $transcriptome -i index
    """
}

/*
 * Run Salmon to perform the quantification of expression using
 * the index and the matched read files
 */
process QUANT {
    tag "$pair_id"

    publishDir "${params.outdir}/quant", mode:"copy", failOnError:true
     
    input:
    path index
    tuple val(pair_id), path(reads)
 
    output:
    path(pair_id)
 
    script:
    """
    salmon quant --threads $task.cpus --libType=U -i $index -1 ${reads[0]} -2 ${reads[1]} -o $pair_id
    """
}

/*
 * Run fastQC to check quality of reads files
 */
process FASTQC {
    tag "$pair_id"
    publishDir "${params.outdir}/fastqc", mode:"copy", failOnError:true

    input:
    tuple val(pair_id), path(reads)

    output:
    path("fastqc_${pair_id}_logs")

    script:
    """
    mkdir fastqc_${pair_id}_logs
    fastqc -o fastqc_${pair_id}_logs -f fastq -q ${reads}
    """  
}  

process MULTIQC {
    publishDir "${params.outdir}/multiqc", mode:"copy", failOnError:true

    input:
    path("*")

    output:
    path("multiqc_report.html")

    script:
    """
    multiqc .
    """
}