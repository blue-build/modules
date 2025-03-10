#!/usr/bin/env nu

const NEGATIVO = 'negativo17'
const NEGATIVO_URL = 'https://negativo17.org/repos/fedora-negativo17.repo'
const RPMFUSION = 'rpmfusion'

# Handle adding/removing repo files and COPR repos.
# 
# This command returns an object containing the repos
# that were added to allow for cleaning up afterwards.
def repos [$repos: record]: nothing -> record {
  let repos = $repos
    | default [] keys

  let cleanup_repos = match $repos.files? {
    # Add repos if it's a list
    [..$files] => {
      add_repos ($files | default [])
    }
    # Add and remove repos
    {
      add: [..$add]
      remove: [..$remove]
    } => {
      let repos = add_repos ($add | default [])
      remove_repos ($remove | default [])
      $repos
    }
    # Add repos
    { add: [..$add] } => {
      add_repos ($add | default [])
    }
    # Remove repos
    { remove: [..$remove] } => {
      remove_repos ($remove | default [])
      []
    }
    _ => []
  }

  let cleanup_coprs = match $repos.copr? {
    # Enable repos if it's a list
    [..$coprs] => {
      add_coprs ($coprs | default [])
    }
    # Enable and disable repos
    {
      enable: [..$enable]
      disable: [..$disable]
    } => {
      let coprs = add_coprs ($enable | default [])
      disable_coprs ($disable | default [])
      $coprs
    }
    # Enable repos
    { enable: [..$enable] } => {
      add_coprs ($enable | default [])
    }
    # Disable repos
    { disable: [..$disable] } => {
      disable_coprs ($disable | default [])
      []
    }
    _ => []
  }

  nonfree_repos $repos.nonfree?
  add_keys $repos.keys

  {
    copr: $cleanup_coprs
    files: $cleanup_repos
  }
}

# Setup nonfree repos for rpmfusion or negativo17-multimedia.
def nonfree_repos [repo_type?: string]: nothing -> list<string> {
  match $repo_type {
    $repo if $repo == $RPMFUSION => {
      disable_negativo
      enable_rpmfusion
    }
    $repo if $repo == $NEGATIVO => {
      disable_rpmfusion
      enable_negativo
    }
    null => [],
    _ => {
      error make {
        msg: $"The only valid values are '($NEGATIVO)' and '($RPMFUSION)'"
        label: {
          text: 'Passed in value'
          span: (metadata $repo_type).span
        }
      }
    }
  }
}

# Enable rpmfusion repos
#
# See https://rpmfusion.org/Configuration
def enable_rpmfusion []: nothing -> nothing {
  const CISCO_REPO = 'fedora-cisco-openh264'

  print $'(ansi green)Enabling rpmfusion repos(ansi reset)'

  mut repos = []

  if (^rpm -q rpmfusion-free-release | complete).exit_code != 0 {
    $repos = $repos | append $'https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-($env.OS_VERSION).noarch.rpm'
  }

  if (^rpm -q rpmfusion-nonfree-release | complete).exit_code != 0 {
    $repos = $repos | append $'https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-($env.OS_VERSION).noarch.rpm'
  }

  install_pkgs { packages: $repos }

  print $"(ansi green)Enabling '(ansi cyan)($CISCO_REPO)(ansi green)' repo for RPMFusion compatibility(ansi reset)"
  try {
    ^dnf5 config-manager setopt $'($CISCO_REPO).enabled=1'
  } catch {
    exit 1
  }
}

# Disable rpmfusion repos
def disable_rpmfusion []: nothing -> nothing {
  print $'(ansi green)Removing rpmfusion repos(ansi reset)'

  mut repos = []

  if (^rpm -q rpmfusion-free-release | complete).exit_code == 0 {
    $repos = $repos | append 'rpmfusion-free-release'
  }

  if (^rpm -q rpmfusion-nonfree-release | complete).exit_code == 0 {
    $repos = $repos | append 'rpmfusion-nonfree-release'
  }

  remove_pkgs { packages: $repos }
}

def negativo_repo_list []: nothing -> list<path> {
  try {
    ^dnf5 -y repo list --all --json | from json
  } catch {
    exit 1
  }
    | find negativo17
    | get id
    | ansi strip
    | par-each {|repo|
      try {
        ^dnf5 -y repo info $repo --all --json | from json
      } catch {
        exit 1
      }
    }
    | flatten
    | get id
    | uniq
}

