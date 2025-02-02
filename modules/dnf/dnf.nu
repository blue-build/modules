#!/usr/bin/env nu

def repos [$repos: record]: nothing -> nothing {
  let repos = $repos
    | default [] keys

  match $repos.files? {
    [..$files] => {
      add_repos $files
    }
    { add: [..$add] } => {
      add_repos $add
    }
    { remove: [..$remove] } => {
      remove_repos $remove
    }
    {
      add: [..$add]
      remove: [..$remove]
    } => {
      add_repos $add
      remove_repos $remove
    }
  }

  match $repos.copr? {
    [..$coprs] => {
      add_coprs $coprs
    }
    { enable: [..$enable] } => {
      add_coprs $enable
    }
    { disable: [..$disable] } => {
      disable_coprs $disable
    }
    {
      enable: [..$enable]
      disable: [..$disable]
    } => {
      add_coprs $enable
      disable_coprs $disable
    }
  }

  add_keys $repos.keys
}

def add_repos [$repos: list]: nothing -> nothing {
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
      let repo = if ($repo | str starts-with 'https://') or ($repo | str starts-with 'http://') {
        print $"Adding repository URL: (ansi cyan)'($repo)'(ansi reset)"
        $repo
      } else if ($repo | str ends-with '.repo') and ($'($env.CONFIG_DIRECTORY)/dnf/($repo)' | path exists) {
        print $"Adding repository file: (ansi cyan)'($repo)'(ansi reset)"
        $env.CONFIG_DIRECTORY | path join dnf $repo
      } else {
        return (error make {
          msg: $"(ansi red)Urecognized repo (ansi cyan)'($repo)'(ansi reset)"
          label: {
            span: (metadata $repo).span
            text: 'Found in config'
          }
        })
      }

      try {
        ^dnf -y config-manager addrepo --from-repofile $repo
      }
    }
  }
}

def remove_repos [$repos: list]: nothing -> nothing {
  if ($repos | is-not-empty) {
    print $'(ansi green)Removing repositories:(ansi reset)'
    let repos = $repos
      | each {
        str trim
      }
    $repos
      | each {
        print $'- (ansi cyan)($in)(ansi reset)'
      }

    for $repo in $repos {
      let repo = try {
        ^dnf repo info --json $repo | from json
      }

      print $'Removing file: (ansi cyan)($repo.repo_file_path)(ansi reset)'
      rm -f ($repo.repo_file_path)
    }
  }
}

def add_coprs [$copr_repos: list]: nothing -> nothing {
  if ($copr_repos | is-not-empty) {
    print $'(ansi green)Adding COPR repositories:(ansi reset)'
    $copr_repos
      | each {
        print $'- (ansi cyan)($in)(ansi reset)'
      }

    for $copr in $copr_repos {
      let is_copr = ($copr | split row / | length) == 2

      if not $is_copr {
        return (error make {
          msg: $"(ansi red)The string '(ansi cyan)($copr)(ansi red)' is not recognized as a COPR repo(ansi reset)"
          label: {
            span: (metadata $is_copr).span
            text: 'Checks if string is a COPR repo'
          }
        })
      }

      print $"Adding COPR repository: (ansi cyan)'($copr)'(ansi reset)"
      try {
        ^dnf -y copr enable $copr
      }
    }
  }
}

def disable_coprs [$copr_repos: list]: nothing -> nothing {
  if ($copr_repos | is-not-empty) {
    print $'(ansi green)Adding COPR repositories:(ansi reset)'
    $copr_repos
      | each {
        print $'- (ansi cyan)($in)(ansi reset)'
      }

    for $copr in $copr_repos {
      let is_copr = ($copr | split row / | length) == 2

      if not $is_copr {
        return (error make {
          msg: $"(ansi red)The string '(ansi cyan)($copr)(ansi red)' is not recognized as a COPR repo(ansi reset)"
          label: {
            span: (metadata $is_copr).span
            text: 'Checks if string is a COPR repo'
          }
        })
      }

      print $"Disabling COPR repository: (ansi cyan)'($copr)'(ansi reset)"
      try {
        ^dnf -y copr disable $copr
      }
    }
  }
}

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
      }
    }
  }
}

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
        chmod +x $'($LIB_EXEC_DIR | path join $OPTFIX_SCRIPT)'
      }
    }

    if not ($SYSTEMD_DIR | path join $SERV_UNIT | path exists) {
      cp ($MODULE_DIR | path join $SERV_UNIT) $'($SYSTEMD_DIR)/'

      try {
        ^systemctl enable $SERV_UNIT
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
    }

    for $opt in $optfix_pkgs {
      let lib_dir = $LIB_OPT_DIR | path join $opt
      mkdir $lib_dir

      try {
        ^ln -sf $lib_dir ($VAR_OPT_DIR | path join $opt)
      }

      print $"Created symlinks for '(ansi cyan)($opt)(ansi reset)'"
    }
  }
}

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
      ^dnf -y group remove ...($remove_list)
    }
  }
}

