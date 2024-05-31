#!/usr/bin/env nu
# build separate images for each module in the repo

ls modules | each { |moduleDir|
    cd $moduleDir.name

    # module is unversioned
    if ($"($moduleDir.name | path basename).sh" | path exists) {
        let meta = {
            name: ($moduleDir.name | path basename)
            directory: ($moduleDir.name)
            tags: ["latest", "v1"]
        }
        
        cd ../../
        (docker build .
            -f ./individual.Containerfile
            -t $"modules/($meta.name):($meta.tags)"
            --build-arg $"DIRECTORY=($meta.directory)"
            --build-arg $"NAME=($meta.name)")

        docker push $"$env.REGISTRY/modules/($meta.name):($meta.tags)"

    } else { # module is versioned
        ls v*/ | each { |item|
            if ($item.type == dir) {
                let meta = {
                    name: ($moduleDir.name | path basename)
                    directory: $"($moduleDir.name)/($item.name)"
                    tags: ["latest", ($item.name)]
                }
            }
        }
    }
}