# Enable negativo17-multimedia repos
def enable_negativo []: nothing -> nothing {
  print $'(ansi green)Enabling negativo17 repos(ansi reset)'

  let current_repo_list = negativo_repo_list

  if ($current_repo_list | is-not-empty) {
    print $'(ansi green)Cleaning up existing negativo17 repos(ansi reset)'
    remove_repos $current_repo_list
  }
  add_repos [$NEGATIVO_URL]

  try {
    ^dnf5 repo list --all --json
  } catch {
    exit 1
  }
    | from json
    | find negativo17
    | get id
    | ansi strip
    | each {|id|
      [$'($id).enabled=1' $'($id).priority=90']
    }
    | flatten
    | try {
      ^dnf5 -y config-manager setopt ...($in)
    } catch {
      exit 1
    }
}

# Disable negativo17-multimedia repos
def disable_negativo []: nothing -> nothing {
  print $'(ansi green)Disabling negativo17 repos(ansi reset)'

  remove_repos (negativo_repo_list)
}

# Adds a list of repo files for `dnf` to use
# for installing packages.
#
# Returns a list of IDs of the repos added
def add_repos [$repos: list]: nothing -> list<string> {
  if ($repos | is-not-empty) {
    print $'(ansi green)Adding repositories:(ansi reset)'

    # Substitute %OS_VERSION% & remove newlines/whitespaces from all repo entries
    let repos = $repos
      | each {
        str replace --all '%OS_VERSION%' $env.OS_VERSION
          | str trim
      }
    $repos
      | each {
        print $'- (ansi cyan)($in)(ansi reset)'
      }

    for $repo in $repos {
      let repo_path = [$env.CONFIG_DIRECTORY dnf $repo] | path join
      let repo = if ($repo | str starts-with 'https://') or ($repo | str starts-with 'http://') {
        print $"Adding repository URL: (ansi cyan)'($repo)'(ansi reset)"
        $repo
      } else if ($repo | str ends-with '.repo') and ($repo_path | path exists) {
        print $"Adding repository file: (ansi cyan)'($repo)'(ansi reset)"
        $repo_path
      } else {
        return (error make {
          msg: $"(ansi red)Unrecognized repo (ansi cyan)'($repo)'(ansi reset)"
          label: {
            span: (metadata $repo).span
            text: 'Found in config'
          }
        })
      }

      try {
        ^dnf5 -y config-manager addrepo --overwrite --from-repofile $repo
      } catch {
        exit 1
      }
    }
  }

  # Get a list of paths of all new repo files added
  let repo_files = $repos
    | each {|repo|
      [/ etc yum.repos.d ($repo | path basename)] | path join 
    }

  # Get a list of info for every repo installed
  let repo_info = try {
    ^dnf5 repo list --all --json
  } catch {
    exit 1
  }
    | from json
    | get id
    | par-each {|repo|
      try {
        ^dnf5 repo info --json $repo
      } catch {
        exit 1
      }
        | from json
    }
    | flatten

  # Return the IDs of all repos that were added
  let repo_ids = $repo_info
    | filter {|repo|
      $repo.repo_file_path in $repo_files
    }
    | get id

  $repo_ids
    | each {
      $'($in).enabled=1'
    }
    | try {
      ^dnf5 -y config-manager setopt ...($in)
    } catch {
      exit 1
    }

  $repo_ids
}

# Remove a list of repos. The list must be the IDs of the repos.
def remove_repos [$repos: list]: nothing -> nothing {
  if ($repos | is-not-empty) {
    print $'(ansi green)Removing repositories:(ansi reset)'
    let repos = $repos | str trim
    $repos
      | each {
        print $'- (ansi cyan)($in)(ansi reset)'
      }

    $repos
      | par-each {|repo|
        try {
          ^dnf5 -y repo info $repo --all --json | from json
        } catch {
          exit 1
        }
      }
      | flatten
      | get repo_file_path
      | uniq
      | each {|file|
        print $"Removing repo file '(ansi cyan)($file)(ansi reset)'"
        rm -f $file
      }
  }
}

# Checks to see if the string passed in is
# a COPR repo string. Will error if it isn't
def check_copr []: string -> string {
  let is_copr = ($in | split row / | length) == 2

  if not $is_copr {
    return (error make {
      msg: $"(ansi red)The string '(ansi cyan)($in)(ansi red)' is not recognized as a COPR repo(ansi reset)"
      label: {
        span: (metadata $is_copr).span
        text: 'Checks if string is a COPR repo'
      }
    })
  }

  $in
}

