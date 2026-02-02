#!/usr/bin/env nu

def main [config: string]: nothing -> nothing {
  let config = $config
    | from json
    | default [] scripts
    | default [] snippets

  let script_dir = [$env.CONFIG_DIRECTORY scripts] | path join
  cd $script_dir
  glob ./**/*{.sh,.nu,.py}
    | each { chmod +x $in }

  $config.scripts
    | each {|script|
      print -e $'(ansi green)Running script: (ansi cyan)($script)(ansi reset)'

      let script_path = [$script_dir $script] | path join
      chmod +x $script_path

      try {
        ^$script_path
        print -e $'(ansi green)Finished running script (ansi cyan)($script)(ansi reset)'
      } catch {
        return (error make {
          msg: $'(ansi red)Failed to run (ansi cyan)($script)(ansi reset)'
        })
      }
    }

  cd -

  $config.snippets
    | each {|snippet|
      print -e $"(ansi green)Running snippet:\n(ansi cyan)($snippet)(ansi reset)"

      try {
        /bin/sh -c $'($snippet)'
        print -e $"(ansi green)Finished running snippet:\n(ansi cyan)($snippet)(ansi reset)"
      } catch {
        return (error make {
          msg: $"(ansi red)Failed to run snippet:\n(ansi cyan)($snippet)(ansi reset)"
        })
      }
    }

  print -e $'(ansi green)Done(ansi reset)'
}
