# Nextflow RNA-seq DSL2

This repository consists of a simple RNAseq Nextflow workflow in DSL-2 (`main.nf`) adapted from the [Sequera Nextflow tutorial](https://github.com/seqeralabs/nextflow-tutorial). 

To run the pipeline, install nextflow and run:
```
nextflow run main.nf
```

# Modifications to Sequera labs tutorial

The key modification I've made is to allow all fastq pairs in the `data/ggal`
directory (liver, gut and lung) to be passed through the pipeline. In the tutorial,
only the fastq reads with the `gut` prefix are quantified: 
```
params.reads = "$baseDir/data/ggal/gut_{1,2}.fq"
```

I've made 2 changes to the workflow script to enable this.

1. Regular expression change

```
params.reads = "$baseDir/data/ggal/*_{1,2}.fq"
```

2. Converting the transcriptome_ch from a queue to value channel

This change is more subtle and instructive than the first. As the `transcriptome_ch` is constructed
with the `Channel.fromPath` channel factory method, it creates a queue channel.
As opposed to a value/singleton channel, a queue channel's contents are consumed as the channel
is read. Since `transcriptome_ch` outputs the path to the single `index` file, when
it is supplied as an input to `QUANT` together with the `read_pairs_ch` which contains 3
items, **only the first read pair** is processed. Hence, to ensure that the index file can be read an unlimited number of times without 
being consumed, I transformed the index file emitted from the channel into a single list with the
`.collect()` operator, which creates a value channel. 

```
transcriptome_ch = Channel
        .fromPath(params.transcriptome, checkIfExists:true)
        .collect()
```

This is discussed in the [Nextflow Channel docs](https://www.nextflow.io/docs/latest/channel.html), and is a similar issue to this [post](https://bioinformatics.stackexchange.com/questions/18321/how-fo-force-nextflow-to-repeat-a-process-until-all-values-in-a-particular-chann) in stackexchange.

To illustrate the importance of distinguishing value from queue channels, I've added the 
`queue_vs_value.nf` workflow in the directory which showcases the distinction between
value and queue channels.







