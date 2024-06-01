#!/usr/bin/env nu
# build separate images for each module in the repo

print $"(ansi green_bold)Gathering images"

let images = ls modules | each { |moduleDir|
    cd $moduleDir.name

    # module is unversioned
    if ($"($moduleDir.name | path basename).sh" | path exists) {

        print $"(ansi cyan)Found unversioned module: ($moduleDir.name)"

        {
            name: ($moduleDir.name | path basename)
            directory: ($moduleDir.name)
            tags: ["latest", "v1"]
        }

    } else { # module is versioned

        print $"(ansi cyan)Found versioned module: ($moduleDir.name)"

        let versioned = ls v*/
            | get name | str substring 1.. | into int | sort # sort versions properly
            | each {|version|
                {
                    name: ($moduleDir.name | path basename)
                    directory: $"($moduleDir.name)/v($version)"
                    tags: [($"v($version)")]
                }
        }

        let latest = ($versioned | last)
        ($versioned
            | update (($versioned | length) - 1) # update the last / latest item in list
            ($latest | update "tags" ($latest.tags | append "latest")) # append "latest" to tags
        )

    }
} | flatten directory

print $"(ansi green_bold)Starting image build"

$images | par-each { |img|

    do --capture-errors { 
        (docker build .
            -f ./individual.Containerfile
            ...($img.tags | each { |tag| ["-t", $"($env.REGISTRY)/modules/($img.name):($tag)"] } | flatten)
            --build-arg $"DIRECTORY=($img.directory)"
            --build-arg $"NAME=($img.name)")
    } | print $"(ansi cyan)Image built: modules/($img.name)(ansi reset)\n ($in)" 

    let digest = do --capture-errors {
        (docker push --all-tags $"($env.REGISTRY)/modules/($img.name)"
            | split row "\n"  | last | split row " " | get 2) # parse push output to get digest for signing
    } | print $"(ansi cyan)Image pushed: ($env.REGISTRY)/modules/($img.name)(ansi reset)\n ($in)"
    
    do --capture-errors {
        cosign sign -y --key env://COSIGN_PRIVATE_KEY $"($env.REGISTRY)/modules/($img.name)@($digest)"
    } | print $"(ansi cyan)Image signed: ($env.REGISTRY)/modules/($img.name)@($digest)(ansi reset)\n ($in)"
}

print $"(ansi green_bold)DONE!"