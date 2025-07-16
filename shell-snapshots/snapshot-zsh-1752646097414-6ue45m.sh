# Snapshot file
# Unset all aliases to avoid conflicts with functions
unalias -a 2>/dev/null || true
# Functions
bashcompinit () {
	# undefined
	builtin autoload -XUz
}
command_not_found_handler () {
	if [[ "$1" != "mise" && "$1" != "mise-"* ]] && /opt/homebrew/bin/mise hook-not-found -s zsh -- "$1"
	then
		_mise_hook
		"$@"
	elif [ -n "$(declare -f _command_not_found_handler)" ]
	then
		_command_not_found_handler "$@"
	else
		echo "zsh: command not found: $1" >&2
		return 127
	fi
}
compaudit () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
compdef () {
	local opt autol type func delete eval new i ret=0 cmd svc 
	local -a match mbegin mend
	emulate -L zsh
	setopt extendedglob
	if (( ! $# ))
	then
		print -u2 "$0: I need arguments"
		return 1
	fi
	while getopts "anpPkKde" opt
	do
		case "$opt" in
			(a) autol=yes  ;;
			(n) new=yes  ;;
			([pPkK]) if [[ -n "$type" ]]
				then
					print -u2 "$0: type already set to $type"
					return 1
				fi
				if [[ "$opt" = p ]]
				then
					type=pattern 
				elif [[ "$opt" = P ]]
				then
					type=postpattern 
				elif [[ "$opt" = K ]]
				then
					type=widgetkey 
				else
					type=key 
				fi ;;
			(d) delete=yes  ;;
			(e) eval=yes  ;;
		esac
	done
	shift OPTIND-1
	if (( ! $# ))
	then
		print -u2 "$0: I need arguments"
		return 1
	fi
	if [[ -z "$delete" ]]
	then
		if [[ -z "$eval" ]] && [[ "$1" = *\=* ]]
		then
			while (( $# ))
			do
				if [[ "$1" = *\=* ]]
				then
					cmd="${1%%\=*}" 
					svc="${1#*\=}" 
					func="$_comps[${_services[(r)$svc]:-$svc}]" 
					[[ -n ${_services[$svc]} ]] && svc=${_services[$svc]} 
					[[ -z "$func" ]] && func="${${_patcomps[(K)$svc][1]}:-${_postpatcomps[(K)$svc][1]}}" 
					if [[ -n "$func" ]]
					then
						_comps[$cmd]="$func" 
						_services[$cmd]="$svc" 
					else
						print -u2 "$0: unknown command or service: $svc"
						ret=1 
					fi
				else
					print -u2 "$0: invalid argument: $1"
					ret=1 
				fi
				shift
			done
			return ret
		fi
		func="$1" 
		[[ -n "$autol" ]] && autoload -rUz "$func"
		shift
		case "$type" in
			(widgetkey) while [[ -n $1 ]]
				do
					if [[ $# -lt 3 ]]
					then
						print -u2 "$0: compdef -K requires <widget> <comp-widget> <key>"
						return 1
					fi
					[[ $1 = _* ]] || 1="_$1" 
					[[ $2 = .* ]] || 2=".$2" 
					[[ $2 = .menu-select ]] && zmodload -i zsh/complist
					zle -C "$1" "$2" "$func"
					if [[ -n $new ]]
					then
						bindkey "$3" | IFS=$' \t' read -A opt
						[[ $opt[-1] = undefined-key ]] && bindkey "$3" "$1"
					else
						bindkey "$3" "$1"
					fi
					shift 3
				done ;;
			(key) if [[ $# -lt 2 ]]
				then
					print -u2 "$0: missing keys"
					return 1
				fi
				if [[ $1 = .* ]]
				then
					[[ $1 = .menu-select ]] && zmodload -i zsh/complist
					zle -C "$func" "$1" "$func"
				else
					[[ $1 = menu-select ]] && zmodload -i zsh/complist
					zle -C "$func" ".$1" "$func"
				fi
				shift
				for i
				do
					if [[ -n $new ]]
					then
						bindkey "$i" | IFS=$' \t' read -A opt
						[[ $opt[-1] = undefined-key ]] || continue
					fi
					bindkey "$i" "$func"
				done ;;
			(*) while (( $# ))
				do
					if [[ "$1" = -N ]]
					then
						type=normal 
					elif [[ "$1" = -p ]]
					then
						type=pattern 
					elif [[ "$1" = -P ]]
					then
						type=postpattern 
					else
						case "$type" in
							(pattern) if [[ $1 = (#b)(*)=(*) ]]
								then
									_patcomps[$match[1]]="=$match[2]=$func" 
								else
									_patcomps[$1]="$func" 
								fi ;;
							(postpattern) if [[ $1 = (#b)(*)=(*) ]]
								then
									_postpatcomps[$match[1]]="=$match[2]=$func" 
								else
									_postpatcomps[$1]="$func" 
								fi ;;
							(*) if [[ "$1" = *\=* ]]
								then
									cmd="${1%%\=*}" 
									svc=yes 
								else
									cmd="$1" 
									svc= 
								fi
								if [[ -z "$new" || -z "${_comps[$1]}" ]]
								then
									_comps[$cmd]="$func" 
									[[ -n "$svc" ]] && _services[$cmd]="${1#*\=}" 
								fi ;;
						esac
					fi
					shift
				done ;;
		esac
	else
		case "$type" in
			(pattern) unset "_patcomps[$^@]" ;;
			(postpattern) unset "_postpatcomps[$^@]" ;;
			(key) print -u2 "$0: cannot restore key bindings"
				return 1 ;;
			(*) unset "_comps[$^@]" ;;
		esac
	fi
}
compdump () {
	# undefined
	builtin autoload -XUz
}
compgen () {
	local opts prefix suffix job OPTARG OPTIND ret=1 
	local -a name res results jids
	local -A shortopts
	emulate -L sh
	setopt kshglob noshglob braceexpand nokshautoload
	shortopts=(a alias b builtin c command d directory e export f file g group j job k keyword u user v variable) 
	while getopts "o:A:G:C:F:P:S:W:X:abcdefgjkuv" name
	do
		case $name in
			([abcdefgjkuv]) OPTARG="${shortopts[$name]}"  ;&
			(A) case $OPTARG in
					(alias) results+=("${(k)aliases[@]}")  ;;
					(arrayvar) results+=("${(k@)parameters[(R)array*]}")  ;;
					(binding) results+=("${(k)widgets[@]}")  ;;
					(builtin) results+=("${(k)builtins[@]}" "${(k)dis_builtins[@]}")  ;;
					(command) results+=("${(k)commands[@]}" "${(k)aliases[@]}" "${(k)builtins[@]}" "${(k)functions[@]}" "${(k)reswords[@]}")  ;;
					(directory) setopt bareglobqual
						results+=(${IPREFIX}${PREFIX}*${SUFFIX}${ISUFFIX}(N-/)) 
						setopt nobareglobqual ;;
					(disabled) results+=("${(k)dis_builtins[@]}")  ;;
					(enabled) results+=("${(k)builtins[@]}")  ;;
					(export) results+=("${(k)parameters[(R)*export*]}")  ;;
					(file) setopt bareglobqual
						results+=(${IPREFIX}${PREFIX}*${SUFFIX}${ISUFFIX}(N)) 
						setopt nobareglobqual ;;
					(function) results+=("${(k)functions[@]}")  ;;
					(group) emulate zsh
						_groups -U -O res
						emulate sh
						setopt kshglob noshglob braceexpand
						results+=("${res[@]}")  ;;
					(hostname) emulate zsh
						_hosts -U -O res
						emulate sh
						setopt kshglob noshglob braceexpand
						results+=("${res[@]}")  ;;
					(job) results+=("${savejobtexts[@]%% *}")  ;;
					(keyword) results+=("${(k)reswords[@]}")  ;;
					(running) jids=("${(@k)savejobstates[(R)running*]}") 
						for job in "${jids[@]}"
						do
							results+=(${savejobtexts[$job]%% *}) 
						done ;;
					(stopped) jids=("${(@k)savejobstates[(R)suspended*]}") 
						for job in "${jids[@]}"
						do
							results+=(${savejobtexts[$job]%% *}) 
						done ;;
					(setopt | shopt) results+=("${(k)options[@]}")  ;;
					(signal) results+=("SIG${^signals[@]}")  ;;
					(user) results+=("${(k)userdirs[@]}")  ;;
					(variable) results+=("${(k)parameters[@]}")  ;;
					(helptopic)  ;;
				esac ;;
			(F) COMPREPLY=() 
				local -a args
				args=("${words[0]}" "${@[-1]}" "${words[CURRENT-2]}") 
				() {
					typeset -h words
					$OPTARG "${args[@]}"
				}
				results+=("${COMPREPLY[@]}")  ;;
			(G) setopt nullglob
				results+=(${~OPTARG}) 
				unsetopt nullglob ;;
			(W) results+=(${(Q)~=OPTARG})  ;;
			(C) results+=($(eval $OPTARG))  ;;
			(P) prefix="$OPTARG"  ;;
			(S) suffix="$OPTARG"  ;;
			(X) if [[ ${OPTARG[0]} = '!' ]]
				then
					results=("${(M)results[@]:#${OPTARG#?}}") 
				else
					results=("${results[@]:#$OPTARG}") 
				fi ;;
		esac
	done
	print -l -r -- "$prefix${^results[@]}$suffix"
}
compinit () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
compinstall () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
complete () {
	emulate -L zsh
	local args void cmd print remove
	args=("$@") 
	zparseopts -D -a void o: A: G: W: C: F: P: S: X: a b c d e f g j k u v p=print r=remove
	if [[ -n $print ]]
	then
		printf 'complete %2$s %1$s\n' "${(@kv)_comps[(R)_bash*]#* }"
	elif [[ -n $remove ]]
	then
		for cmd
		do
			unset "_comps[$cmd]"
		done
	else
		compdef _bash_complete\ ${(j. .)${(q)args[1,-1-$#]}} "$@"
	fi
}
getent () {
	if [[ $1 = hosts ]]
	then
		sed 's/#.*//' /etc/$1 | grep -w $2
	elif [[ $2 = <-> ]]
	then
		grep ":$2:[^:]*$" /etc/$1
	else
		grep "^$2:" /etc/$1
	fi
}
mise () {
	local command
	command="${1:-}" 
	if [ "$#" = 0 ]
	then
		command /opt/homebrew/bin/mise
		return
	fi
	shift
	case "$command" in
		(deactivate | shell | sh) if [[ ! " $@ " =~ " --help " ]] && [[ ! " $@ " =~ " -h " ]]
			then
				eval "$(command /opt/homebrew/bin/mise "$command" "$@")"
				return $?
			fi ;;
	esac
	command /opt/homebrew/bin/mise "$command" "$@"
}
precmd () {
	if [[ -n $COMMAND_START_DATE ]]
	then
		local duration=$((SECONDS - COMMAND_START_DATE)) 
		if ((duration > 20))
		then
			local mins=$((duration / 60)) 
			local secs=$((duration % 60)) 
			osascript -e 'display notification "実行時間: '"$(printf "%02d:%02d" $mins $secs)"'" with title "FINISH: '"$LAST_COMMAND"'"'
		fi
	fi
}
preexec () {
	COMMAND_START_DATE=$SECONDS 
	LAST_COMMAND=$1 
}
# Shell Options
setopt nohashdirs
setopt login
# Aliases
alias -- android='emulator @Pixel_4_API_33 -wipe-data'
alias -- android-tablet='emulator @Pixel_C_API_33 -wipe-data'
alias -- dc='docker compose'
alias -- dce='docker compose exec'
alias -- emulator=/Users/aitaro/Library/Android/sdk/emulator/emulator
alias -- evans-account-local='zsh -c "evans --host localhost --port 38080 -r repl --package account.v1 --service Account"'
alias -- evans-backend-dev='zsh -c "evans --tls --host grpc.backend.dev.uzu.one --port 443 -r repl --package backend.v2 --service BackendService"'
alias -- evans-backend-local='zsh -c "evans --host localhost --port 18080 -r repl --package backend.v2 --service BackendService"'
alias -- evans-backend-stg='zsh -c "evans --tls --host grpc.backend.stg.uzu.one --port 443 -r repl --package backend.v2 --service BackendService"'
alias -- evans-chat-dev='zsh -c "evans --tls --host chat.dev.uzu.one --port 443 -r repl --package chat.v1 --service Chat"'
alias -- evans-mdms_jp-local='zsh -c "evans --host localhost --port 29000 -r repl --package mdms_jp.v1 --service MdmsJpService"'
alias -- evans-recommender-dev='zsh -c "evans --tls --host recommender.dev.uzu.one --port 443 -r repl --package recommender.v1 --service RecommenderService"'
alias -- evans-recommender-local='zsh -c "evans --host localhost --port 50051 -r repl --package recommender.v1 --service RecommenderService"'
alias -- evans-recommender-prd='zsh -c "evans --tls --host recommender.prd.uzu.one --port 443 -r repl --package recommender.v1 --service RecommenderService"'
alias -- evans-recommender-stg='zsh -c "evans --tls --host recommender.stg.uzu.one --port 443 -r repl --package recommender.v1 --service RecommenderService"'
alias -- flutter-ios-reset='rm -Rf ios/Pods ios/.symlinks ios/Flutter/Flutter.framework ios/Flutter/Flutter.podspec ios/Podfile.lock && (cd ios && pod repo update) && flutter clean'
alias -- flutter-macos-reset='rm -Rf macos/Pods macos/.symlinks macos/Flutter/Flutter.framework macos/Flutter/Flutter.podspec macos/Podfile.lock && (cd macos && pod repo update) && flutter clean'
alias -- generate_sql='(cd /Users/aitaro/works/uzu/ts-console && task exec-prd -- ./scripts/aitaro/generate_sql.ts)'
alias -- github-pull-request=/Users/aitaro/scripts/github-pull-request.sh
alias -- ll='ls -alF'
alias -- pr-shops=/Users/aitaro/scripts/pr-shops.sh
alias -- register-ip=/Users/aitaro/scripts/register-ip.sh
alias -- relogin='exec $SHELL -l'
alias -- run-help=man
alias -- title='wezterm cli set-tab-title'
alias -- tn='terminal-notifier -sound Pop -message "Command Finished"'
alias -- uninstall=/Users/aitaro/scripts/uninstall-cli.sh
alias -- watch-files=/Users/aitaro/scripts/watch-files.sh
alias -- which-command=whence
# Check for rg availability
if ! command -v rg >/dev/null 2>&1; then
  alias rg='/opt/homebrew/Cellar/ripgrep/14.1.1/bin/rg'
fi
export PATH=/opt/homebrew/Cellar/zplug/2.4.2/bin\:/opt/homebrew/opt/zplug/bin\:/Users/aitaro/development/google-cloud-sdk/bin\:/opt/homebrew/opt/crowdin\@3/bin\:/opt/homebrew/opt/libpq/bin\:/usr/local/go/bin\:/Users/aitaro/go/bin\:/Users/aitaro/.local/share/mise/installs/node/22.14.0/bin\:/Users/aitaro/.local/share/mise/installs/ruby/3.3.5/bin\:/Users/aitaro/.local/share/mise/installs/python/3.13.0/bin\:/Users/aitaro/.local/share/mise/installs/java/21.0.2/bin\:/opt/homebrew/bin\:/opt/homebrew/sbin\:/opt/homebrew/opt/mysql-client/bin\:/Users/aitaro/.krew/bin\:/opt/homebrew/opt/postgresql\@15/bin\:/usr/local/bin\:/System/Cryptexes/App/usr/bin\:/usr/bin\:/bin\:/usr/sbin\:/sbin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin\:/Library/Apple/usr/bin\:/Users/aitaro/.orbstack/bin\:/Users/aitaro/development/flutter/bin\:/Users/aitaro/.pub-cache/bin\:/Users/aitaro/Library/Android/sdk/platform-tools\:/Users/aitaro/.cursor/extensions/ms-python.debugpy-2025.8.0-darwin-arm64/bundled/scripts/noConfigScripts
