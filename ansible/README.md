# DEPRECATION NOTICE

Originally Ansible playbooks (used to deploy Kubernetes cluster) were part of this repository. It has, however, proved challenging to maintain them here because of other roles/playbooks that weren't in the repository (e.g. PXE server deployment, KVM server deployment etc).

A decision has therefore been made to move Ansible playbooks from this repository to their own dedicated GitHub repository called [homelab-ansible](https://github.com/lisenet/homelab-ansible).

Files in this folder are left for references only, and are no longer maintained. Ansible playbooks to configure Kubernetes homelab can be found in [homelab-ansible](https://github.com/lisenet/homelab-ansible) repository.

# Ansible-defined Kubernetes Homelab

Ansible playbooks to configure Kubernetes homelab.

## Passwordless SSH Authentication

Configure passwordless root SSH authentication from some device where Ansible is installed (e.g. your laptop) to all nodes:
```
$ for i in $(seq 1 6);do ssh-copy-id -f -i ./roles/hl.users/files/id_rsa_root.pub root@10.11.1.3${i};done
```

## Set Ansible User Password

Create a file `vault.key` to store your Ansible Vault secret (see `ansible.cfg` for vault_password_file). Use Ansible Vault to create an encrypted file `./roles/hl.users/defaults/secure.yml` to store your user password:
```
$ ansible-vault create ./roles/hl.users/defaults/secure.yml
```

The variable for user password is `user_password`.

## Deploy Kubernetes Cluster

Kubernetes cluster defaults are defined in [`roles/hl.k8s-cluster/defaults/main.yml`](./roles/hl.k8s-cluster/defaults/main.yml).

Run the main playbook:
```
$ ansible-playbook ./playbooks/main-k8s-hosts.yml
```

## How to Get Kubernetes Dashboard Token

```
$ kubectl get secret $(kubectl get serviceaccount dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}"|base64 -d;echo
```
