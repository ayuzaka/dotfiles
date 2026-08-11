export MISE_ENV="{{ vars.dotfiles_purpose }}"

{% if os() == "macos" %}
{% if vars.dotfiles_purpose == "private" %}
# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
{% else %}
# Set PATH, MANPATH, etc., for Homebrew.
eval "$(/opt/homebrew/bin/brew shellenv)"
{% endif %}

{% endif %}
