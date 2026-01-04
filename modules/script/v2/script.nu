#!/usr/bin/env nu

def main [config: string]: nothing -> nothing {
  let config = $config
    | from json
    | default [] scripts
    | default [] snippets

  cd $'($env.CONFIG_DIRECTORY)/scripts'
  ls
    | where { ($in | path type) == 'file' }
    | each { chmod +x $in }

  $config.scripts
    | each {|script|
      let script = $'($env.PWD)/($script)'
      print -e $'(ansi green)Running script: (ansi cyan)($script)(ansi reset)'
      ^$script
    }

  cd -

  $config.snippets
    | each {|snippet|
      print -e $"(ansi green)Running snippet:\n(ansi cyan)($snippet)(ansi reset)"
      /bin/sh -c $'($snippet)'
    }
}
