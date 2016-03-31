autoload -U match-words-by-style

function smart-backward-kill-word() {
    local precise
    zstyle -g precise ':zle:smart-kill-word' precise

    local from_cursor_to_left=(${(z)LBUFFER})

    local number_of_words_left=${#from_cursor_to_left}

    local word_part_before_cursor="${from_cursor_to_left[-1]}"
    local word_under_cursor=${${(z)BUFFER}[$number_of_words_left]}

    local inside_shell_word=$(((
        ${#word_under_cursor} > ${#word_part_before_cursor}
    )))

    local match_style="shell"
    if [ "$inside_shell_word" = "1" -o "$precise" = "always" ]; then
        if [[ "${word_part_before_cursor[1]}" =~ "['\"([]" ]]; then
            if (( ${#${word_part_before_cursor// /}} > 1 )); then
                match_style="normal"
            fi
        fi
    fi

    case "$match_style"; in
        normal)
            match-words-by-style -w normal -C "['\"([]"
            ;;

        shell)
            match-words-by-style -w shell-subword -r '/'
            ;;
    esac

    LBUFFER=${matched_words[1]}
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
        if [[ "${word_part_before_cursor[1]}" =~ "['\"([]" ]]; then
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
