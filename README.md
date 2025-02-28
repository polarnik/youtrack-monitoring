# Developer environment

```bash
brew install go-jsonnet
brew install jsonnet-bundler

jb install github.com/grafana/grafonnet/gen/grafonnet-v10.4.0@main
```

# Usage

```bash
./generate.sh
```

compare:

```bash
diff <(./tools/sjsonnet.jar --strict --strict-import-syntax --fatal-warnings --throw-error-for-invalid-sets -J vendor youtrack_process.jsonnet | jq --sort-keys -r '.panels[] | select(.title=="Versions : ${instance}")') <(jq --sort-keys -r '.panels[] | select(.title=="Versions : ${instance}")' youtrack_process.original.json)
```

```bash
jsonnet -J vendor youtrack_process.jsonnet > youtrack_process.json

./tools/sjsonnet.jar --strict --strict-import-syntax --fatal-warnings --throw-error-for-invalid-sets --indent 4 --no-duplicate-keys-in-comprehension --preserve-order -J vendor youtrack_process.jsonnet > youtrack_process.json

diff <(jq --sort-keys .templating youtrack_process.json) <(jq --sort-keys .templating youtrack_process.original.json)

diff <(./tools/sjsonnet.jar --strict --strict-import-syntax --fatal-warnings --throw-error-for-invalid-sets -J vendor youtrack_process.jsonnet | jq --sort-keys -r '.panels[] | select(.title=="Versions : ${instance}")') <(jq --sort-keys -r '.panels[] | select(.title=="Versions : ${instance}")' youtrack_process.original.json)
```

# Reference

- https://github.com/grafana/grafonnet/tree/main/examples/runtimeDashboard