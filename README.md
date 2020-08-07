# Openshift on Vsphere UPI, ACI-CNI plugin

Ansible playbooks for installing Openshift on Vmware user provisioned infrastructure with ACI-CNI plugin.

## Steps
* Provision ACI fabric using acc-provision utility. 

  Specify the flavor parameter value as 'openshift-4.4-esx'. 
  
  Specify an archive tar file for '-z' option, the archive file created will be required in the next steps
  
  Example 
  `acc-provision -a -c acc_provision_input.yaml -u admin -p ### -f openshift-4.4-esx  -z manifests.tar.gz`
  
  On successful execution, a portgroup with name **<system_id>_vlan_<kubeapi_vlan>** will be created under the distributed switch. This document will refer to this portgroup as **api-vlan-portgroup**.
  
* Download OCP4 OVA from Redhat site and import it. Specify **api-vlan-portgroup** as the port group for network interface.
  
* Provision a RHEL 7 VM with network interface connected to **api-vlan-portgroup**.

  This VM will be configured as loadbalancer for the openshift cluster. This document will refer to this VM as **loadbalancer**
  
* Provision a RHEL 7 VM with network interface connected to **api-vlan-portgroup**. 

  Enable rhel-7-server-ansible-2.9-rpms repository. Update ansible package to latest version.
  
  Generate ssh keys and copy the ssh keys to **loadbalancer**
  
  Clone this repository.
  
  change directory to the git cloned directory.
  
  Install ansible module requirements. `ansible-galaxy install -r requirements.yaml`
  
  Edit *group_vars/all.yml* and *hosts.ini* file as per site requirements.
  
  perform basic validation of variable values using asserts.yml playbook `ansible-playbook asserts.yml`
  
  copy the archive file created by acc-provision to files directory with name as  **aci_manifests.tar.gz**. Alternatively the file can be specified on command line using variable name *aci_manifests_archive*
  
  Run setup playbook to configure this VM and the loadbalancer. `ansible-playbook setup.yml`
  
  Run oshift_prep playbook to generate openshift manifests and ignition files. `ansible-playbook oshift_prep.yml`
  
  Run create_nodes playbook to bring up the cluster. This playbook creates the bootstrap node, master and worker nodes.
  
  At this point, cluster creation has started, if auto_approve_csr option was not enabled, monitor the csr's pending and approve them for cluster creation to progress.
  
  To delete the cluser, use delete_nodes playbook.

