set fish_greeting
function fish_prompt
    pgrep -u haoxuany vim > /dev/null
    if test $status -eq 0
        printf '%s(vim) ' (set_color red)
    end
    string join '' -- \
        (set_color cyan) (prompt_pwd --full-length-dirs 2) \
        \n \
        (set_color yellow) '$ ' \
        (set_color normal)
end

function fish_right_prompt
    string join '' -- (set_color brown) (prompt_hostname)
end

set -gx EDITOR nvim

alias vi="nvim"
alias vim="nvim"

# fish shell has no support for cdable vars, which is very annoying
set -gx CDPATH . "$HOME/.cdpath"

if status is-interactive
    # Commands to run in interactive sessions can go here
    function book -a name
        if test -n "$name"
            set bp "$HOME/.cdpath/$name"
            mkdir -p "$HOME/.cdpath"
            ln -s $(pwd) $bp
            if test $status -eq 0
                echo "Linked $bp to $(pwd)"
            end
        else
            ls -Al "$HOME/.cdpath"
        end
    end

    function unbook -a name
        set bp "$HOME/.cdpath/$name"
        if test -L $bp
            unlink $bp
        else
            echo "$bp does not exist."
        end
    end

    function abs
        cd $(realpath .)
    end
end
