# Openshift on Vsphere UPI, ACI-CNI plugin

Ansible playbooks for installing Openshift on Vmware user provisioned infrastructure with ACI-CNI plugin.
This document is for Openshift version 4.6 and CoreOS 4.6. If you are installing Openshift version 4.5 please refer to ocp45 branch

If you have restrictions on the use of DHCP in your environment, access this directory (Docs -> openshift_vsphere_upi_without_DHCP) to provide this integration without DHCP, using VMware's guestinfo.afterburn.initrd.network-kargs.

## Step 1 - acc-provision
* Provision ACI fabric using acc-provision utility. 

  * Specify the flavor parameter value as 'openshift-4.4-esx'. 
  * Specify an archive tar file for '-z' option, the archive file created will be required in the next steps
  
  Example 
  `acc-provision -a -c acc_provision_input.yaml -u admin -p ### -f openshift-4.4-esx  -z manifests.tar.gz`
  
  On successful execution, a portgroup with name **<system_id>_vlan_<kubeapi_vlan>** will be created under the distributed switch. This document will refer to this portgroup as **api-vlan-portgroup**.

## Step 2 - VM Provisioning
* Download OCP46 OVA from Redhat site and import it. Specify **api-vlan-portgroup** as the port group for network interface.
* **LoadBalancer**: Provision a RHEL 8 VM with network interface connected to **api-vlan-portgroup**.
This VM will be configured as loadbalancer for the openshift cluster. 
* **Orchestrator**: Provision a RHEL 8 VM with network interface connected to **api-vlan-portgroup**. 

## Setp 3 - Configure the LoadBalancer
* Connect to the VM via console and configure basic network connectivity. Remember that the interface is a VLAN Interface for the <kubeapi_vlan>. Assign to the VM an IP in your Node Subnet
* Give the VM an hostname

## Setp 4 - Configure the Orchestrator
	
* Register and subscribe: https://access.redhat.com/solutions/253273
* Enable ansible-2.9-for-rhel-8-x86_64-rpms repository: https://access.redhat.com/solutions/265523
* Update and install the required packages:

* Generate ssh keys and copy the ssh keys to **loadbalancer**

	```
	ssh-keygen
	ssh-copy-id root@<LB_IP> 
	ssh-copy-id root@<Orchestrator_IP> YES to yourself :)
	```
  
* Clone this repository and change directory to the git cloned directory.
  
* Install ansible module requirements. `ansible-galaxy install -r requirements.yaml`
  
* Edit *group_vars/all.yml* and *hosts.ini* file as per site requirements.
  
* perform basic validation of variable values using asserts.yml playbook `ansible-playbook asserts.yml`
  
* copy the archive file created by acc-provision to files directory with name as  **aci_manifests.tar.gz**. Alternatively the file can be specified on in the *default_aci_manifests_archive* variable in the *group_vars/all.yml* file.
  
* Run setup playbook to configure this VM and the loadbalancer. `ansible-playbook setup.yml`
  
* Run oshift_prep playbook to generate openshift manifests and ignition files. `ansible-playbook oshift_prep.yml`

* Create folder in Vmware with the name of the infraID, obtained with the command below:

  `jq -r .infraID <installation_directory>/metadata.json `
  
* Run create_nodes playbook to bring up the cluster. This playbook creates the bootstrap node, master and worker nodes. `ansible-playbook create_nodes.yml`
  
At this point, cluster creation has started, if auto_approve_csr option was not enabled, monitor the csr's pending and approve them for cluster creation to progress.

IMPORTANT:

Before adding workloads to the cluster, perform the procedures below on the worker VM's so that we don't have problems with volume provisioning in the pods.

Edit settings → VM Options → Advanced.

Optional: In the event of cluster performance issues, from the Latency Sensitivity list, select High.

Click Edit Configuration, and on the Configuration Parameters window, click Add Configuration Params. Define the following parameter names and values:

`disk.EnableUUID: Specify TRUE.`

## Delete  
To delete the cluser, use delete_nodes playbook.