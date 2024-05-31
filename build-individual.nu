#!/usr/bin/env nu
# build separate images for each module in the repo

print $"(ansi green)Gathering images..."

let images = ls modules | each { |moduleDir|
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
} | flatten directory

print $"(ansi green)Starting image build..."

$images | par-each { |img|
    (docker build .
        -f ./individual.Containerfile
        ...($img.tags | each { |tag| ["-t", $"($env.REGISTRY)/modules/($img.name):($tag)"] } | flatten)
        --build-arg $"DIRECTORY=($img.directory)"
        --build-arg $"NAME=($img.name)")

    docker push --all-tags $"($env.REGISTRY)/modules/($img.name)"
}