#!/bin/bash
# push-alle.sh – Stand Ende Tag 12 (absichtlich fehlerhaft, zum Üben mit ShellCheck)
source ~/ct-lab/setup/env.sh
ziel=$1
cd $LAB/tag12
for img in $(podman images --format '{{.Repository}}:{{.Tag}}' | grep notes); do
  podman push $img $REG/$ziel/${img##*/}
done
echo "fertig: $(ls $LAB/tag12 | wc -l) Dateien im Ordner"
