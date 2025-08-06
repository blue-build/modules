export def "dnf install" [
  --opts: record
  --global-opts: record
  --repoid: string
  packages: list
]: nothing -> nothing {
  let dnf = dnf version

  if ($packages | is-empty) {
    return (error make {
      msg: 'At least one package is required'
      label: {
        text: 'Packages'
        span: (metadata $packages).span
      }
    })
  }

  try {
    (^$dnf.path
      -y
      ($opts | weak_arg --global-config $global_opts)
      install
      ...(if $repoid != null {
        [--repoid $repoid]
      } else {
        []
      })
      ...($opts | install_args --global-config $global_opts)
      ...$packages)
  } catch {|e|
    print $'($e.msg)'
    exit 1
  }
}

export def "dnf remove" [
  --opts: record
  packages: list
]: nothing -> nothing {
  let dnf = dnf version
  
  if ($packages | is-empty) {
    return (error make {
      msg: 'At least one package is required'
      label: {
        text: 'Packages'
        span: (metadata $packages).span
      }
    })
  }

  mut args = []

  if not $opts.auto-remove {
    $args = $args | append '--no-autoremove'
  }

  try {
    (^$dnf.path
      -y
      remove
      ...($args)
      ...($packages))
  } catch {|e|
    print $'($e.msg)'
    exit 1
  }
}

export def "dnf config-manager addrepo" [
  --from-repofile: string
]: nothing -> nothing {
  check_dnf_plugins
  let dnf = dnf version
  
  try {
    match $dnf.command {
      "dnf4" => {
        ^dnf4 -v -y config-manager --add-repo $from_repofile
      }
      "dnf5" => {
        (^dnf5
          -y
          config-manager
          addrepo
          --create-missing-dir
          --overwrite
          --from-repofile $from_repofile)
      }
    }
  } catch {|e|
    print $'($e.msg)'
    exit 1
  }
}

export def "dnf config-manager setopt" [
  opts: list
]: nothing -> nothing {
  check_dnf_plugins
  let dnf = dnf version
  
  if ($opts | is-empty) {
    return (error make {
      msg: 'At least one option is required'
      label: {
        text: 'Options'
        span: (metadata $opts).span
      }
    })
  }

  try {
    match $dnf.command {
      "dnf4" => {
        (^dnf4
          -y
          config-manager
          --save
          ...($opts
            | each {|opt|
              [--setopt $opt]
            }
            | flatten))
      }
      "dnf5" => {
        ^dnf5 -y config-manager setopt ...($opts)
      }
    }
  } catch {|e|
    print $'($e.msg)'
    exit 1
  }
}

export def "dnf copr enable" [copr: string]: nothing -> nothing {
  check_dnf_plugins
  let dnf = dnf version
  
  try {
    ^$dnf.path -y copr enable ($copr | check_copr)
  } catch {|e|
    print $'($e.msg)'
    exit 1
  }
}

export def "dnf copr disable" [copr: string]: nothing -> nothing {
  check_dnf_plugins
  let dnf = dnf version
  
  try {
    ^$dnf.path -y copr disable ($copr | check_copr)
  } catch {|e|
    print $'($e.msg)'
    exit 1
  }
}

export def "dnf swap" [
  --opts: record
  --global-opts: record
  old: string
  new: string
]: nothing -> nothing {
  let dnf = dnf version

  try {
    (^$dnf.path
      -y
      swap
      ...($opts | install_args --global-config $global_opts 'allow-erasing')
      $old
      $new)
  } catch {|e|
    print $'($e.msg)'
    exit 1
  }
}

export def "dnf distro-sync" [
  --opts: record
  --repo: string
  packages: list
]: nothing -> nothing {
  let dnf = dnf version
  
  if ($packages | is-empty) {
    return (error make {
      msg: 'At least one package is required'
      label: {
        text: 'Packages'
        span: (metadata $packages).span
      }
    })
  }

  try {
    (^$dnf.path
      -y
      ($opts | weak_arg)
      distro-sync
      ...($opts | install_args)
      --repo $repo
      ...($packages))
  } catch {|e|
    print $'($e.msg)'
    exit 1
  }
}

