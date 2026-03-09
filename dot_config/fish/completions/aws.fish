# aws sso login --profile の補完
function __fish_aws_profiles
    if test -f $HOME/.config/aws/config
        string match -r '(?<=\[profile )\S+(?=\])' < $HOME/.config/aws/config
    end
end

complete -c aws -n '__fish_seen_subcommand_from sso' -n '__fish_seen_subcommand_from login' -l profile -xa '(__fish_aws_profiles)'
