#!/usr/bin/env bash

LOG=execution.log

function usage() {
  echo 'run_matrix_multiply.sh <hosts file> <matrix 1> <matrix 2> <swift container> <output matrix>'
  exit 1
}

# Check number of argument
[ $# -eq 5 ] || usage
# hosts file and input matrices should be present
for file in "$1" "$2" "$3" ; do
  if [ ! -e "$file" ] ; then
    echo "File \"$file\" does not exist"
    usage
  fi
done

# Deploy MPI Apps on nodes
exec_mpi=matrix_multiply
mpicc $exec_mpi.c -o $exec_mpi
hosts=$(cat "$1")
for host in $hosts ; do
  echo "Prepare $host for execution"
  scp $exec_mpi "$host:$exec_mpi" >> $LOG 2>&1
  ssh $host "sudo mv $exec_mpi /usr/bin" >> $LOG 2>&1
  echo "Node $host ready"
done
rm $exec_mpi

# Define first node
root_node=$(cat "$1" | head -n 1)
echo "Root node is $root_node"
scp "$2" "$root_node:$2" >> $LOG 2>&1
scp "$3" "$root_node:$3" >> $LOG 2>&1

echo "Execute the multiplication"
mpirun -machinefile "$1" "$exec_mpi" "$2" "$3" "$5"

echo "Get results from $root_node"
scp "$root_node:$5" "$5" >> $LOG 2>&1

cat "$5" | head -n1
