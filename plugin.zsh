autoload -U match-words-by-style

function smart-backward-kill-word() {
    local precise
    local keep_slash
    zstyle -g precise ':zle:smart-kill-word' precise
    zstyle -g keep_slash ':zle:smart-kill-word' keep-slash

    local from_cursor_to_left=(${(z)LBUFFER})

    local number_of_words_left=${#from_cursor_to_left}

    local word_part_before_cursor="${from_cursor_to_left[-1]}"
    local word_under_cursor=${${(z)BUFFER}[$number_of_words_left]}

    local inside_shell_word=$(((
        ${#word_under_cursor} > ${#word_part_before_cursor}
    )))

    local match_style="shell"
    if [ "$inside_shell_word" = "1" -o "$precise" = "always" ]; then
        if [[ "${word_part_before_cursor[1]}" =~ "['\"([<]" ]]; then
            if (( ${#${word_part_before_cursor// /}} > 1 )); then
                match_style="normal"
            fi
        fi
    fi

    exec 2>>/tmp/debug

    case "$match_style"; in
        normal)
            match-words-by-style -w normal -C "['\"([]"
            ;;

        shell)
            -smart-kill-word-match-slash-aware ${keep_slash:+true}
            ;;
    esac

    LBUFFER=${matched_words[1]}
}

function -smart-kill-word-match-slash-aware() {
    local keep_slash=${1:-false}

    match-words-by-style -w shell-subword
    if [ "${matched_words[2]}" = "/" ]; then
        return
    fi

    if $keep_slash && [ "${BUFFER[$CURSOR]}" = "/" ]; then
        BUFFER[$CURSOR]=""
        if (( $CURSOR < ${#BUFFER[@]}-1 )); then
            CURSOR=$((CURSOR-1))
        fi
    fi

    match-words-by-style -w shell-subword -r '/'

    if $keep_slash && [ "${matched_words[2]:0:1}" = "/" ]; then
        matched_words[1]=${matched_words[1]}"/"
    fi
}

zle -N smart-backward-kill-word

function smart-forward-kill-word() {
    local precise
    zstyle -g precise ':zle:smart-kill-word' precise

    local from_cursor_to_left=(${(z)LBUFFER})
    local from_cursor_to_right=(${(z)RBUFFER})

    local number_of_words_left=${#from_cursor_to_left}

    local word_part_before_cursor="${from_cursor_to_left[-1]}"
    local word_under_cursor=${${(z)BUFFER}[$number_of_words_left]}
    local word_part_after_cursor="${word_under_cursor:((${#word_under_cursor} \
        - ${#word_part_before_cursor} - 1))}"

    local inside_shell_word=$(((
        ${#word_under_cursor} > ${#word_part_before_cursor}
    )))

    local match_style="shell"
    if [ "$inside_shell_word" = "1" -o "$precise" = "always" ]; then
        if [[ "${word_part_before_cursor[1]}" =~ "['\"([<]" ]]; then
            if (( ${#${word_part_after_cursor// /}} > 1 )); then
                match_style="normal"
            fi
        fi
    fi

    case "$match_style"; in
        normal)
            match-words-by-style -w normal -C "['\")\]]"
            ;;

        shell)
            match-words-by-style -w shell-subword -r '/'
            ;;
    esac

    RBUFFER=${matched_words[-1]}
}

zle -N smart-forward-kill-word
