#!/usr/bin/env nu

def determine_file_dir []: nothing -> string {
  let config_dir = $env.CONFIG_DIRECTORY

  if $config_dir == '/tmp/config' {
    $config_dir | path join 'files' 
  } else {
    $config_dir
  }
}

def main [config: string]: nothing -> nothing {
  let config = $config | from json
  let files: list = $config.files
  let list_is_empty = $files | is-empty

  if $list_is_empty {
    return (error make {
      msg: $"(ansi red_bold)At least one entry is required in property(ansi reset) `(ansi cyan)files(ansi reset)`:\n($config | to yaml)"
      label: {
        text: 'Checks for empty list'
        span: (metadata $list_is_empty).span
      }
    })
  }

  let config_dir = determine_file_dir

  for $file in $files {
    let file = $file | merge { source: ($config_dir | path join $file.source) }
    let source = $file.source
    let destination = $file.destination
    let source_exists = not ($source | path exists)
    let is_dir = ($destination | path exists) and ($destination | path type) == 'file'

    if $source_exists {
      return (error make {
        msg: $"(ansi red_bold)The path (ansi cyan)`($source)`(ansi reset) (ansi red_bold)does not exist(ansi reset):\n($config | to yaml)"
        label: {
          text: 'Checks for source'
          span: (metadata $source_exists).span
        }
      })
    }

    if $is_dir {
      return (error make {
        msg: $"(ansi red_bold)The destination path (ansi cyan)`($destination)`(ansi reset) (ansi red_bold)should be a directory(ansi reset):\n($config | to yaml)"
        label: {
          text: 'Checks destination is directory'
          span: (metadata $is_dir).span
        }
      })
    }

    print $'Copying (ansi cyan)($source)(ansi reset) to (ansi cyan)($destination)(ansi reset)'
    mkdir $destination

    if ($source | path type) == 'dir' {
      cp -rfv ($source | path join * | into glob) $destination
    } else {
      cp -fv $source $destination
    }

    let git_keep = $destination | path join '.gitkeep'

    if ($git_keep | path exists) {
      rm -f $git_keep
    }
  }
}
