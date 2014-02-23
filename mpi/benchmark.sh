#!/bin/bash

if [ $# -ne 1 ] ; then
  echo "benchmark.sh <flavor>"
  exit 1
fi

flavor=$1
nb_nodes=$(cat hosts | wc -l)
container="results_flavor_$flavor"

if [ $flavor = "3" ] ; then
  npernode=2
elif [ $flavor = "4" ] ; then
  npernode=4
else
  npernode=1
fi

for n in 128 256 512 1024 1360 ; do
  [ -d "matrices" ] || mkdir -p matrices
  [ -e "matrices/matrix1_$n" ] || ./matrix_gen.rb $n $n > matrices/matrix1_$n
  [ -e "matrices/matrix2_$n" ] || ./matrix_gen.rb $n $n > matrices/matrix2_$n

  ./run_matrix_multiply.sh hosts matrices/matrix1_$n matrices/matrix2_$n $container result_${nb_nodes}_${n} $npernode
done
