Cloud Computing Assignment
==========================

Assignment due for the Cloud Computing module of the Msc in Computer and
Softwares Techniques in Engineering, Option Distributed Computing and
e-science.

Usage
-----

### Deployment scripts

```
# Create the cloud
./create_cluster.rb <n>

# Destroy it and its network
./create_cluster.rb --purge

--- Following options have been used for debugging

# Rewrite ansible hosts file according to existing cloud
./create_cluster.rb --ansible

# Rewrite mpi machine file according to existing cloud
./create_cluster.rb --mpi
```

### MPI scripts

```
# Run all the experiments (/!\ LONG) with all kind of cluster/matrices
./run_experiment.sh

# In the 'mpi' directory

# Run a benchmark for every kind of matrix 128/256/512/1024/1360 (they are generated if necessary)
# for the current cluster at a given flavor. <flavor> must be an integer.
./benchmark.sh <flavor>

# Run a specific experiment, upload the result on swift
./run_matrix_multiply.sh <hosts file> <m1> <m2> <swift_container> <mout> [nb processes per node]
# Example
./run_matrix_multiply.sh hosts matrices/matrix_1024 matrices/matrix_1024 experiment_1024_results results 2
```

### Tool script

```
# Generate a random matrix, print on the standard output
./matrix_gen.rb <width> <height>
```


Configuration from environment
------------------------------

These are the default values, any of them is overridable through the environment

```
NETWORK_NAME = "s202926-net"
SUBNET_NAME  = "s202926-subnet"
SUBNET_RANGE = "192.168.111.0/24"
DNS_NAMESERVER = "10.7.0.3"
ROUTER_NAME = "s202926-router"
PUB_KEY_FILE= "#{ENV["HOME"]}/.ssh/id_rsa.pub"
KEYPAIR_NAME = "s202926-key"
INSTANCE_PREFIX = "s202926vm-"
INSTANCE_FLAVOR = 2
VM_IMAGE = "ubuntu-precise"
MAX_WAIT_TIME = 180
```

