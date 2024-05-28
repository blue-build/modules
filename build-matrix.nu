# Generate build matrix for GitHub Actions to build separate images for each module in the repo

print (ls modules | each { |moduleDir|
    cd $moduleDir.name

    # module is unversioned
    if ($"($moduleDir.name | path basename).sh" | path exists) {
        {
            name: ($moduleDir.name | path basename)
            directory: ($moduleDir.name)
            tags: ["latest", "v1"]
        }
    } else { # module is versioned
        ls v*/ | each { |item|
            if ($item.type == dir) {
                {
                    name: ($moduleDir.name | path basename)
                    directory: $"($moduleDir.name)/($item.name)"
                    tags: ["latest", ($item.name)]
                }
            }
        }
    }

} | flatten name | to json --raw)