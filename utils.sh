char_lower() {
    case "$1" in
        [A-Z])
        n=$(printf "%d" "'$1")
        n=$((n+32))
        printf \\$(printf "%o" "$n")
        ;;
        *)
        printf "%s" "$1"
        ;;
    esac
}

char_upper() {
    case "$1" in
        [a-z])
        n=$(printf "%d" "'$1")
        n=$((n-32))
        printf \\$(printf "%o" "$n")
        ;;
        *)
        printf "%s" "$1"
        ;;
    esac
}
str_lower() {
    word=$1
    for((i=0;i<${#word};i++))
    do
        ch="${word:$i:1}"
        char_lower "$ch"
    done
}

str_upper() {
    word=$1
    for((i=0;i<${#word};i++))
    do
        ch="${word:$i:1}"
        char_upper "$ch"
    done
}

# var=$(str_lower "Hello Mister")
# echo $var

# var=$(str_upper "Hello Mister")
# echo $var
