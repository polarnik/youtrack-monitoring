#!/usr/bin/env sh

if [ ! -f ./tools/sjsonnet.jar ]; then
  echo "💤 Download sjsonnet"
  curl --output ./tools/sjsonnet.jar \
  https://github.com/databricks/sjsonnet/releases/download/0.4.14/sjsonnet-0.4.14.jar
  echo "✅  Download sjsonnet complete"

  chmod +x ./tools/sjsonnet.jar
fi

echo "💤 youtrack_Workflows"
./tools/sjsonnet.jar \
--strict --strict-import-syntax --fatal-warnings --throw-error-for-invalid-sets \
--indent 4 --no-duplicate-keys-in-comprehension \
--output-file ./dashboards/generated/youtrack_Workflows.json \
-J vendor \
youtrack_Workflows.jsonnet
echo "✅  youtrack_Workflows"

echo "💤 youtrack_process"
./tools/sjsonnet.jar \
--strict --strict-import-syntax --fatal-warnings --throw-error-for-invalid-sets \
--indent 4 --no-duplicate-keys-in-comprehension \
--output-file ./dashboards/generated/youtrack_process.json \
-J vendor \
youtrack_process.jsonnet
echo "✅  youtrack_process"

echo "💤 youtrack_XodusStorage_CachedJobs"
./tools/sjsonnet.jar \
--strict --strict-import-syntax --fatal-warnings --throw-error-for-invalid-sets \
--indent 4 --no-duplicate-keys-in-comprehension  \
--output-file ./dashboards/generated/youtrack_XodusStorage_CachedJobs.json \
-J vendor \
youtrack_XodusStorage_CachedJobs.jsonnet
echo "✅  youtrack_XodusStorage_CachedJobs"

echo "💤 youtrack_XodusStorage_CachedJobs_Queued"
./tools/sjsonnet.jar \
--strict --strict-import-syntax --fatal-warnings --throw-error-for-invalid-sets \
--indent 4 --no-duplicate-keys-in-comprehension \
--output-file ./dashboards/generated/youtrack_XodusStorage_CachedJobs_Queued.json \
-J vendor \
youtrack_XodusStorage_CachedJobs_Queued.jsonnet
echo "✅  youtrack_XodusStorage_CachedJobs_Queued"


echo "💤 youtrack_XodusStorage_CachedJobs_Queued_Execute"
./tools/sjsonnet.jar \
--strict --strict-import-syntax --fatal-warnings --throw-error-for-invalid-sets \
--indent 4 --no-duplicate-keys-in-comprehension \
--output-file ./dashboards/generated/youtrack_XodusStorage_CachedJobs_Queued_Execute.json \
-J vendor \
youtrack_XodusStorage_CachedJobs_Queued_Execute.jsonnet
echo "✅  youtrack_XodusStorage_CachedJobs_Queued_Execute"


echo "💤 youtrack_XodusStorage_CachedJobs_Queued_Execute_Started"
./tools/sjsonnet.jar \
--strict --strict-import-syntax --fatal-warnings --throw-error-for-invalid-sets \
--indent 4 --no-duplicate-keys-in-comprehension \
--output-file ./dashboards/generated/youtrack_XodusStorage_CachedJobs_Queued_Execute_Started.json \
-J vendor \
youtrack_XodusStorage_CachedJobs_Queued_Execute_Started.jsonnet
echo "✅  youtrack_XodusStorage_CachedJobs_Queued_Execute_Started"


echo "💤 youtrack_XodusStorage_CachedJobs_Queued_Execute_Started_Retried"
./tools/sjsonnet.jar \
--strict --strict-import-syntax --fatal-warnings --throw-error-for-invalid-sets \
--indent 4 --no-duplicate-keys-in-comprehension \
--output-file ./dashboards/generated/youtrack_XodusStorage_CachedJobs_Queued_Execute_Started_Retried.json \
-J vendor \
youtrack_XodusStorage_CachedJobs_Queued_Execute_Started_Retried.jsonnet
echo "✅  youtrack_XodusStorage_CachedJobs_Queued_Execute_Started_Retried"


echo "💤 youtrack_XodusStorage_CachedJobs_Queued_Execute_Started_Interrupted"
./tools/sjsonnet.jar \
--strict --strict-import-syntax --fatal-warnings --throw-error-for-invalid-sets \
--indent 4 --no-duplicate-keys-in-comprehension \
--output-file ./dashboards/generated/youtrack_XodusStorage_CachedJobs_Queued_Execute_Started_Interrupted.json \
-J vendor \
youtrack_XodusStorage_CachedJobs_Queued_Execute_Started_Interrupted.jsonnet
echo "✅  youtrack_XodusStorage_CachedJobs_Queued_Execute_Started_Interrupted"


echo "💤 youtrack_HubIntegration"
./tools/sjsonnet.jar \
--strict --strict-import-syntax --fatal-warnings --throw-error-for-invalid-sets \
--indent 4 --no-duplicate-keys-in-comprehension \
--output-file ./dashboards/generated/youtrack_HubIntegration.json \
-J vendor \
youtrack_HubIntegration.jsonnet
echo "✅  youtrack_HubIntegration"

echo "💤 youtrack_Workflow_details"
./tools/sjsonnet.jar \
--strict --strict-import-syntax --fatal-warnings --throw-error-for-invalid-sets \
--indent 4 --no-duplicate-keys-in-comprehension \
--output-file ./dashboards/generated/youtrack_Workflow_details.json \
-J vendor \
youtrack_Workflow_details.jsonnet
echo "✅  youtrack_Workflow_details"

