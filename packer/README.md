[[Back to Index Page](../README.md)]

# Packer

See https://www.packer.io/docs

Packer is a tool that enables us to create identical machine images for multiple platforms from a single source template.

## Why Packer?

Speed. Deploying KVM guests with Packer-built images takes less time than provisioning servers using PXE boot.

Are you getting rid of PXE? Not anytime soon. PXE is still used to provision physical hosts (KVM hypervisors).

## Install Packer

For RHEL-based systems:

```bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install packer
```

For Debian-based systems:

```bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install --no-install-recommends packer
```

## Build Images with Qemu Packer Builder

The [Qemu Packer builder](https://www.packer.io/plugins/builders/qemu) is able to create KVM virtual machine images.

See JSON files for each distribution:

* [rocky9.json](./rocky9.json)
* [rocky8.json](./rocky8.json)
* [centos7.json](./centos7.json)

Build Rocky 9 image:

```bash
PACKER_LOG=1 packer build ./rocky9.json
```

Build Rocky 8 image:

```bash
PACKER_LOG=1 packer build ./rocky8.json
```

## Monitoring Build Process

Packer uses VNC, therefore we can check its window with a VNC client, e.g.:

```bash
vncviewer -shared 127.0.0.1:5934
```

Note that your VNC port will be different.

If you are using Packer on a remote server (e.g. 10.11.1.100) where you can't access VNC directly, then you can use SSH port forwarding. See example below.

```bash
ssh -L 5934:127.0.0.1:5934 user@10.11.1.100
```

## Install KVM Guests from Packer Images

On a KVM hypervisor that was used to "package" the image, run the following commands to deploy a `rocky9` guest:

```bash
sudo cp --sparse=always ./artifacts/qemu/rocky9/rocky9.qcow2 /var/lib/libvirt/images/

sudo virt-install \
  --name rocky9 \
  --network bridge=br0,model=virtio,mac=C0:FF:EE:D0:5E:37 \
  --disk path=/var/lib/libvirt/images/rocky9.qcow2,size=32 \
  --ram 2048 \
  --vcpus 2 \
  --os-type linux \
  --os-variant centos8 \
  --sound none \
  --rng /dev/urandom \
  --virt-type kvm \
  --import \
  --wait 0
```

## Provision Homelab KVM Guests

```bash
for i in 1 2 3; do \
  scp ./artifacts/qemu/rocky9/rocky9.qcow2 root@kvm${i}.hl.test:/var/lib/libvirt/images/srv3${i}.qcow2 && \
  virt-install \
  --connect qemu+ssh://root@kvm${i}.hl.test/system \
  --name srv3${i}-master \
  --network bridge=br0,model=virtio,mac=C0:FF:EE:D0:5E:3${i} \
  --disk path=/var/lib/libvirt/images/srv3${i}.qcow2,size=32 \
  --import \
  --ram 4096 \
  --vcpus 2 \
  --os-type linux \
  --os-variant centos8 \
  --sound none \
  --rng /dev/urandom \
  --virt-type kvm \
  --wait 0; \
done

for i in 1 2 3; do \
  scp ./artifacts/qemu/rocky9/rocky9.qcow2 root@kvm${i}.hl.test:/var/lib/libvirt/images/srv3${i}.qcow2 && \
  virt-install \
  --connect qemu+ssh://root@kvm${i}.hl.test/system \
  --name srv3$(($i + 3))-node \
  --network bridge=br0,model=virtio,mac=C0:FF:EE:D0:5E:3$(($i + 3)) \
  --disk path=/var/lib/libvirt/images/srv3$(($i + 3)).qcow2,size=32 \
  --import \
  --ram 8192 \
  --vcpus 2 \
  --os-type linux \
  --os-variant centos8 \
  --sound none \
  --rng /dev/urandom \
  --virt-type kvm \
  --wait 0; \
done
```