# Enable a list of COPR repos. The COPR repo ID has a '/' in the name.
#
# This will error if a COPR repo ID is invalid.
def add_coprs [$copr_repos: list]: nothing -> list<string> {
  if ($copr_repos | is-not-empty) {
    print $'(ansi green)Adding COPR repositories:(ansi reset)'
    $copr_repos
      | each {
        print $'- (ansi cyan)($in)(ansi reset)'
      }

    for $copr in $copr_repos {
      print $"Adding COPR repository: (ansi cyan)'($copr)'(ansi reset)"
      try {
        ^dnf5 -y copr enable ($copr | check_copr)
      } catch {
        exit 1
      }
    }
  }
  $copr_repos
}

# Disable a list of COPR repos. The COPR repo ID has a '/' in the name.
#
# This will error if a COPR repo ID is invalid.
def disable_coprs [$copr_repos: list]: nothing -> nothing {
  if ($copr_repos | is-not-empty) {
    print $'(ansi green)Adding COPR repositories:(ansi reset)'
    $copr_repos
      | each {
        print $'- (ansi cyan)($in)(ansi reset)'
      }

    for $copr in $copr_repos {
      print $"Disabling COPR repository: (ansi cyan)'($copr)'(ansi reset)"
      try {
        ^dnf5 -y copr disable ($copr| check_copr)
      } catch {
        exit 1
      }
    }
  }
}

# Add a list of keys for integrity checking repos.
def add_keys [$keys: list]: nothing -> nothing {
  if ($keys | is-not-empty) {
    print $'(ansi green)Adding keys:(ansi reset)'
    $keys
      | each {
        print $'- (ansi cyan)($in)(ansi reset)'
      }

    for $key in $keys {
      let key = $key
        | str replace --all '%OS_VERSION%' $env.OS_VERSION
        | str trim

      try {
        ^rpm --import $key
      } catch {
        exit 1
      }
    }
  }
}

# Setup /opt directory symlinks to allow certain packages to install.
#
# Each entry must be the directory name that the application expects
# to install into /opt. A systemd unit will be installed to setup
# symlinks on boot of the OS.
def run_optfix [$optfix_pkgs: list]: nothing -> nothing {
  const LIB_EXEC_DIR = '/usr/libexec/bluebuild'
  const SYSTEMD_DIR = '/etc/systemd/system'
  const MODULE_DIR = '/tmp/modules/dnf'
  const LIB_OPT_DIR = '/usr/lib/opt'
  const VAR_OPT_DIR = '/var/opt'
  const OPTFIX_SCRIPT = 'optfix.sh'
  const SERV_UNIT = 'bluebuild-optfix.service'

  if ($optfix_pkgs | is-not-empty) {
    if not ($LIB_EXEC_DIR | path join $OPTFIX_SCRIPT | path exists) {
      mkdir $LIB_EXEC_DIR
      cp ($MODULE_DIR | path join $OPTFIX_SCRIPT) $'($LIB_EXEC_DIR)/'

      try {
        ^chmod +x $'($LIB_EXEC_DIR | path join $OPTFIX_SCRIPT)'
      } catch {
        exit 1
      }
    }

    if not ($SYSTEMD_DIR | path join $SERV_UNIT | path exists) {
      cp ($MODULE_DIR | path join $SERV_UNIT) $'($SYSTEMD_DIR)/'

      try {
        ^systemctl enable $SERV_UNIT
      } catch {
        exit 1
      }
    }

    print $"(ansi green)Creating symlinks to fix packages that install to /opt:(ansi reset)"
    $optfix_pkgs
      | each {
        print $'- (ansi cyan)($in)(ansi reset)'
      }

    mkdir $VAR_OPT_DIR
    try {
      ^ln -snf $VAR_OPT_DIR /opt
    } catch {
      exit 1
    }

    for $opt in $optfix_pkgs {
      let lib_dir = [$LIB_OPT_DIR $opt] | path join
      let var_opt_dir = [$VAR_OPT_DIR $opt] | path join

      mkdir $lib_dir

      try {
        ^ln -sf $lib_dir $var_opt_dir
      } catch {
        exit 1
      }

      print $"Created symlinks for '(ansi cyan)($opt)(ansi reset)'"
    }
  }
}

