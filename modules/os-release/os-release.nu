#!/usr/bin/env nu

def main [config: string]: nothing -> nothing {
  let config = $config
    | from json
    | default {} properties
  mut os_release = open --raw /etc/os-release
    | lines
    | parse '{key}={value}'
    | transpose --ignore-titles -dr
    | str trim -c '"'
    | str trim -c "'"
  print $'(ansi green)Original release:(ansi reset)'
  print $os_release

  for $item in ($config.properties | transpose key value) {
    if $item.key in $os_release {
      print $'(ansi green)Updating (ansi cyan)($item.key)(ansi green) with value (ansi yellow)($item.value)(ansi reset)'
      $os_release = $os_release | update $item.key $item.value
    } else {
      print $'(ansi green)Adding (ansi cyan)($item.key)(ansi green) with value (ansi yellow)($item.value)(ansi reset)'
      $os_release = $os_release | insert $item.key $item.value
    }
  }

  print $'(ansi green)New release:(ansi reset)'
  print $os_release

  $os_release
    | transpose key value
    | each { $'($in.key)="($in.value)"' }
    | str join "\n"
    | save --force /etc/os-release
}
