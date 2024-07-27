#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

echo "Attention: laptop submodule has been removed from the bling module."
echo "It has been removed due to it being depreciated compared to the current power-saving solutions like Power Profiles Daemon (PPD) or Tuned."
echo "TLP v1.6+ also has issues with SeLinux & requires the insecure workaround of setting SeLinux to permissive mode."
echo "If you need this submodule and want to resurrect it, you can find the source code in the URLs below:"
echo "https://github.com/blue-build/modules/blob/af2db664acdcf05eedd4780736d420b87691d60f/modules/bling/installers/laptop.sh"
echo "https://github.com/blue-build/modules/tree/af2db664acdcf05eedd4780736d420b87691d60f/modules/bling/50-laptop.conf"
echo "To fix your build: remove the laptop entry from your bling module configuration"

exit 1
