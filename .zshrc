# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="eastwood"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
alias zshconfig="nano ~/.zshrc"
alias zshcode="code ~/.zshrc"
alias zshsource="source ~/.zshrc"
alias cheatsheet="wslview /mnt/c/Users/$USER/CheatSheet/index.html"
alias publish="~/scripts/publish.sh"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Custom config
function gohome() {
    cd ~
    echo -e "\e[32mNow in Linux home:\e[0m $(pwd)"
}

function exit() { 
    cd /mnt/c/Users/$USER 
}

function rebuildhistory() {
    mv ~/.zsh_history ~/.zsh_history_bad
    strings ~/.zsh_history_bad > ~/.zsh_history
    fc -R ~/.zsh_history
    echo "History rebuilt successfully!"
}
function aliases() {
    keys=("gohome - Go to Linux home" "gowindows - Go to Windows home" "commands - Open commands cheatsheet" "zshcode - code ~/.zshrc" "zshconfig - nano ~/.zshrc" "zshsource - source ~/.zshrc")

    echo ""
    local i=1
    for key in "${keys[@]}"; do
        echo -e "\e[33m${i}.\e[0m $key"
        ((i++))
    done
	echo ""
}

function typer() {
    text="$1"
    speed=${2:-0.01}
    for ((i=0; i<${#text}; i++ )); do
	printf "%s" "${text:$i:1}"
	sleep $speed
    done
    printf "\n"
}
function toiletMsg() {
    toilet -f slant -F gay UwU - WSL
}

function gm_message() {
clear
toiletMsg
echo -e "\e[33m"
typer "Initiating WSL..."
echo -e "\e[37m"
typer "$(date +"%A, %B %d. %Y")"
echo ""
typer "$(echo -e "\e[37m$(date +"[%H:%M]")\e[32m GM, eirik!\e[0m")"
#typer "$(echo -e "\e[37m$(date +"[%H:%M]")\e[32m $ \e[33mcommands\e[0m - Command line cheatsheet!\e[0m")"
typer "$(echo -e "\e[37m$(date +"[%H:%M]")\e[32m $ \e[33maliases\e[0m - View aliases!\e[0m")"
echo ""
}
gm_message

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# pnpm
export PNPM_HOME="/home/eirik/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
