function opr
    op whoami &>/dev/null
    if test $status -ne 0
        if test -n "$OP_ACCOUNT"
            eval (op signin --account "$OP_ACCOUNT")
        else
            eval (op signin)
        end
    end

    if test -f "$PWD/.env"
        op run --env-file="$PWD/.env" -- $argv
    else if test -f "$PWD/.env.local"
        op run --env-file="$PWD/.env.local" -- $argv
    else if test -f "$XDG_CONFIG_HOME/op/.env"
        op run --env-file="$XDG_CONFIG_HOME/op/.env" -- $argv
    else
        $argv
    end
end
