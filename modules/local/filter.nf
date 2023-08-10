
process FILTER {
    tag "$meta.id"
    label 'process_single'

    conda "conda-forge::python=3.10.2"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.10.2':
        'biocontainers/python:3.10.2' }"

    input:
    tuple val(meta), path(fasta)
    
    output:
    tuple val(meta), path ('*.fa') , emit: fasta_ch 
    tuple val(meta), path ('*.txt'), emit: log_ch
    path "versions.yml"            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def threshold = task.ext.threshold ?: 1000
    def prefix    = task.ext.prefix    ?: "${meta.id}"
    """
    filter_by_length.py \\
        --input $fasta \\
        --min_len $threshold \\
        --output ${prefix}_filtered.fa
        
    grep -c ">" $fasta > ${prefix}_original.txt
    grep -c ">" ${prefix}_filtered.fa > ${prefix}_filtered.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        filter_by_length.py: \$( filter_by_length.py --version | sed -e 's/Version //g' )
    END_VERSIONS
    """

    stub:
    def threshold = task.ext.threshold ?: 1000
    def prefix    = task.ext.prefix    ?: "${meta.id}"
    """
    touch ${prefix}_filtered.fa
    touch ${prefix}_original.txt
    touch ${prefix}_filtered.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        filter_by_length.py: \$( filter_by_length.py --version | sed -e 's/Version //g' )
    END_VERSIONS
    """
}

// TODO
// The input fasta must be compressed
// The output fasta has to be compressed at the end.
// Follow PRODIGAL example
