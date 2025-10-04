#!/usr/libexec/bluebuild/nu/nu

# Validate quadlet files
# Usage: quadlet-validator.nu <quadlet-name>

const validExtensions = [".container" ".pod" ".network" ".volume" ".kube" ".image"]

def main [quadletName: string] {
    let quadletPath = $"/tmp/bluebuild-quadlets/($quadletName)"
    
    if not ($quadletPath | path exists) {
        print $"(ansi red_bold)Error(ansi reset): Quadlet directory not found: ($quadletPath)"
        exit 1
    }
    
    let files = (ls $quadletPath | where type == file)
    
    if ($files | is-empty) {
        print $"(ansi red_bold)Error(ansi reset): No files found in quadlet directory"
        exit 1
    }
    
    mut hasQuadletFile = false
    mut errors = []
    
    for file in $files {
        let fileName = ($file.name | path basename)
        let ext = ($fileName | path parse | get extension)
        
        # Check if it's a valid quadlet file
        if $ext in $validExtensions {
            $hasQuadletFile = true
            
            # Validate file content
            let content = (open $file.name)
            
            # Check for basic INI structure
            if not ($content | str contains "[") {
                $errors = ($errors | append $"($fileName): Missing INI section headers")
            }
            
            # Specific validations by type
            match $ext {
                ".container" => {
                    if not ($content | str contains "Image=") {
                        $errors = ($errors | append $"($fileName): Container file must specify Image=")
                    }
                }
                ".pod" => {
                    if not ($content | str contains "PodName=") {
                        print $"(ansi yellow_bold)Warning(ansi reset): ($fileName): Pod file should specify PodName="
                    }
                }
                ".kube" => {
                    if not ($content | str contains "Yaml=") {
                        $errors = ($errors | append $"($fileName): Kube file must specify Yaml=")
                    }
                }
                ".image" => {
                    if not ($content | str contains "Image=") {
                        $errors = ($errors | append $"($fileName): Image file must specify Image=")
                    }
                }
            }
            
            print $"    (ansi green)✓(ansi reset) ($fileName)"
            
        } else if ($fileName | str ends-with ".service") or ($fileName | str ends-with ".timer") {
            # Regular systemd unit files are OK
            print $"    (ansi blue)ℹ(ansi reset) ($fileName) (systemd unit)"
            
        } else {
            # Unknown file type - warn but don't fail
            print $"    (ansi yellow)⚠(ansi reset) ($fileName) (non-quadlet file, will be copied)"
        }
    }
    
    # Check if we found at least one quadlet file
    if not $hasQuadletFile {
        print $"(ansi red_bold)Error(ansi reset): No valid quadlet files found"
        print $"  Valid extensions: ($validExtensions | str join ', ')"
        exit 1
    }
    
    # Report errors
    if not ($errors | is-empty) {
        print ""
        print $"(ansi red_bold)Validation errors:(ansi reset)"
        for error in $errors {
            print $"  • ($error)"
        }
        exit 1
    }
    
    print $"    (ansi green)✓(ansi reset) Validation passed"
}
