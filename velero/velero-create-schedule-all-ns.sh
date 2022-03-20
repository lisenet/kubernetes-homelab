#!/bin/bash
set -e

velero schedule get

for i in $(kubectl get ns -o name|cut -d"/" -f2|grep -ve velero);do
  velero create schedule "${i}" --schedule="0 2 * * *" --include-namespaces "${i}"
done
