#!/bin/bash

function die() {
  echo $*
  exit 1
}

for flavor in 1 2 3 4 ; do
  for nbnodes in 1 2 4 8 16 ; do
    MAX_WAIT_TIME=300 INSTANCE_FLAVOR=$flavor ./create_cluster.rb $nbnodes|| die "Fail to create cluster"
    pushd mpi
    ./benchmark.sh $flavor || die "Fail to run benchmark"
    popd
    ./create_cluster.rb --purge || die "Fail to destroy the cluster"
  done
done