def group_install [install: record]: nothing -> nothing {
  let install = $install
    | default true install-weak-dependencies
    | default false skip-unavailable-packages
    | default false skip-broken-packages
    | default false allow-erasing-packages
    | default [] packages
  let install_list = $install
    | get packages
    | each { str trim }

  if ($install_list | is-not-empty) {
    print $'(ansi cyan)Installing group packages:(ansi reset)'
    $install_list
      | each {
        print $'- (ansi cyan)($in)(ansi reset)'
      }

    mut args = []

    let weak_arg = if $install.install-weak-dependencies {
      '--setopt=install_weak_deps=True'
    } else {
      '--setopt=install_weak_deps=False'
    }

    if $install.skip-unavailable-packages {
      $args = $args | append '--skip-unavailable'
    }

    if $install.skip-broken-packages {
      $args = $args | append '--skip-broken'
    }

    if $install.allow-erasing-packages {
      $args = $args | append '--allowerasing'
    }

    try {
      ^dnf -y $weak_arg group install --refresh ...($args) ...($install_list)
    }
  }
}

def remove_pkgs [remove: record]: nothing -> nothing {
  let remove = $remove
    | default [] packages
    | default true remove-unused-dependencies

  if ($remove.packages | is-not-empty) {
    print $'(ansi green)Removing packages:(ansi reset)'
    $remove.packages
      | each {
        print $'- (ansi cyan)($in)(ansi reset)'
      }

    mut args = []

    if not $remove.remove-unused-dependencies {
      $args = $args | append '--no-autoremove'
    }

    try {
      ^dnf -y remove ...($args) ...($remove.packages)
    }
  }
}

def install_pkgs [install: record]: nothing -> nothing {
  let install = $install
    | default true install-weak-dependencies
    | default false skip-unavailable-packages
    | default false skip-broken-packages
    | default false allow-erasing-packages
    | default [] packages

  let install_list = $install.packages
    | each { str replace --all '%OS_VERSION%' $env.OS_VERSION | str trim }
  let http_list = $install_list
    | filter {|pkg|
      ($pkg | str starts-with 'https://') or ($pkg | str starts-with 'http://')
    }
  let local_list = $install_list
    | filter {|pkg|
      ($env.CONFIG_DIRECTORY | path join dnf $pkg | path exists)
    }
  let normal_list = $install_list
    | filter {|pkg|
      not (
        ($pkg | str starts-with 'https://') or ($pkg | str starts-with 'http://')
      ) and not (
        ($env.CONFIG_DIRECTORY | path join dnf $pkg | path exists)
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

    mut args = []

    let weak_arg = if $install.weak-deps {
      '--setopt=install_weak_deps=True'
    } else {
      '--setopt=install_weak_deps=False'
    }

    if $install.skip-unav {
      $args = $args | append '--skip-unavailable'
    }

    if $install.skip-broken {
      $args = $args | append '--skip-broken'
    }

    if $install.allow-erase {
      $args = $args | append '--allowerasing'
    }

    try {
      ^dnf -y $weak_arg install --refresh ...($args) ...($install_list)
    }
  }
}

def replace_pkgs [replace_list: list]: nothing -> nothing {
  if ($replace_list | is-not-empty) {
    for $replacement in $replace_list {
      let replacement = $replacement
        | default [] packages
        | default true install-weak-dependencies
        | default false skip-unavailable-packages
        | default false skip-broken-packages
        | default false allow-erasing-packages

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

        print $"(ansi green)Replacing packages from '(ansi cyan)($from_repo)(ansi green)':(ansi reset)"
        $replacement.packages
          | each {
            print $'- (ansi cyan)($in)(ansi reset)'
          }

        mut args = []

        let weak_arg = if $replacement.weak-deps {
          '--setopt=install_weak_deps=True'
        } else {
          '--setopt=install_weak_deps=False'
        }

        if $replacement.skip-unav {
          $args = $args | append '--skip-unavailable'
        }

        if $replacement.skip-broken {
          $args = $args | append '--skip-broken'
        }

        if $replacement.allow-erase {
          $args = $args | append '--allowerasing'
        }

        try {
          ^dnf -y $weak_arg distro-sync --refresh ...($args) --repo $from_repo ...($replacement.packages)
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
    | default [] replace
  let has_dnf5 = ^rpm -q dnf5 | complete

  if $has_dnf5.exit_code != 0 {
    return (error make {
      msg: $"(ansi red)ERROR: Main dependency '(ansi cyan)dnf5(ansi red)' is not installed. Install '(ansi cyan)dnf5(ansi red)' before using this module to solve this error.(ansi reset)"
      label: {
        span: (metadata $has_dnf5).span
        text: 'Checks for dnf5'
      }
    })
  }

  repos $config.repos
  group_remove $config.group-remove
  group_install $config.group-install
  remove_pkgs $config.remove
  install_pkgs $config.install
  replace_pkgs $config.replace
}
