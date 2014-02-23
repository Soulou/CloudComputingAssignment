#!/usr/bin/env bash

LOG=execution.log

function usage() {
  echo 'run_matrix_multiply.sh <hosts file> <matrix 1> <matrix 2> <swift container> <output matrix> [mpi process per node]'
  exit 1
}

# Check number of argument
[[ $# -ne 5 && $# -ne 6 ]] && usage
# hosts file and input matrices should be present
for file in "$1" "$2" "$3" ; do
  if [ ! -e "$file" ] ; then
    echo "File \"$file\" does not exist"
    usage
  fi
done

hosts_file=$1
path_m1=$2
path_m2=$3
m1=$(basename $2)
m2=$(basename $3)
container=$4
result_file=$5
npernode=${6-1}

# Deploy MPI Apps on nodes
exec_mpi=matrix_multiply
mpicc $exec_mpi.c -o $exec_mpi
hosts=$(cat "$hosts_file")
for host in $hosts ; do
  echo "Prepare $host for execution"
  scp $exec_mpi "$host:$exec_mpi" >> $LOG 2>&1
  ssh $host "sudo mv $exec_mpi /usr/bin" >> $LOG 2>&1
  echo "Node $host ready"
done
rm $exec_mpi

# Define first node
root_node=$(cat "$hosts_file" | head -n 1)
echo "Root node is $root_node"
scp "$path_m1" "$root_node:$m1" >> $LOG 2>&1
scp "$path_m2" "$root_node:$m2" >> $LOG 2>&1

echo "Execute the multiplication"

mpirun -npernode $npernode -machinefile "$hosts_file" "$exec_mpi" "$m1" "$m2" "$result_file"

echo "Get results from $root_node"
scp "$root_node:$result_file" "$result_file" >> $LOG 2>&1
cat "$result_file" | head -n1

echo "Upload to swift: container $container"
swift upload $container $result_file
mkdir -p $container
cp $result_file $container/$result_file

echo "Upload has been done, clean local directory"
rm $result_file

