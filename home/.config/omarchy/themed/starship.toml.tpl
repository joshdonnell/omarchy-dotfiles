# Omarchy renders this to ~/.local/state/omarchy/current/theme/starship.toml on every
# theme change, and ~/.config/starship.toml links there. Edit this file, not that one.
"$schema" = 'https://starship.rs/config-schema.json'

format = """
${env_var.PROMPT_HOST}\
$directory\
[](bg:seg2 fg:seg1)\
$git_branch\
$git_status\
[](fg:seg2 bg:seg3)\
$c\
$rust\
$golang\
$nodejs\
$php\
$java\
$kotlin\
$haskell\
$python\
[](fg:seg3)\
$character"""
command_timeout = 1500

palette = 'omarchy'

[env_var.PROMPT_HOST]
style = "bg:red fg:text"
format = '[ 󰒋 $env_value ]($style)[](fg:red bg:seg1)'

[directory]
style = "bg:seg1 fg:text"
format = "[ $path ]($style)"
truncation_length = 3
truncation_symbol = "…/"

[directory.substitutions]
"Documents" = "󰈙 "
"Downloads" = " "
"Music" = "󰝚 "
"Pictures" = " "
"Projects" = "󰲋 "

[git_branch]
symbol = ""
style = "bg:seg2"
format = '[[ $symbol $branch ](fg:text bg:seg2)]($style)'

[git_status]
style = "bg:seg2"
format = '[[($all_status$ahead_behind )](fg:text bg:seg2)]($style)'

[nodejs]
symbol = ""
style = "bg:seg3"
format = '[[ $symbol( $version) ](fg:text bg:seg3)]($style)'

[c]
symbol = " "
style = "bg:seg3"
format = '[[ $symbol( $version) ](fg:text bg:seg3)]($style)'

[rust]
symbol = ""
style = "bg:seg3"
format = '[[ $symbol( $version) ](fg:text bg:seg3)]($style)'

[golang]
symbol = ""
style = "bg:seg3"
format = '[[ $symbol( $version) ](fg:text bg:seg3)]($style)'

[php]
symbol = ""
style = "bg:seg3"
format = '[[ $symbol( $version) ](fg:text bg:seg3)]($style)'

[java]
symbol = " "
style = "bg:seg3"
format = '[[ $symbol( $version) ](fg:text bg:seg3)]($style)'

[kotlin]
symbol = ""
style = "bg:seg3"
format = '[[ $symbol( $version) ](fg:text bg:seg3)]($style)'

[haskell]
symbol = ""
style = "bg:seg3"
format = '[[ $symbol( $version) ](fg:text bg:seg3)]($style)'

[python]
symbol = ""
style = "bg:seg3"
format = '[[ $symbol( $version)(\(#$virtualenv\)) ](fg:text bg:seg3)]($style)'

[line_break]
disabled = true

[character]
disabled = false
success_symbol = '[❯](bold fg:accent)'
error_symbol = '[❯](bold fg:red)'
vimcmd_symbol = '[❮](bold fg:accent)'
vimcmd_replace_one_symbol = '[❮](bold fg:accent)'
vimcmd_replace_symbol = '[❮](bold fg:accent)'
vimcmd_visual_symbol = '[❮](bold fg:yellow)'

# Filled in from the current Omarchy theme by omarchy-theme-set-templates.
# The segments step from the accent (the window border colour) towards the
# foreground, like the Mac's jade, leaf and pine.
[palettes.omarchy]
accent = "{{ accent }}"
seg1 = "{{ accent }}"
seg2 = "{{ mix accent foreground 30% }}"
seg3 = "{{ mix accent foreground 55% }}"
text = "{{ background }}"
red = "{{ red }}"
yellow = "{{ yellow }}"