# Remove group packages.
def group_remove [remove: record]: nothing -> nothing {
  let remove_list = $remove
    | default [] packages
    | get packages

  if ($remove_list | is-not-empty) {
    print $'(ansi green)Removing group packages:(ansi reset)'
    $remove_list
      | each {
        print $'- (ansi cyan)($in)(ansi reset)'
      }

    try {
      ^dnf5 -y group remove ...($remove_list)
    } catch {
      exit 1
    }
  }
}

# Install group packages.
def group_install [install: record]: nothing -> nothing {
  let install = $install
    | default false with-optional
    | default [] packages
  let install_list = $install
    | get packages
    | each { str trim }

  if ($install_list | is-not-empty) {
    print $'(ansi green)Installing group packages:(ansi reset)'
    $install_list
      | each {
        print $'- (ansi cyan)($in)(ansi reset)'
      }

    mut args = $install | install_args

    if $install.with-optional {
      $args = $args | appent '--with-optional'
    }

    try {
      (^dnf5
        -y
        ($install | weak_arg)
        group
        install
        ...($args)
        ...($install_list))
    } catch {
      exit 1
    }
  }
}

# Remove packages.
def remove_pkgs [remove: record]: nothing -> nothing {
  let remove = $remove
    | default [] packages
    | default true auto-remove

  if ($remove.packages | is-not-empty) {
    print $'(ansi green)Removing packages:(ansi reset)'
    $remove.packages
      | each {
        print $'- (ansi cyan)($in)(ansi reset)'
      }

    mut args = []

    if not $remove.auto-remove {
      $args = $args | append '--no-autoremove'
    }

    try {
      ^dnf5 -y remove ...($args) ...($remove.packages)
    } catch {
      exit 1
    }
  }
}

# Build up args to use on `dnf`
def install_args [...filter: string]: record -> list<string> {
  let install = $in
  mut args = []
  let check_filter = {|arg|
    let arg_exists = ($arg in $install)
    if ($filter | is-empty) {
      $arg_exists and ($install | get $arg)
    } else {
      $arg_exists and ($arg in $filter) and ($install | get $arg)
    }
  }

  if (do $check_filter 'skip-unavailable') {
    $args = $args | append '--skip-unavailable'
  }

  if (do $check_filter 'skip-broken') {
    $args = $args | append '--skip-broken'
  }

  if (do $check_filter 'allow-erasing') {
    $args = $args | append '--allowerasing'
  }

  $args
}

