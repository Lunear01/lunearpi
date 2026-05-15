#!/bin/bash
docker system prune -f
sudo sh -c 'truncate -s 0 /var/lib/docker/containers/*/*-json.log'
sudo journalctl --vacuum-time=2d
sudo apt-get autoremove -y
sudo apt-get clean

echo "Cleanup Complete: $(date)"
