MAX_HEIGHT=$(tput lines)
MAX_WIDTH=$(tput cols)
_STTY=$(stty -g)      # Save current terminal setup
printf "\e[?25l"      # Turn of cursor 

at_exit() {
	printf "\e[?9l"          # Turn off mouse reading
	printf "\e[?12l\e[?25h"  # Turn on cursor
	stty "$_STTY"            # reinitialize terminal settings
	tput sgr0
	clear
}

draw_box(){
    echo -e "\033[$((${1}-5));${2}f\u250C\u2500\u2500\u2510"
    echo -e "\033[$((${1}-4));${2}f\u2502\u0020\u0020\u2502"
    echo -e "\033[$((${1}-3));${2}f\u2514\u2500\u2500\u2518"
       }

game_loop() {
    local i, M, Timer, v_init, v_prev, x_prev, g
    i=$(($MAX_WIDTH-2))
    M=$MAX_HEIGHT
    TIMER=0.05
    v_init=15
    v_prev=$v_init
    x_prev=0 
    g=-9.82
    while :; do 
        read -n1 -s -t 0.0005 key
        if [[ $key = q ]] || (( $(echo "$x_prev > 0" |bc -l) )) #;[ $counter != 0]
        then
            v=$( echo "$v_prev + $g * 0.1"| bc )
            x=$( echo "$x_prev + $v * 0.1"| bc)
            M=$( echo "scale=20;$MAX_HEIGHT - $x;"| bc -l)
            printf -v M '%.0f' $M
            v_prev=$v
            x_prev=$x
        else
            M=$MAX_HEIGHT
            v_prev=$v_init
            x_prev=0 
        fi

        if [ $i -le 0 ]
        then
            i=$(($MAX_WIDTH-3))
            ((TIMER+=0.01))
        fi
        sleep $TIMER
        echo -e "\033c"
        draw_box $MAX_HEIGHT $i
        draw_box $M $(($MAX_WIDTH/2))
        ((i-=2))
    done
}
exec 2>/dev/null
game_loop
trap at_exit EXIT ERR
