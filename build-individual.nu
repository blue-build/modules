#!/usr/bin/env nu
# build separate images for each module in the repo

print $"(ansi green_bold)Gathering images"

let images = ls modules | each { |moduleDir|
    cd $moduleDir.name

    # module is unversioned
    if (glob $"($moduleDir.name | path basename).{sh,nu}" | any { path exists }) {

        print $"(ansi cyan)Found(ansi reset) (ansi cyan_bold)unversioned(ansi reset) (ansi cyan)module:(ansi reset) ($moduleDir.name | path basename)"

        let tags = (
            if ($env.GH_EVENT_NAME != "pull_request" and $env.GH_BRANCH == "main") {
                ["latest", "v1"]
            } else if ($env.GH_EVENT_NAME != "pull_request") {
                [$env.GH_BRANCH, $"v1-($env.GH_BRANCH)"]
            } else {
                [$"pr-($env.GH_PR_NUMBER)", $"v1-pr-($env.GH_PR_NUMBER)"]
            }
        )
        print $"(ansi cyan)Generated tags:(ansi reset) ($tags | str join ' ')"

        {
            name: ($moduleDir.name | path basename)
            directory: ($moduleDir.name)
            tags: $tags
        }

    } else { # module is versioned

        print $"(ansi cyan)Found(ansi reset) (ansi blue_bold)versioned(ansi reset) (ansi cyan)module:(ansi reset) ($moduleDir.name | path basename)"

        let versioned = ls v*/
            | get name | str substring 1.. | into int | sort # sort versions properly
            | each {|version|
                let tags = (
                    if ($env.GH_EVENT_NAME != "pull_request" and $env.GH_BRANCH == "main") {
                        [$"v($version)"]
                    } else if ($env.GH_EVENT_NAME != "pull_request") {
                        [$"v($version)-($env.GH_BRANCH)"]
                    } else {
                        [$"v($version)-pr-($env.GH_PR_NUMBER)"]
                    }
                )
                print $"(ansi cyan)Generated tags:(ansi reset) ($tags | str join ' ')"

                {
                    name: ($moduleDir.name | path basename)
                    directory: $"($moduleDir.name)/v($version)"
                    tags: $tags
                }
        }

        let latest_tag = (
            if ($env.GH_EVENT_NAME != "pull_request" and $env.GH_BRANCH == "main") {
                "latest"
            } else if ($env.GH_EVENT_NAME != "pull_request") {
                $env.GH_BRANCH
            } else {
                $"pr-($env.GH_PR_NUMBER)"
            }
        )
        print $"(ansi cyan)Extra tag for latest image:(ansi reset) ($latest_tag)"
        let latest = ($versioned | last)
        ($versioned
            | update (($versioned | length) - 1) # update the last / latest item in list
            ($latest | update "tags" ($latest.tags | append $latest_tag)) # append tag which should only be given to the latest version
        )

    }
} | flatten directory

print $"(ansi green_bold)Starting image build(ansi reset)"

$images | par-each { |img|

    print $"(ansi cyan)Building image:(ansi reset) modules/($img.name)"
    (docker build .
        -f ./individual.Containerfile
        ...($img.tags | each { |tag| ["-t", $"($env.REGISTRY)/modules/($img.name):($tag)"] } | flatten) # generate and spread list of tags
        --build-arg $"DIRECTORY=($img.directory)"
        --build-arg $"NAME=($img.name)")

    print $"(ansi cyan)Pushing image:(ansi reset) ($env.REGISTRY)/modules/($img.name)"
    let digest = (
        docker push --all-tags $"($env.REGISTRY)/modules/($img.name)"
            | split row "\n"  | last | split row " " | get 2 # parse push output to get digest for signing
    )

    print $"(ansi cyan)Signing image:(ansi reset) ($env.REGISTRY)/modules/($img.name)@($digest)"
    cosign sign -y --key env://COSIGN_PRIVATE_KEY $"($env.REGISTRY)/modules/($img.name)@($digest)"

}

print $"(ansi green_bold)DONE!(ansi reset)"
