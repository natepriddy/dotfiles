# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /usr/local/share/powerlevel10k/powerlevel10k.zsh-theme

alias reload-zsh="source ~/.zshrc"
alias edit-zsh="nvim ~/.zshrc"

# Path to your oh-my-zsh installation.
export ZSH="/Users/npriddy/.oh-my-zsh"

export NVM_DIR="$HOME/.nvm"
  [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# source $HOME/dotfiles/.config/zshrc/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git docker-compose node zsh-autosuggestions zsh-syntax-highlighting web-search)

eval "$(starship init zsh)"
source $ZSH/oh-my-zsh.sh
source $(brew --prefix nvm)/nvm.sh

export SE_HOME="/Users/npriddy/Documents/git/student-experience-monorepo"
export FLAGS_GETOPT_CMD="$(brew --prefix gnu-getopt)/bin/getopt"
export PATH="/usr/local/opt/openjdk/bin:$PATH"
export PATH="/usr/local/opt/postgresql@15/bin:$PATH"
export PATH="/usr/local/opt/openjdk@11/bin:$PATH"
export PATH="/usr/local/opt/openjdk/bin:$PATH"

setopt complete_aliases

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# ----- Bat (better cat) -----

export BAT_THEME=tokyonight_night

# ---- Eza (better ls) -----

alias ls="eza --icons=always"

# ---- Zoxide (better cd) ----
eval "$(zoxide init zsh)"

alias cd="z"

#alias ld='eza -lD'
#alias  lf='eza -lf --color=always | grep -v /'
#alias  lh='eza -dl .* --group-directories-first'
#alias  ll='eza -al --group-directories-first'
#alias  ls='eza -alf --color=always --sort=size | grep -v /'
#alias  lt='eza -al --sort=modified'

alias home='z $HOME'
alias se-home='z $SE_HOME'
alias oauth='z $SE_HOME/meta-apps/oauth'
alias monolith='z $SE_HOME/meta-apps/scheduler-monolith'
alias nvim-config='nvim $HOME/dotfiles/.config/nvim/'


