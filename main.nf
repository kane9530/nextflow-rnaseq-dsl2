nextflow.enable.dsl=2

/* 
Import tasks from module folder 
*/
include { INDEX; QUANT; FASTQC; MULTIQC  } from './modules/rnaseq-tasks.nf'

/* 
 * pipeline input parameters 
 */
params.reads = "$baseDir/data/ggal/*_{1,2}.fq"
params.transcriptome = "$baseDir/data/ggal/transcriptome.fa"
params.outdir = "results"


log.info """\
         R N A S E Q - N F   P I P E L I N E    
         ===================================
         transcriptome: ${params.transcriptome}
         reads        : ${params.reads}
         outdir       : ${params.outdir}
         """
         .stripIndent()

workflow {
    read_pairs_ch = Channel 
        .fromFilePairs( params.reads, checkIfExists:true)
    transcriptome_ch = Channel
        .fromPath(params.transcriptome, checkIfExists:true).collect()
    
    index_ch = INDEX(transcriptome_ch)
    quant_ch = QUANT(index_ch, read_pairs_ch)
    fastqc_ch = FASTQC(read_pairs_ch)
    multiqc_ch = MULTIQC(fastqc_ch.mix(quant_ch).collect())
}

workflow.onComplete{
    log.info (workflow.success ? "\nDone! Open the following report in your browser --> $params.outdir/multiqc/multiqc_report.html\n" : "Oops.. something went wrong!")
}

