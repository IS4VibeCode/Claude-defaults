case "$(cat)" in
  *'"notification_type":"idle_prompt"'*) return 0 ;;
esac
printf "\07" > "$(tmux display-message -p '#{pane_tty}')"
