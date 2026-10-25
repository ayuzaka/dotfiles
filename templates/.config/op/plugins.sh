export OP_PLUGIN_ALIASES_SOURCED=1
{% if vars.dotfiles_purpose == "work" %}
alias localstack="op plugin run -- localstack"
{% endif %}
