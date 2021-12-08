ansible-role-pihole-exporter
====================

Ansible Role - configure pihole exporter for Prometheus.

## Requirements

None.

## Role Variables

	pihole_exporter_url: "https://github.com/eko/pihole-exporter/releases/download/v0.0.11/pihole_exporter-linux-arm"

## Example Playbook

    - hosts: raspberrypi
      roles:
        - hl.pihole-exporter
