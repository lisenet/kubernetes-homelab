ansible-role-k8s-cluster
====================

Ansible Role - Kubernetes cluster with control planes and worker nodes on RHEL.

## Requirements

Docker. 

Remote user must be {{ k8s_user }}.

## Example Playbook

Specify the remote user as {{ k8s_user }}.

    - hosts: k8s
      remote_user: "{{ k8s_user }}"
      roles:
        - hl.k8s-cluster
