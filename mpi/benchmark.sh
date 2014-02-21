#!/bin/bash

nb_nodes=$(cat hosts | wc -l)
mkdir -p results

for n in 128 256 512 1024 ; do
  [ -e "matrix1_$n" ] || ./matrix_gen.rb $n $n > matrix1_$n
  [ -e "matrix2_$n" ] || ./matrix_gen.rb $n $n > matrix2_$n

  ./run_matrix_multiply.sh hosts matrix1_$n matrix2_$n container result_${nb_nodes}_${n}
  mv result_${nb_nodes}_${n} results
done
