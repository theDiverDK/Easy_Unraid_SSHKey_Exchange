#!/bin/bash
#The original script was forked from here:
#https://github.com/SpaceinvaderOne/Easy_Unraid_SSHKey_Exchange

#SpaceinvaderOne makes some amazing videos about Unraid and more :)

# Check if ed25519 key exists, if not generate one
if [[ ! -f /root/.ssh/id_ed25519 ]]; then
    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
fi

# ask user for ip or name of remote server
while [[ -z $remote_server_address ]]; do
    read -p "Please enter the remote server name or IP: " remote_server_address
done

# ask for username (root if another Unraid box)
while [[ -z $remote_server_username ]]; do
    read -p "Please enter the remote server username: " remote_server_username
done

# see if the keys have previously been exchanged
if ssh -o BatchMode=yes -o ConnectTimeout=5 $remote_server_username@$remote_server_address true 2>/dev/null; then
    echo "Keys have already been exchanged. Exiting."
    exit 1
fi

# exchange keys
ssh-copy-id -f -o StrictHostKeyChecking=no -i ~/.ssh/id_ed25519.pub $remote_server_username@$remote_server_address

# fix for the Unraid problem after swapping keys about '"hostfile_replace_entries" failed for /root/.ssh/known_hosts'
ssh-keyscan -H $remote_server_address >> ~/.ssh/known_hosts

echo "Keys successfully exchanged and known_hosts file updated."
