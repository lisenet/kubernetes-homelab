ansible-role-node-exporter
====================

Ansible Role - configure node exporter for Prometheus on RHEL.

## Requirements

None.

## Role Variables

	node_exporter_url: "https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz"

## Example Playbook

    - hosts: k8s
      roles:
        - hl.node-exporter
