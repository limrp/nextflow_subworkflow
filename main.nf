#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    nf-core/metagen
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/nf-core/metagen
    Website: https://nf-co.re/metagen
    Slack  : https://nfcore.slack.com/channels/metagen
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

params.csv = './path/to/default.csv'  // placeholder path to csv input

Channel
    .fromPath(params.csv)
    .splitCsv(header: false, sep: ',')
    .filter { row -> row[0] != "sample_id" && row[0] != "sample" }  // This will filter out the header line
    //.filter { row -> !(row[0] == "sample_id" || row[0] == "sample") } // This will also filter out the header line
    .map { row -> [ [id: row[0]], file(row[1].trim()) ] } 
    .set { fasta_ch }

    // .trim() to ensure that any leading or trailing spaces in the file paths are removed
    // fasta_ch is a channel of tuples: val(meta), file(path/to/fasta)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOW FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { FASTA_METAPRODIGAL_CDHIT } from './subworkflows/local/fasta_metaprodigal_cdhit.nf'

//
// WORKFLOW: Run main nf-core/metagen analysis pipeline
//
workflow NFCORE_METAGEN {
    FASTA_METAPRODIGAL_CDHIT(fasta_ch)
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN ALL WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// WORKFLOW: Execute a single named workflow for the pipeline
// See: https://github.com/nf-core/rnaseq/issues/619
//
workflow {
    NFCORE_METAGEN ()
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
