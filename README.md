# Openshift on Vsphere UPI, ACI-CNI plugin

Ansible playbooks for installing Openshift on Vmware user provisioned infrastructure with ACI-CNI plugin.

## Step 1 - acc-provision
* Provision ACI fabric using acc-provision utility. 

  * Specify the flavor parameter value as 'openshift-4.4-esx'. 
  * Specify an archive tar file for '-z' option, the archive file created will be required in the next steps
  
  Example 
  `acc-provision -a -c acc_provision_input.yaml -u admin -p ### -f openshift-4.4-esx  -z manifests.tar.gz`
  
  On successful execution, a portgroup with name **<system_id>_vlan_<kubeapi_vlan>** will be created under the distributed switch. This document will refer to this portgroup as **api-vlan-portgroup**.

## Step 2 - VM Provisioning
* Download OCP4 OVA from Redhat site and import it. Specify **api-vlan-portgroup** as the port group for network interface.
* **LoadBalancer**: Provision a RHEL 7 VM with network interface connected to **api-vlan-portgroup**.
This VM will be configured as loadbalancer for the openshift cluster. 
* **Orchestrator**: Provision a RHEL 7 VM with network interface connected to **api-vlan-portgroup**. 

## Setp 3 - Configure the LoadBalancer
* Connect to the VM via console and configure basic network connectivity. Remember that the interface is a VLAN Interface for the <kubeapi_vlan>. Assign to the VM an IP in your Node Subnet
* Give the VM an hostname

## Setp 4 - Configure the Orchestrator
	
* Register and subscribe: https://access.redhat.com/solutions/253273
* Enable rhel-7-server-ansible-2.9-rpms repository: https://access.redhat.com/solutions/265523
* Update and install the required packages:
* 
	```
	subscription-manager repos --enable rhel-server-rhscl-7-rpms
	yum update -y ; yum install git ansible python-netaddr unzip -y
	```

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
  
* Run create_nodes playbook to bring up the cluster. This playbook creates the bootstrap node, master and worker nodes. `ansible-playbook create_nodes.yml`
  
At this point, cluster creation has started, if auto_approve_csr option was not enabled, monitor the csr's pending and approve them for cluster creation to progress.

## Delete  
To delete the cluser, use delete_nodes playbook.


