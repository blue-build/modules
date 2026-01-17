#!/usr/bin/env nu

# Remove packages.
def remove_pkgs [remove: record]: nothing -> nothing {
  let remove = $remove
    | default [] packages

  let remove_list = $remove.packages
    | str trim

  if ($remove.packages | is-not-empty) {
    print $'(ansi green)Removing packages:(ansi reset)'
    $remove_list
      | each {
        print $'- (ansi cyan)($in)(ansi reset)'
      }

    try {
      ^zypper --non-interactive remove ...($remove_list)
    } catch {|err|
      return (error make {
        msg: $"Failed to remove packages\n($err.msg)"
      })
    }
  }
}

# Install packages.
#
# You can specify a list of packages to install, and you can
# specify a list of packages for a specific repo to install.
def install_pkgs [install: record]: nothing -> nothing {
  let install = $install
    | default [] packages

  # Gather lists of the various ways a package is installed
  # to report back to the user.
  let install_list = $install.packages
    | str trim

  if ($install_list | is-not-empty) {
    print $'(ansi green)Installing packages:(ansi reset)'
    $install_list
      | each {
        print $'- (ansi cyan)($in)(ansi reset)'
      }
    try {
      ^zypper --non-interactive install --auto-agree-with-licenses ...($install_list)
    } catch {|err|
      return (error make {
        msg: $"Failed to install packages\n($err.msg)"
      })
    }
  }
}

def main [config: string]: nothing -> nothing {
  let config = $config
    | from json
    | default {} remove
    | default {} install

  remove_pkgs $config.remove
  install_pkgs $config.install
}
