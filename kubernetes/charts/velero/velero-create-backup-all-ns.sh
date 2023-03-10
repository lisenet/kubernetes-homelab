#!/bin/bash
set -e

for i in $(kubectl get ns -o name|cut -d"/" -f2|grep -ve velero);do
  velero backup create "${i}" --include-namespaces "${i}"
done
