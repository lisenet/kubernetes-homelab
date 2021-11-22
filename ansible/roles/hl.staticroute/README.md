ansible-role-staticroute
====================

Ansible Role - create a static route on RHEL.

This role is used to configure Kubernetes servers with a static route to access the VPN server.

## Requirements

None.

## Example Playbook

    - hosts: k8s_master,k8s_node
      roles:
        - hl.staticroute
