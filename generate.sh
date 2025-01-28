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


echo "💤 youtrack_XodusStorage_CachedJobs_Queued_Execute"
./sjsonnet.jar \
--strict --strict-import-syntax --fatal-warnings --throw-error-for-invalid-sets \
--indent 4 --no-duplicate-keys-in-comprehension \
--output-file youtrack_XodusStorage_CachedJobs_Queued_Execute.json \
-J vendor \
youtrack_XodusStorage_CachedJobs_Queued_Execute.jsonnet
echo "✅  youtrack_XodusStorage_CachedJobs_Queued_Execute"


echo "💤 youtrack_XodusStorage_CachedJobs_Queued_Execute_Started"
./sjsonnet.jar \
--strict --strict-import-syntax --fatal-warnings --throw-error-for-invalid-sets \
--indent 4 --no-duplicate-keys-in-comprehension \
--output-file youtrack_XodusStorage_CachedJobs_Queued_Execute_Started.json \
-J vendor \
youtrack_XodusStorage_CachedJobs_Queued_Execute_Started.jsonnet
echo "✅  youtrack_XodusStorage_CachedJobs_Queued_Execute_Started"


echo "💤 youtrack_XodusStorage_CachedJobs_Queued_Execute_Started_Retried"
./sjsonnet.jar \
--strict --strict-import-syntax --fatal-warnings --throw-error-for-invalid-sets \
--indent 4 --no-duplicate-keys-in-comprehension \
--output-file youtrack_XodusStorage_CachedJobs_Queued_Execute_Started_Retried.json \
-J vendor \
youtrack_XodusStorage_CachedJobs_Queued_Execute_Started_Retried.jsonnet
echo "✅  youtrack_XodusStorage_CachedJobs_Queued_Execute_Started_Retried"


echo "💤 youtrack_XodusStorage_CachedJobs_Queued_Execute_Started_Interrupted"
./sjsonnet.jar \
--strict --strict-import-syntax --fatal-warnings --throw-error-for-invalid-sets \
--indent 4 --no-duplicate-keys-in-comprehension \
--output-file youtrack_XodusStorage_CachedJobs_Queued_Execute_Started_Interrupted.json \
-J vendor \
youtrack_XodusStorage_CachedJobs_Queued_Execute_Started_Interrupted.jsonnet
echo "✅  youtrack_XodusStorage_CachedJobs_Queued_Execute_Started_Interrupted"


echo "💤 youtrack_HubIntegration"
./sjsonnet.jar \
--strict --strict-import-syntax --fatal-warnings --throw-error-for-invalid-sets \
--indent 4 --no-duplicate-keys-in-comprehension \
--output-file youtrack_HubIntegration.json \
-J vendor \
youtrack_HubIntegration.jsonnet
echo "✅  youtrack_HubIntegration"