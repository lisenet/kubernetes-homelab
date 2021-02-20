ansible-role-hostsfile
====================

Ansible Role - manage hosts file on RHEL.

## Requirements

None.

## Example Playbook

    - hosts: k8s_master,k8s_node
      roles:
        - hl.hostsfile
