#!/usr/bin/env sh

echo "💤 youtrack_process"
./sjsonnet.jar \
--strict --strict-import-syntax --fatal-warnings --throw-error-for-invalid-sets \
--indent 4 --no-duplicate-keys-in-comprehension \
--output-file youtrack_process.json \
-J vendor \
youtrack_process.jsonnet
echo "✅  youtrack_process"

echo "💤 youtrack_XodusStorage_CachedJobs"
./sjsonnet.jar \
--strict --strict-import-syntax --fatal-warnings --throw-error-for-invalid-sets \
--indent 4 --no-duplicate-keys-in-comprehension  \
--output-file youtrack_XodusStorage_CachedJobs.json \
-J vendor \
youtrack_XodusStorage_CachedJobs.jsonnet
echo "✅  youtrack_XodusStorage_CachedJobs"

echo "💤 youtrack_XodusStorage_CachedJobs_Queued"
./sjsonnet.jar \
--strict --strict-import-syntax --fatal-warnings --throw-error-for-invalid-sets \
--indent 4 --no-duplicate-keys-in-comprehension \
--output-file youtrack_XodusStorage_CachedJobs_Queued.json \
-J vendor \
youtrack_XodusStorage_CachedJobs_Queued.jsonnet
echo "✅  youtrack_XodusStorage_CachedJobs_Queued"
