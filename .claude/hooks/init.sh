readonly PROJECT_TMP_NAME=`echo "$PWD" | tr / -`

dotnet() {
  case "$1" in
    build|test|run|publish)
      command dotnet "$@" \
        /maxcpucount:1 \
        /p:EnableSourceControlManagerQueries=false \
        /p:ContinuousIntegrationBuild=false \
        /p:EnableSourceLink=false \
        /p:PublishRepositoryUrl=false \
        /p:EmbedUntrackedSources=false \
        /p:UseArtifactsOutput=true \
        /p:ArtifactsPath="$TMPDIR/$PROJECT_TMP_NAME"
      ;;
    *)
      command dotnet "$@"
      ;;
  esac
}
