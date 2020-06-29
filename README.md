
# Openshift on Vsphere UPI, ACI-CNI plugin

Ansible playbooks for installing Openshift on Vmware with user provisioned infrastructure with ACI-CNU plugin.

## Requirements
* ACI fabric is provisioned using acc-provision utility. The archive file generated would be required later in the proces
* A RHEL system, which will be used to run the playbooks in this repository
* A RHEL system, which will be configured as a load balancer for the openshift cluster
* Download and import OCP4 OVA template to vSphere.

## Steps
* Enable orchestrator system subscription to enable rhel-7-server-ansible-2.9-rpms repository
* Update ansible package to latest version
* generate ssh keys, and copy the ssh keys to loadbalancer.
* clone this repository on the orchestrator system.
* Install ansible module requirements`cd openshift_vsphere_upi; ansible-galaxy install -r requirements.yaml
* edit the variable values in group_vars/all.yaml and hosts.ini
* copy the archive file created by acc-provision to files directory with name as  **aci_manifests.tar.gz**. Alternatively the file can be specified on command line using variable name *default_aci_manifests_archive*
* setup orchestrator and load balancer `ansible-playbook setup.yml`
* setup openshift install configurate `ansible-playbook oshift_prep.yml`
* Bring up bootstrap, master and worker nodes `ansible-playbook create_nodes.yml

## Deleting the cluster
The cluster can be removed using the delete_nodes.yaml playbook `ansible-playbook delete_nodes.yml`
