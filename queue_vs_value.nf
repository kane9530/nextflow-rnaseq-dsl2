/* Inspired by https://training.nextflow.io/basic_training/channels/#value-channels */

nextflow.enable.dsl=2

process addTwoValues {
    debug true
    input:
    val x 
    val y

    /*
    In the shell block below, !{} denotes the nextflow variables whereas $sum
    refers to the bash variable "sum". $(()) is used to evaluate the summation
    in bash.
    */

    shell:
    '''
    sum=$((!{x} + !{y}))
    echo "The sum is: $sum"
    '''
}

channel_1 = Channel.of(1,2,3)
channel_4 = Channel.of(8) //Queue channel with a single item. Once 8 is read, the next item is a poison pill, which will tell the process that there’s nothing left to be consumed.
channel_4_value = Channel.value(4) //Value channel that can be consumed indefinitely. 

/*
The queue_channel and value_channel workflows are functionally identical, but
we create them separately to be able to run them both in the implicit workflow (
taken as the default entrypoint). 
*/

workflow queue_channel{
    take:
        first_queue_channel
        second_queue_channel
    main:
        addTwoValues(first_queue_channel, second_queue_channel)
}

workflow value_channel{
    take:
        first_queue_channel
        second_value_channel
    main:
        addTwoValues(first_queue_channel, second_value_channel)
}

/*
In the implicit workflow, queue_channel workflow returns only a single sum whereas the 
value_channel workflow returns 3 sums. 
*/

workflow {
    main:
        queue_channel(channel_1, channel_4)
        value_channel(channel_1, channel_4_value)
}

workflow.onComplete{
    log.info(workflow.success ? "\nDone!" : "\nOops, something went wrong...")
}

