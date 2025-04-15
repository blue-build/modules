export def "dnf install" [
  --opts: record
  --global-opts: record
  packages: list<string>
]: nothing -> nothing {
  
}

def versions []: nothing -> list<string> {
  ["dnf5" "dnf4"]
}

def dnf_version []: nothing -> string@versions {
  
}

# Build up args to use on `dnf`
def install_args [
  --global-config: record
  ...filter: string
]: record -> list<string> {
  let install = $in
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
  let install =
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
