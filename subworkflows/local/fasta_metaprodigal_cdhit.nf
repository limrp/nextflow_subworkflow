include { PRODIGAL             } from '../../modules/nf-core/prodigal/main'
include { CDHIT_CDHIT          } from '../../modules/nf-core/cdhit/cdhit/main'
include { FILTER as FILTER_one } from '../../modules/local/filter.nf'
include { FILTER as FILTER_two } from '../../modules/local/filter.nf'

workflow FASTA_METAPRODIGAL_CDHIT {

    take:
    // input (take) channels
    ch_metagenome // channel: [ val(meta), [ genome ]] => tuple

    main:

    ch_versions = Channel.empty()

    FILTER_one( ch_metagenome )
    ch_versions = ch_versions.mix(FILTER_one.out.versions.first())

    // prodigal expects a zipped input fasta
    // Filter must give a zipped output
    PRODIGAL( FILTER_one.out.fasta_ch ) 
    ch_versions = ch_versions.mix(PRODIGAL.out.versions.first())

    FILTER_two( PRODIGAL.out.nucleotide_fasta )
    ch_versions = ch_versions.mix(FILTER_two.out.versions.first())

    CDHIT_CDHIT( FILTER_two.out.fasta_ch )
    ch_versions = ch_versions.mix(CDHIT_CDHIT.out.versions.first())

    emit:

    // TODO: Add structure of each channel
    fasta                = FILTER_one.out.fasta_ch
    log                  = FILTER_one.out.log_ch
    gene_annotations     = PRODIGAL.out.gene_annotations
    nucleotide_fasta     = PRODIGAL.out.nucleotide_fasta
    amino_acid_fasta     = PRODIGAL.out.amino_acid_fasta
    all_gene_annotations = PRODIGAL.out.all_gene_annotations
    fasta_two            = FILTER_two.out.fasta_ch
    log_two              = FILTER_two.out.log_ch
    fasta                = CDHIT_CDHIT.out.fasta
    clusters             = CDHIT_CDHIT.out.clusters

    versions             = ch_versions                        // channel: [ versions.yml ]

}