export def "dnf group install" [
  --opts: record
  packages: list
]: nothing -> nothing {
  let dnf = dnf version
  
  if ($packages | is-empty) {
    return (error make {
      msg: 'At least one package is required'
      label: {
        text: 'Packages'
        span: (metadata $packages).span
      }
    })
  }

  mut args = $opts | install_args

  if $opts.with-optional {
    $args = $args | append '--with-optional'
  }

  try {
    (^$dnf.path
      -y
      ($opts | weak_arg)
      group
      install
      ...($args)
      ...($packages))
  } catch {|e|
    print $'($e.msg)'
    exit 1
  }
}

export def "dnf group remove" [
  packages: list
]: nothing -> nothing {
  let dnf = dnf version
  
  if ($packages | is-empty) {
    return (error make {
      msg: 'At least one package is required'
      label: {
        text: 'Packages'
        span: (metadata $packages).span
      }
    })
  }

  try {
    (^$dnf.path -y group remove ...($packages))
  } catch {|e|
    print $'($e.msg)'
    exit 1
  }
}

export def "dnf repo list" []: nothing -> list {
  let dnf = dnf version

  try {
    match $dnf.command {
      "dnf4" => {
        ^/tmp/modules/dnf/dnf-repolist | from json
      }
      "dnf5" => {
        ^dnf5 repo list --all --json | from json
      }
    }
  } catch {|e|
    print $'($e.msg)'
    exit 1
  }
}

export def "dnf repo info" [
  repo: string
  --all
]: nothing -> record {
  let dnf = dnf version

  try {
    match $dnf.command {
      "dnf4" => {
        ^/tmp/modules/dnf/dnf-repoinfo $repo | from json
      }
      "dnf5" => {
        (^dnf5
          -y
          repo
          info
          $repo
          ...(if $all {
            [--all]
          } else {
            []
          })
          --json)
          | from json
      }
    }
  } catch {|e|
    print $'($e.msg)'
    exit 1
  }
}

export def "dnf makecache" []: nothing -> nothing {
  let dnf = dnf version

  try {
    ^$dnf.path makecache --refresh
  } catch {|e|
    print $'($e.msg)'
    exit 1
  }
}

export def "dnf version" []: nothing -> record {
  let dnf = which dnf4 dnf5

  if ("dnf5" in ($dnf | get command)) {
    $dnf | where command == "dnf5" | first
  } else if ("dnf4" in ($dnf | get command)) {
    $dnf | where command == "dnf4" | first
  } else {
    return (error make {
      msg: $"(ansi red)ERROR: Main dependency '(ansi cyan)dnf5/dnf4(ansi red)' is not installed. Install '(ansi cyan)dnf5/dnf4(ansi red)' before using this module to solve this error.(ansi reset)"
      label: {
        span: (metadata $dnf).span
        text: 'Checks for dnf5/dnf4'
      }
    })
  }
}

# Build up args to use on `dnf`
def install_args [
  --global-config: record
  ...filter: string
]: record -> list<string> {
  let opts = $in | default {}
  let global_config = $global_config | default {}
  let install = $opts
    | default (
      $global_config.skip-unavailable?
        | default false
    ) skip-unavailable
    | default (
      $global_config.skip-broken?
        | default false
    ) skip-broken
    | default (
      $global_config.allow-erasing?
        | default false
    ) allow-erasing
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
def weak_arg [
  --global-config: record
]: record -> string {
  let opts = $in | default {}
  let global_config = $global_config | default {}
  let install = $opts
    | default (
      $global_config.install-weak-deps?
        | default true
    ) install-weak-deps

  if $install.install-weak-deps {
    '--setopt=install_weak_deps=True'
  } else {
    '--setopt=install_weak_deps=False'
  }
}

# Handles installing necessary plugins for repo management.
def check_dnf_plugins []: nothing -> nothing {
  let dnf = dnf version

  match $dnf.command {
    "dnf4" => {
      if (^rpm -q dnf-plugins-core | complete).exit_code != 0 {
        print $'(ansi yellow1)Required dnf4 plugins are not installed. Installing plugins(ansi reset)'

        ^dnf4 -y install dnf-plugins-core
      }
    }
    "dnf5" => {
      if (^rpm -q dnf5-plugins | complete).exit_code != 0 {
        print $'(ansi yellow1)Required dnf5 plugins are not installed. Installing plugins(ansi reset)'

        ^dnf5 -y install dnf5-plugins
      }
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

