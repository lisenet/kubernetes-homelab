# Packer

See https://www.packer.io/docs

Packer is a tool that enables us to create identical machine images for multiple platforms from a single source template.

## Why Packer?

Speed. Deploying KVM guests with Packer-built images takes less time than provisioning servers using PXE boot.

Are you getting rid of PXE? Not anytime soon. PXE is still used to provision physical hosts (KVM hypervisors).

## Install Packer

For RHEL-based systems:

```
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install packer
```

For Debian-based systems:

```
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install --no-install-recommends packer
```

## Build Images with Qemu Packer Builder

The [Qemu Packer builder](https://www.packer.io/plugins/builders/qemu) is able to create KVM virtual machine images.

See JSON files for each distribution:

* [rocky8.json](./rocky8.json)
* [centos7.json](./centos7.json)

Build Rocky 8 image:

```
PACKER_LOG=1 packer build ./rocky8.json
```

## Monitoring Build Process

Packer uses VNC, therefore we can check its window with a VNC client, e.g.:

```
vncviewer -shared 127.0.0.1:5934
```

Note that your VNC port will be different.

## Install KVM Guests from Packer Images

On a KVM hypervisor that was used to "package" the image, run the following commands to deploy a `rocky8` guest:

```
sudo cp --sparse=always ./artifacts/qemu/rocky8/rocky8.qcow2 /mnt/storage-luks/libvirt/

sudo virt-install \
  --name rocky8 \
  --network bridge=br0,model=virtio,mac=C0:FF:EE:D0:5E:37 \
  --disk path=/mnt/storage-luks/libvirt/rocky8.qcow2,size=32 \
  --ram 2048 \
  --vcpus 2 \
  --os-type linux \
  --os-variant centos7.0 \
  --sound none \
  --rng /dev/urandom \
  --virt-type kvm \
  --import \
  --wait 0
```

## Provision Homelab KVM Guests

```
for i in 1 2 3; do \
  scp ./artifacts/qemu/rocky8/rocky8.qcow2 root@kvm${i}.hl.test:/var/lib/libvirt/images/srv3${i}.qcow2 && \
  virt-install \
  --connect qemu+ssh://root@kvm${i}.hl.test/system \
  --name srv3${i}-master \
  --network bridge=br0,model=virtio,mac=C0:FF:EE:D0:5E:3${i} \
  --disk path=/var/lib/libvirt/images/srv3${i}.qcow2,size=32 \
  --import \
  --ram 4096 \
  --vcpus 2 \
  --os-type linux \
  --os-variant centos7.0 \
  --sound none \
  --rng /dev/urandom \
  --virt-type kvm \
  --wait 0; \
done

for i in 1 2 3; do \
  scp ./artifacts/qemu/rocky8/rocky8.qcow2 root@kvm${i}.hl.test:/var/lib/libvirt/images/srv3${i}.qcow2 && \
  virt-install \
  --connect qemu+ssh://root@kvm${i}.hl.test/system \
  --name srv3$(($i + 3))-node \
  --network bridge=br0,model=virtio,mac=C0:FF:EE:D0:5E:3$(($i + 3)) \
  --disk path=/var/lib/libvirt/images/srv3$(($i + 3)).qcow2,size=32 \
  --import \
  --ram 8192 \
  --vcpus 2 \
  --os-type linux \
  --os-variant centos7.0 \
  --sound none \
  --rng /dev/urandom \
  --virt-type kvm \
  --wait 0; \
done
```
