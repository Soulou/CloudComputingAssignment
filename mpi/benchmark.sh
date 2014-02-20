#!/bin/bash

nb_nodes=$(cat hosts | wc -l)
mkdir -p results

for n in 128 256 512 1024 ; do
  ./matrix_gen.rb ${n} ${n} > matrix1_${nb_nodes}_${n}
  ./matrix_gen.rb ${n} ${n} > matrix2_${nb_nodes}_${n}

  ./run_matrix_multiply.sh hosts matrix1_${nb_nodes}_${n} matrix2_${nb_nodes}_${n} container result_${nb_nodes}_${n}
  mv result_${nb_nodes}_${n} results
done
