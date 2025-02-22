# Git ahead and behind
# https://stackoverflow.com/a/77327346
function +vi-git-st() {
	local ahead behind
	local -a gitstatus

	git rev-parse @{upstream} >/dev/null 2>&1 || return 0
	local -a x=( $(git rev-list --left-right --count HEAD...@{upstream} ) )

	(( $x[1] )) && gitstatus+=( "%F{green}+${x[1]}%f" )  # ahead count
	(( $x[2] )) && gitstatus+=( "%F{red}-${x[2]}%f" )  # behind count

	hook_com[branch]+=${(j:/:)gitstatus}
}

# Git tracked and untracked changes
function +vi-git-changes() {
	local ahead behind
	local -a stagedCount
	local -a unstagedCount
	local -a untrackedCount

	unstagedCount=$(git ls-files -m --exclude-standard | wc -l)
	untrackedCount=$(git ls-files -o --exclude-standard | wc -l)
	stagedCount=$(git diff --cached --numstat | wc -l) # https://stackoverflow.com/a/3162492

	hook_com[misc]="%F{green}${stagedCount}S%F{yellow} ${unstagedCount}M%F{red} ${untrackedCount}U%f"
}

# VCS info
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' check-for-changes false
zstyle ':vcs_info:git*' get-revision true
zstyle ':vcs_info:git*+set-message:*' hooks git-st git-changes
zstyle ':vcs_info:git*' formats '%f(%s)-[%F{magenta}%b%f %F{yellow}#%7.7i%f]-[%m]'
zstyle ':vcs_info:git*' actionformats '%f(%s)-[%F{magenta}%b%f %F{yellow}#%7.7i%f]-[%m]-(%F{blue}%a%f)'
precmd () { vcs_info }

PROMPT=$'[%F{red}%D{%T %Z %e/%m/%Y}%f] [%F{cyan}%y%f] ${vcs_info_msg_0_}\n%F{green}%n%f@%F{magenta}%m%f %F{blue}%B%~%b%f %# '
RPROMPT='[%F{yellow}%?%f]'

TIMEFMT=$'%J\ntotal\t%*E\nuser\t%*U\nsys\t%*S\n\nCPU\t%P\nMemory\t%MkB\nI/O\t%I/%O'
