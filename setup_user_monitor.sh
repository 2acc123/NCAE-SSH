#!/bin/bash

# Set variables
PROJECT_DIR="ansible_user_monitor"
INVENTORY_FILE="inventory.ini"
KNOWN_USERS_FILE="known_users.yml"
PLAYBOOK_FILE="check_users.yml"
ANSIBLE_GROUP="linux_group"

# 1. Install Ansible (if not already installed)
if ! command -v ansible &> /dev/null; then
    echo "Installing Ansible..."
    pip install ansible || { echo "Ansible installation failed"; exit 1; }
fi

# 2. Create project directory
mkdir -p "$PROJECT_DIR" && cd "$PROJECT_DIR"

# 3. Create inventory file
cat > "$INVENTORY_FILE" <<EOF
[$ANSIBLE_GROUP]
192.0.2.50
192.0.2.51
192.0.2.52
EOF

# 4. Create known users file
cat > "$KNOWN_USERS_FILE" <<EOF
known_users:
  - root
  - camille_jenatzy
  - gaston_chasseloup
  - leon_serpollet
  - william_vanderbilt
  - henri_fournier
  - maurice_augieres
  - arthur_duray
  - henry_ford
  - louis_rigolly
  - pierre_caters
  - paul_baras
  - victor_hemery
  - fred_marriott
  - lydston_hornsted
  - kenelm_guinness
  - rene_thomas
  - ernest_eldridge
  - malcolm_campbell
  - ray_keech
  - john_cobb
  - dorothy_levitt
  - paula_murphy
  - betty_skelton
  - rachel_kushner
  - kitty_oneil
  - jessi_combs
  - andy_green
EOF

# 5. Create playbook
cat > "$PLAYBOOK_FILE" <<'EOF'
- name: Check for unknown users on remote Linux systems
  hosts: linux_group
  gather_facts: no
  vars_files:
    - known_users.yml

  tasks:
    - name: Get list of all users from /etc/passwd
      command: awk -F: '{ print $1 }' /etc/passwd
      register: all_users

    - name: Compare with known users
      set_fact:
        unknown_users: "{{ all_users.stdout_lines | difference(known_users) }}"

    - name: Display unknown users
      debug:
        msg: "Unknown users on {{ inventory_hostname }}: {{ unknown_users }}"
      when: unknown_users | length > 0
EOF

# 6. Instructions
echo
echo "Setup complete!"
echo "To check for unknown users, run:"
echo "  ansible-playbook -i $INVENTORY_FILE $PLAYBOOK_FILE -u your_ssh_user"
echo "Replace 'your_ssh_user' with the remote SSH username."