# Generate a weak deps argument
def weak_arg []: record -> string {
  let install =
    | default true install-weak-deps

  if $install.install-weak-deps {
    '--setopt=install_weak_deps=True'
  } else {
    '--setopt=install_weak_deps=False'
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
    | filter {|pkg|
      ($pkg | describe) == 'string'
    }
    | str replace --all '%OS_VERSION%' $env.OS_VERSION
    | str trim
  let http_list = $install_list
    | filter {|pkg|
      ($pkg | str starts-with 'https://') or ($pkg | str starts-with 'http://')
    }
  let local_list = $install_list
    | each {|pkg|
      [$env.CONFIG_DIRECTORY dnf $pkg] | path join
    }
    | filter {|pkg|
      ($pkg | path exists)
    }
  let normal_list = $install_list
    | filter {|pkg|
      not (
        ($pkg | str starts-with 'https://') or ($pkg | str starts-with 'http://')
      ) and not (
        [$env.CONFIG_DIRECTORY dnf $pkg]
          | path join
          | path exists
      )
    }

  if ($install_list | is-not-empty) {
    if ($http_list | is-not-empty) {
      print $'(ansi green)Installing packages directly from URL:(ansi reset)'
      $http_list
        | each {
          print $'- (ansi cyan)($in)(ansi reset)'
        }
    }

    if ($local_list | is-not-empty) {
      print $'(ansi green)Installing local packages:(ansi reset)'
      $local_list
        | each {
          print $'- (ansi cyan)($in)(ansi reset)'
        }
    }

    if ($normal_list | is-not-empty) {
      print $'(ansi green)Installing packages:(ansi reset)'
      $normal_list
        | each {
          print $'- (ansi cyan)($in)(ansi reset)'
        }
    }

    try {
      (^dnf5
        -y
        ($install | weak_arg)
        install
        ...($install | install_args)
        ...($http_list)
        ...($local_list)
        ...($normal_list))
    } catch {
      exit 1
    }
  }

  # Get all the entries that have a repo specified.
  let repo_install_list = $install.packages
    | filter {|pkg|
      'repo' in $pkg and 'packages' in $pkg
    }

  for $repo_install in $repo_install_list {
    let repo = $repo_install.repo
    let packages = $repo_install.packages

    print $'(ansi green)Installing packages from repo (ansi cyan)($repo)(ansi green):(ansi reset)'
    $packages
      | each {
        print $'- (ansi cyan)($in)(ansi reset)'
      }

    try {
      (^dnf5
        -y
        ($repo_install | weak_arg)
        install
        --repoid
        $repo
        ...($repo_install | install_args)
        ...($packages))
    } catch {
      exit 1
    }
  }
}

# Perform a replace operation for a list of packages that
# you want to replace from a specific repo.
def replace_pkgs [replace_list: list]: nothing -> nothing {
  let check = {|item|
    'old' in $item and 'new' in $item
  }

  if ($replace_list | is-not-empty) {
    for $replacement in $replace_list {
      let replacement = $replacement
        | default [] packages

      if ($replacement.packages | is-not-empty) {
        let has_from_repo = 'from-repo' in $replacement

        if not $has_from_repo {
          return (error make {
            msg: $"(ansi red)A value is expected in key 'from-repo'(ansi reset)"
            label: {
              span: (metadata $replacement).span
              text: "Checks for 'from-repo' property"
            }
          })
        }

        let from_repo = $replacement
          | get from-repo

        let swap_packages = $replacement.packages
          | filter $check
        let sync_packages = $replacement.packages
          | filter {
            not (do $check $in)
          }

        if ($swap_packages | is-not-empty) {
          print $"(ansi green)Swapping packages from '(ansi cyan)($from_repo)(ansi green)':(ansi reset)"
          $swap_packages
            | each {
              print $'- (ansi cyan)($in.old)(ansi green) -> (ansi cyan)($in.new)(ansi reset)'
            }

          for $pkg_pair in $swap_packages {
            try {
              (^dnf5
                -y
                swap
                ...($replacement | install_args allow-erasing)
                $pkg_pair.old
                $pkg_pair.new)
            } catch {
              exit 1
            }
          }
        }

        if ($sync_packages | is-not-empty) {
          print $"(ansi green)Replacing packages from '(ansi cyan)($from_repo)(ansi green)':(ansi reset)"
          $sync_packages
            | each {
              print $'- (ansi cyan)($in)(ansi reset)'
            }

          try {
            (^dnf5
              -y
              ($replacement | weak_arg)
              distro-sync
              ...($replacement | install_args)
              --repo $from_repo
              ...($sync_packages))
          } catch {
            exit 1
          }
        }
      }
    }
  }
}

def main [config: string]: nothing -> nothing {
  let config = $config
    | from json
    | default {} repos
    | default {} group-remove
    | default {} group-install
    | default {} remove
    | default {} install
    | default [] optfix
    | default [] replace
  let has_dnf5 = ^rpm -q dnf5 | complete
  let should_cleanup = $config.repos
    | default false cleanup
    | get cleanup

  if $has_dnf5.exit_code != 0 {
    return (error make {
      msg: $"(ansi red)ERROR: Main dependency '(ansi cyan)dnf5(ansi red)' is not installed. Install '(ansi cyan)dnf5(ansi red)' before using this module to solve this error.(ansi reset)"
      label: {
        span: (metadata $has_dnf5).span
        text: 'Checks for dnf5'
      }
    })
  }

  let cleanup_repos = repos $config.repos

  try {
    ^dnf5 makecache --refresh
  } catch {
    exit 1
  }

  run_optfix $config.optfix
  group_remove $config.group-remove
  group_install $config.group-install
  remove_pkgs $config.remove
  install_pkgs $config.install
  replace_pkgs $config.replace

  if $should_cleanup {
    print $'(ansi green)Cleaning up added repos(ansi reset)'
    remove_repos $cleanup_repos.files
    disable_coprs $cleanup_repos.copr

    match $config.repos.nonfree? {
      $repo if $repo == $RPMFUSION => {
        disable_rpmfusion
      }
      $repo if $repo == $NEGATIVO => {
        disable_negativo
      }
      _ => {},
    }
    print $'(ansi green)Finished cleaning up repos(ansi reset)'
  }
}
