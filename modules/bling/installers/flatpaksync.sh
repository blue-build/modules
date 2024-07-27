#!/usr/bin/env bash
set -euo pipefail

echo "Attention: flatpaksync has been removed from the bling module due to it being unmaintained and unused."
echo "If you need this module and want to resurrect it, you can find the source code and documentation in the URLs below:"
echo "https://github.com/blue-build/modules/tree/af2db664acdcf05eedd4780736d420b87691d60f/modules/bling/flatpaksync"
echo "https://github.com/blue-build/modules/blob/af2db664acdcf05eedd4780736d420b87691d60f/modules/bling/installers/flatpaksync.sh"
echo "https://github.com/blue-build/modules/blob/af2db664acdcf05eedd4780736d420b87691d60f/modules/bling/README.md#flatpaksync-unmaintained"
echo "To fix your build: remove the flatpaksync entry from your bling module configuration"

exit 1