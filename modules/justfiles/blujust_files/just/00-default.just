# Copyright 2025 Universal Blue
# Copyright 2025 The BlueBuild Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

uid := `id -u`
shell := `grep :$(id -u): /etc/passwd | cut -d: -f7`

# Boot into this device's BIOS/UEFI screen
bios:
    #!/usr/bin/bash
    if [ -d /sys/firmware/efi ]; then
      systemctl reboot --firmware-setup
    else
      echo "Rebooting to legacy BIOS from OS is not supported."
    fi

# Show BIOS info
bios-info:
    #!/usr/bin/bash
    echo "Manufacturer: $(sudo dmidecode -s baseboard-manufacturer)"
    echo "Product Name: $(sudo dmidecode -s baseboard-product-name)"
    echo "Version: $(sudo dmidecode -s bios-version)"
    echo "Release Date: $(sudo dmidecode -s bios-release-date)"

# Show all messages from this boot
logs-this-boot:
    sudo journalctl --no-hostname -b 0

# Show all messages from last boot
logs-last-boot:
    sudo journalctl --no-hostname -b -1

# Check for local overrides
check-local-overrides:
    #!/usr/bin/bash
    diff -r \
      --suppress-common-lines \
      --color="always" \
      --exclude "passwd*" \
      --exclude "group*" \
      --exclude="subgid*" \
      --exclude="subuid*" \
      --exclude="machine-id" \
      --exclude="adjtime" \
      --exclude="fstab" \
      --exclude="system-connections" \
      --exclude="shadow*" \
      --exclude="gshadow*" \
      --exclude="ssh_host*" \
      --exclude="cmdline" \
      --exclude="crypttab" \
      --exclude="hostname" \
      --exclude="localtime" \
      --exclude="locale*" \
      --exclude="*lock" \
      --exclude=".updated" \
      --exclude="*LOCK" \
      --exclude="vconsole*" \
      --exclude="00-keyboard.conf" \
      --exclude="grub" \
      --exclude="system.control*" \
      --exclude="cdi" \
      --exclude="default.target" \
      /usr/etc /etc 2>/dev/null | sed '/Binary\ files\ /d'

# Gather device info to a pastebin
device-info:
    #!/usr/bin/bash
    fpaste <(rpm-ostree status) <(fpaste --sysinfo --printonly) <(flatpak list --columns=application,version,options)

# Measure Idle Power Draw
check-idle-power-draw:
    #!/usr/bin/bash
    sudo powerstat -a -r

alias upgrade := update

# Update system, flatpaks, and containers all at once
update VERB_LEVEL="full":
    #!/usr/bin/bash
    if [ {{ VERB_LEVEL }} = "help" ]; then
        echo "Usage: just update <level>"
        echo "  <level>: Specify the verbosity level - 'full', 'minimal', or 'prompt'"
        echo "  Use 'full' to show full output of each command."
        echo "  Use 'minimal' to show minimal output and indicate success or failure."
        echo "  Use 'prompt' to prompt the user before running each command."
        exit 0
    fi

    # Function to run commands with appropriate verbosity and approval check
    update_command() {
        command=$1
        case "{{ VERB_LEVEL }}" in
            full)
                echo "Running $command..."
                $command
                echo "Completed $command"
                ;;
            minimal)
                echo "Running $command..."
                $command > /dev/null 2>&1
                if [ $? -eq 0 ]; then
                    echo "Completed $command"
                else
                    echo "Failed to complete $command"
                    exit 1
                fi
                ;;
            prompt)
                printf "Do you want to run %s? [Y/n]: " "$command"
                read user_input
                user_input=${user_input:-Y}  # Default to Y if Enter is pressed
                if [ "$user_input" = "Y" ] || [ "$user_input" = "y" ]; then
                    echo "Running $command..."
                    $command
                    echo "Completed $command"
                else
                    echo "Skipped $command"
                fi
                ;;
            *)
                echo "Invalid level: {{ VERB_LEVEL }}. Please use 'full', 'minimal', 'prompt' or 'help' for usage."
                exit 1
                ;;
        esac
    }

    # Run rpm-ostree update
    update_command "sudo bootc upgrade"

    # Run flatpak update
    update_command "flatpak update -y"

alias changelog := changelogs

# Show the changelog
changelogs:
    rpm-ostree db diff --changelogs

# Update device firmware
[no-exit-message]
update-firmware:
    fwupdmgr refresh --force
    fwupdmgr get-updates
    fwupdmgr update

# Clean up old up unused podman images, volumes, flatpak packages and rpm-ostree content
clean-system:
    #!/usr/bin/bash
    podman image prune -af
    podman volume prune -f
    flatpak uninstall --unused
    rpm-ostree cleanup -bm
    if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
        brew autoremove
        brew cleanup
    fi
