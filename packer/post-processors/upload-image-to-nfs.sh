#!/bin/bash
set -eu

# Post-processor : doing something with the build image.

NAME="${IMAGE_NAME}"
VERSION="${IMAGE_VERSION}"
IMAGE="${NAME}${VERSION}"
IMAGE_QCOW2="${IMAGE}.qcow2"
ARTIFACT_DIR="artifacts/qemu/${IMAGE}"
NFS_SERVER="${DESTINATION_SERVER}"
LOCAL_NFS_MOUNT="/mnt/nfs_packer"

# Install nfs client package
if [ -f "/etc/debian_version" ]; then
  if ! dpkg -s nfs-common >/dev/null 2>&1; then
    printf "%s\\n" "INFO: Debian-based OS detected, installing nfs-common package"
    sudo apt update -qq && sudo apt -y -q install nfs-common
  else
    printf "%s\\n" "INFO: Debian-based OS detected, nfs-common package found"
  fi
fi
if [ -f "/etc/redhat-release" ]; then
  if ! rpm -q nfs-utils >/dev/null 2>&1; then
    printf "%s\\n" "INFO: RHEL-based OS detected, installing nfs-utils package"
    sudo yum -y -q install nfs-utils
  else
    printf "%s\\n" "INFO: RHEL-based OS detected, nfs-utils package found"
  fi
fi

# Change to the artifact folder
cd "${ARTIFACT_DIR}"

# Rename the image and compute sha256 checksum
printf "%s\\n" "INFO: renaming packer-${IMAGE} file to ${IMAGE_QCOW2}"
mv -v "packer-${IMAGE}" "${IMAGE_QCOW2}"
printf "%s\\n" "INFO: calculating SHA256 checksum for ${IMAGE_QCOW2}"
sha256sum "${IMAGE_QCOW2}" | tee "${IMAGE_QCOW2}.sha256sum"

printf "%s\\n" "INFO: creating local NFS mountpoint ${LOCAL_NFS_MOUNT}"
sudo mkdir -p "${LOCAL_NFS_MOUNT}"
printf "%s\\n" "INFO: mounting NFS ${NFS_SERVER} on to ${LOCAL_NFS_MOUNT}"
sudo mount -t nfs4 "${NFS_SERVER}" "${LOCAL_NFS_MOUNT}"
printf "%s\\n" "INFO: copying files to ${LOCAL_NFS_MOUNT}"
cp -v --sparse=always "${IMAGE_QCOW2}.sha256sum" "${LOCAL_NFS_MOUNT}/"
cp -v --sparse=always "${IMAGE_QCOW2}" "${LOCAL_NFS_MOUNT}/"
printf "%s\\n" "INFO: unmounting ${LOCAL_NFS_MOUNT}"
sudo umount "${LOCAL_NFS_MOUNT}/"
printf "%s\\n" "INFO: deleting local NFS mountpoint ${LOCAL_NFS_MOUNT}"
sudo rm -rf "${LOCAL_NFS_MOUNT:-fallback}"

exit 0
