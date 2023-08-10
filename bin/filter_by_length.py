import argparse

def read_and_filter_fasta(file, threshold):
    # Open the original fasta file with the gene sequences
    with open(file, 'r') as f:
        sequences = {}
        seq_id = None
        seq = []

        # Iterating over the lines of the file
        for line in f:
            line = line.strip()
            if line.startswith('>'):
                if seq_id is not None:
                    sequence = '\n'.join(seq)
                    if len(sequence.replace('\n', '')) >= threshold:
                        sequences[seq_id] = sequence
                seq_id = line[1:]
                seq = []
            else:
                seq.append(line)
        
        # To evaluate the last gene sequence
        if seq_id is not None:
            sequence = '\n'.join(seq)
            if len(sequence.replace('\n', '')) >= threshold:
                sequences[seq_id] = sequence
        
        # Returning a dictionary with the sequences whose length was longer than the threshold
        return sequences

def main():
    parser = argparse.ArgumentParser(description='Read and filter sequences in a FASTA file by length.')
    parser.add_argument('--input', '-i', type=str, required=True, help='The input FASTA file.')
    parser.add_argument('--min_len', '-m', type=int, required=True, help='The minimum sequence length.')
    parser.add_argument('--output', '-o', type=str, required=True, help='The output FASTA file.')
    parser.add_argument('--version', '-v', action='version', version='Version 1.0', help='Show the version number and exit.')
    args = parser.parse_args()

    # dictionary with the sequences whose length was longer than the threshold
    sequences = read_and_filter_fasta(args.input, args.min_len)

    # Saving to a fasta file the elements of the sequences dictionary
    with open(args.output, 'w') as f:
        for id, seq in sequences.items():
            f.write(f'>{id}\n{seq}\n')

if __name__ == '__main__':
    main()
