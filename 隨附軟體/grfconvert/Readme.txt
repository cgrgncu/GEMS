使用說明:

GRFConvert version 1.4.10 (Dec  3 2013 08:54:17), pid:2540

Usage: grfconvert [-hqdblNSvx] [-n name_format] [-f format] [-r rec_len]
                  [-t seconds] [-L list_file] [-o path] -s socket|image_file

   -h           Help display.
   -q           Quiet logging.
   -d           Debug logging.
   -b           Big endian output, if appropriate. (native)
   -l           Little endian output, if appropriate. (native)
   -N           If format is ASCII, don't include header info.
   -S           If format is ASCII, use simple single column format.
   -v           If format is ASCII or STATS, output samples in volts.
   -x           Drop data packets with 'unknown' or 'bad' time quality.
   -n format    Output file naming format string.
   -f format    Output data format:
                   ASCII, (GSE2.0), SAC, SEG-Y, SEED, SUDS, MATLAB, or STATS.
   -r rec_len   Output record length in seconds. (3600 seconds)
   -t seconds   Set socket read timeout. (30 seconds)
   -L list_file ASCII list file to append output filenames to. (none)
   -o path      Output directory. (./)
   -s socket    Socket endpoint to read GRF packets from.
                port number defaults to 3757 if not specified.
   image_file   GRF packet image file to read packets from.

[] = optional, () = default, | = mutually exclusive.

