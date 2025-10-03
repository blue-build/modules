#!/usr/libexec/bluebuild/nu/nu

# Parse Git URL and download quadlet
# Usage: git-source-parser.nu <git-url> <branch> <quadlet-name>

def main [gitUrl: string, branch: string, quadletName: string] {
    # Parse Git URL
    # Supports: https://github.com/org/repo/tree/branch/path/to/dir
    
    mut repoUrl = ""
    mut subPath = ""
    
    if ($gitUrl | str contains "/tree/") {
        # URL includes path component
        let parts = ($gitUrl | split row "/tree/")
        $repoUrl = $parts.0
        
        # Extract subpath after branch
        let treePath = $parts.1
        let pathParts = ($treePath | split row "/")
        
        # Skip the branch part and get the rest
        $subPath = ($pathParts | skip 1 | str join "/")
        
    } else {
        # Simple repo URL
        $repoUrl = $gitUrl
        $subPath = $quadletName
    }
    
    print $"  Repository: ($repoUrl)"
    print $"  Branch: ($branch)"
    if not ($subPath | is-empty) {
        print $"  Subdirectory: ($subPath)"
    }
    
    # Create temp directory for cloning
    let tempDir = (mktemp -d -t bluebuild-quadlets-XXXXXXXXXX)
    
    try {
        # Clone repository with sparse checkout for efficiency
        cd $tempDir
        
        git init | complete
        git remote add origin $repoUrl | complete
        
        # Enable sparse checkout if we have a subpath
        if not ($subPath | is-empty) {
            git config core.sparseCheckout true | complete
            $"($subPath)/*\n" | save .git/info/sparse-checkout
        }
        
        # Fetch and checkout
        print $"  Cloning repository..."
        let fetchResult = (git fetch --depth 1 origin $branch | complete)
        if $fetchResult.exit_code != 0 {
            print $"(ansi red_bold)Error(ansi reset): Failed to fetch repository"
            print $fetchResult.stderr
            exit 1
        }
        
        git checkout $branch | complete
        
        # Determine source path
        let sourcePath = if ($subPath | is-empty) {
            $quadletName
        } else {
            $subPath
        }
        
        let fullSourcePath = $"($tempDir)/($sourcePath)"
        
        # Verify directory exists
        if not ($fullSourcePath | path exists) {
            print $"(ansi red_bold)Error(ansi reset): Quadlet directory not found: ($sourcePath)"
            print $"  Looked in: ($fullSourcePath)"
            print $"  Repository contents:"
            ls $tempDir | each {|item| print $"    ($item.name)"}
            exit 1
        }
        
        # Create destination directory
        let destPath = $"/tmp/bluebuild-quadlets/($quadletName)"
        mkdir $destPath
        
        # Copy quadlet files
        print $"  Copying quadlet files..."
        let files = (ls $fullSourcePath | where type == file)
        
        if ($files | is-empty) {
            print $"(ansi red_bold)Error(ansi reset): No files found in quadlet directory"
            exit 1
        }
        
        for file in $files {
            cp $file.name $destPath
            print $"    ($file.name | path basename)"
        }
        
        print $"  (ansi green)✓(ansi reset) Downloaded ($files | length) file\(s\)"
        
    } catch {|err|
        print $"(ansi red_bold)Error during git operations(ansi reset):"
        print $err
        exit 1
    } finally {
        # Cleanup temp directory
        rm -rf $tempDir
    }
}
