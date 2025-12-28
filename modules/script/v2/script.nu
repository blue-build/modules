#!/usr/bin/env nu

def main [config: string]: nothing -> nothing {
  let config = $config
    | from json
    | default [] scripts
    | default [] snippets


  $config.scripts
    | each {|script|
      cd $'($env.CONFIG_DIRECTORY)/scripts'
      let script = $'($env.PWD)/($script)'
      chmod +x $script
      print -e $'(ansi green)Running script: (ansi cyan)($script)(ansi reset)'
      ^$script
    }

  $config.snippets
    | each {|snippet|
      print -e $"(ansi green)Running snippet:\n(ansi cyan)($snippet)(ansi reset)"
      /bin/sh -c $'($snippet)'
    }
}
