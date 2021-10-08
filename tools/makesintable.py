#Tool to generate an 8-bit sine table with center offset (default 128)
#The generated sin table is written to a file given as an argument

import math
import argparse


def gen_sin(n, off, freq, ampl):
    return b''.join([int(off + math.sin((x * freq / n) * 180 / math.pi) * ampl).to_bytes(1,'little') for x in range(n)])

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Sine table generator")
    parser.add_argument('--count', '-n', type=int, default=0x100, help='Duration or number of points to generate (minimum: 1, default: 256)')
    parser.add_argument('--offset', '-c', type=int, default=0x80, help='Center position of the output wave')
    parser.add_argument('--freq', '-f', type=float, default=1.0, help='Frequency of the output wave, in Hz. Can be fractional')
    parser.add_argument('--amplitude', '-a', type=float, default=16.0, help='Amplitude of the output wave, in bytes. Can be fractional')
    parser.add_argument('filename', help="Output filename. Use '-' to output to stdout")
    args = parser.parse_args()

    if args.count <= 0:
        raise ValueError('Count must be 1 or larger')

    if args.filename == '-':
        #Write to stdout
        import sys
        #Note: On Windows, redirecting stdout to a file will cause it to become UTF-8 encoded, and will corrupt the data
        sys.stdout.buffer.write(gen_sin(args.count, args.offset, args.freq, args.amplitude))
        sys.stdout.flush()
    else:
        with open(args.filename, 'wb') as f:
            f.write(gen_sin(args.count, args.offset, args.freq, args.amplitude))