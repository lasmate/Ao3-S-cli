list=(one two three)
ans1=$(printf '%s\n' "${list[@]}" | fzf --color='fg:111,info:159,border:134' --border --height=10% --cycle | awk '{printf $1}')
#ans1=$(printf '%s\n' "Python" "Shell" "c/c++" "Rust" "HOME" "EXIT"| fzf  --color='fg:111,info:159,border:134' --border --height=10% | awk '{print $1}')
echo $ans1