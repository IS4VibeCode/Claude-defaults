readonly PROJECT_TMP_NAME=`echo "$PWD" | tr / -`

dotnet() {
  case "$1" in
    build|test|run|publish|restore)
      # Sandbox-safe options with isolated build directory
      command dotnet "$@" \
        /maxcpucount:1 \
        /p:EnableSourceControlManagerQueries=false \
        /p:ContinuousIntegrationBuild=false \
        /p:EnableSourceLink=false \
        /p:PublishRepositoryUrl=false \
        /p:EmbedUntrackedSources=false \
        /p:UseArtifactsOutput=true \
        /p:ArtifactsPath="${TMPDIR:-/tmp}/$PROJECT_TMP_NAME"
      ;;
    *)
      command dotnet "$@"
      ;;
  esac
}

git() {
  if repo_dir="$(command git rev-parse --show-toplevel 2>/dev/null)" && [ -e "$repo_dir/.gitmodules" ] && [ ! -f "$repo_dir/.gitmodules" ]; then
    # Exclude .gitmodules as a phantom file for this command only

    tmp_dir="${TMPDIR:-/tmp}/$PROJECT_TMP_NAME"
    mkdir -p "$tmp_dir"
    tmp_excludes="$(mktemp "$tmp_dir/.gitignore.XXXXXX")"

    echo "/.gitmodules" > "$tmp_excludes"
    if excludes="$(command git config --get core.excludesFile 2>/dev/null)"; then
      case "$excludes" in
        "~/"*) excludes="$HOME/${excludes:2}" ;;
      esac
      [ -f "$excludes" ] && cat "$excludes" >> "$tmp_excludes"
    fi

    status=0
    command git -c core.excludesFile="$tmp_excludes" "$@" || status=$?
    rm -f "$tmp_excludes"
    return $status
  fi
  command git "$@"
}
