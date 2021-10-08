#!/usr/bin/env python3
#
# Reformat THOMAS volume outputs to CSV.

import argparse
import os
import pandas


parser = argparse.ArgumentParser()
parser.add_argument('--out_dir', default='/OUTPUTS')
args = parser.parse_args()

left = pandas.read_csv(os.path.join(args.out_dir, 'left', 'nucleiVols.txt'), sep='\s+', header=None)
right = pandas.read_csv(os.path.join(args.out_dir, 'right', 'nucleiVols.txt'), sep='\s+', header=None)

names = list('L-' + left[0]) + list('R-' + right[0])
data = list(left[1]) + list(right[1])

csv = pandas.DataFrame([data], columns=names)

csv.to_csv(os.path.join(args.out_dir, 'nucleiVols.csv'), index=False)
