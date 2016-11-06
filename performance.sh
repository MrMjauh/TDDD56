#!/bin/bash
NB_THREADS=$1;

for ((i = 1; i <= $NB_THREADS; i++)); do
	make NB_THREADS = 2
done