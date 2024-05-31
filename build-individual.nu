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
        let versioned = ls v*/
            | get name | str substring 1.. | into int | sort # sort versions properly
            | each {|version|
                {
                    name: ($moduleDir.name | path basename)
                    directory: $"($moduleDir.name)/v($version)"
                    tags: [($"v($version)")]
                }
        }
        let latest = $versioned | last
        ($versioned
            | update (($versioned | length) - 1) # update the last / latest item in list
            ($latest | update "tags" ($latest.tags | append "latest"))) # append "latest" to tags
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