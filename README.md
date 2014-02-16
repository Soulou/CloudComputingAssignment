Cloud Computing Assignment
==========================

Assignment due for the Cloud Computing module of the Msc in Computer and
Softwares Techniques in Engineering, Option Distributed Computing and
e-science.

Usage
-----

```
# Create the cloud
./create_cluster.rb <n>

# Destroy it and its network
./create_cluster.rb --purge
```

Example
-------

```
$ ./create_cluster.rb 4
Validation of the Openstack environment variables
Create new network s202926-net
Create new sub-network s202926-subnet
Create new router s202926-router
Create router interface to public network
Use existing keypair s202926-key
Rule icmp -1 already exists
Rule tcp 22 already exists
Use available floating IP 10.7.2.130
Create VM s202926vm-1
Create VM s202926vm-2
Create VM s202926vm-3
Create VM s202926vm-4

Wait for [s202926vm-1, s202926vm-2, s202926vm-3, s202926vm-4] boot
................
Wait for [s202926vm-1, s202926vm-2, s202926vm-3] boot
......
Wait for [s202926vm-2, s202926vm-3] boot
.
Wait for [s202926vm-3] boot
......
All VMs have successfuly boot
Cluster is booting, public ip is 10.7.2.130
s202926@senbazuru-01:~/assignment$ ./create_cluster.rb --purge
Validation of the Openstack environment variables
Use existing network s202926-net
Use existing sub-network s202926-subnet
Use existing router s202926-router

Wait for [s202926vm-4, s202926vm-3, s202926vm-2, s202926vm-1] shutdown
....
Wait for [s202926vm-3, s202926vm-2, s202926vm-1] shutdown
......
Wait for [s202926vm-2] shutdown

All VMs have been deleted
Delete router s202926-router
Delete subnet s202926-subnet
Delete network s202926-net

```

### Note

https://www.youtube.com/v/3funbluzm2A
