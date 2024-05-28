#!/usr/bin/env nu
# build separate images for each module in the repo

ls modules | each { |moduleDir|
    cd $moduleDir.name

    # module is unversioned
    if ($"($moduleDir.name | path basename).sh" | path exists) {
        {
            name: ($moduleDir.name | path basename)
            directory: ($moduleDir.name)
            tags: ["latest", "v1"]
        }

        (docker build .
            -f ../individual.Containerfile
            --build-arg DIRECTORY=($moduleDir.name) 
            --build-arg NAME=($moduleDir.name | path basename))

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
}