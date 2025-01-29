local g = import 'g.libsonnet';

local row = g.panel.row;

local panels = import './panels.libsonnet';
local variables = import './variables.libsonnet';
local queries = import './queries.promql.thanos.libsonnet';
local cached_jobs = queries.Xodus_entity_store_metrics.cached_jobs;

g.dashboard.new('Xodus storage: ✳️ Started → ❎ Completed | ↩️ Retried | 🚫️ Interrupted')
+ g.dashboard.withDescription(|||
  YouTrack Xodus entity store metrics (DB):
  ⚙️ Cached Jobs →
  ✅ Queued →
  (🟡 Consistent | 🟠 Non Consistent) →
  🛠 Execute →
  ✳️ Started →
  ❎ Completed | ↩️ Retried | 🚫️ Interrupted
|||)
+ g.dashboard.withUid('xodus_storage_started')
+ g.dashboard.withTags([
    'YouTrack Server',
    'Xodus',
    'Xodus Entity',
    '✳️ Started',
    '❎ Completed',
    '↩️ Retried',
    '🚫️ Interrupted'
    ])
+ panels.links(['YouTrack Server', 'Xodus', 'Xodus Entity'])
+ g.dashboard.graphTooltip.withSharedCrosshair()
+ g.dashboard.withVariables([
  variables.datasource,
  variables.offset,
  variables.diff_interval,
  variables.service,
  variables.environment,
  variables.instance,
  variables.app_start,
])
+ g.dashboard.withPanels(
  g.util.grid.wrapPanels(
    [
      // Version
      row.new('Version'),
      panels.texts.version,
      panels.timeseries.version('Version', queries.version),

      // ⚙️ Cached Jobs → Queued | Non Queued
      row.new('ℹ️ Info: ⚙️ Cached Jobs → ✅ Queued → (🟡|🟠) → 🛠️ Execute → ✳️ Started → ❎ Completed | ↩️ Retried | 🚫️ Interrupted')
      + row.withCollapsed(true)
      + row.withPanels([
      panels.texts.image('https://polarnik.github.io/youtrack-monitoring/Execute-Started.png')
      ]),

      row.new('⚙️ Cached Jobs → ✅ Queued → (🟡|🟠) → 🛠️ Execute → ✳️ Started → ❎ Completed | ↩️ Retried | 🚫️ Interrupted'),
      // ✳️ Started
      panels.combo.stat.a_bigger_value_is_better(
        '✳️ Started',
        queries.diff(cached_jobs.Started.Started_per_sec)
      ),
      panels.combo.timeSeries.current_vs_prev(
        '✳️ Started (per 1 second)',
        queries.start_prev_current_diff(cached_jobs.Started.Started_per_sec),
        cached_jobs.Started.Started_per_sec.unit
      ),

      // ✳️ Completed
      panels.combo.stat.a_bigger_value_is_better(
        '✳️ Completed',
        queries.diff(cached_jobs.Started.Completed_per_sec)
      ),
      panels.combo.timeSeries.current_vs_prev(
        '✳️ Completed (per 1 second)',
        queries.start_prev_current_diff(cached_jobs.Started.Completed_per_sec),
        cached_jobs.Started.Completed_per_sec.unit
      ),

      // ↩️ Retried
      panels.combo.stat.a_bigger_value_is_a_problem(
        '↩️ Retried',
        queries.diff(cached_jobs.Started.Retried_per_sec)
      ),
      panels.combo.timeSeries.current_vs_prev(
        '↩️ Retried (per 1 second)',
        queries.start_prev_current_diff(cached_jobs.Started.Retried_per_sec),
        cached_jobs.Started.Retried_per_sec.unit
      ),

      // 🚫️ Interrupted
      panels.combo.stat.a_bigger_value_is_a_problem(
        '🚫️ Interrupted',
        queries.diff(cached_jobs.Started.Interrupted_per_sec)
      ),
      panels.combo.timeSeries.current_vs_prev(
        '🚫️ Interrupted (per 1 second)',
        queries.start_prev_current_diff(cached_jobs.Started.Interrupted_per_sec),
        cached_jobs.Started.Interrupted_per_sec.unit
      ),

      // ✳️ % Completed
      panels.combo.stat.a_bigger_value_is_better(
        '✳️ % Completed',
        queries.diff(cached_jobs.Started.Completed_percent)
      ),
      panels.combo.timeSeries.current_vs_prev(
        '✳️ % Completed (100 * ✳️ Completed / ✳️ Started)',
        queries.start_prev_current_diff(cached_jobs.Started.Completed_percent),
        cached_jobs.Started.Completed_percent.unit
      ),

      // ↩️ % Retried
      panels.combo.stat.a_bigger_value_is_a_problem(
        '↩️ % Retried',
        queries.diff(cached_jobs.Started.Retried_percent)
      ),
      panels.combo.timeSeries.current_vs_prev(
        '↩️ % Retried (100 * ↩️ Retried / ✳️ Started)',
        queries.start_prev_current_diff(cached_jobs.Started.Retried_percent),
        cached_jobs.Started.Retried_percent.unit
      ),

      // 🚫️ % Interrupted
      panels.combo.stat.a_bigger_value_is_a_problem(
        '🚫️ % Interrupted',
        queries.diff(cached_jobs.Started.Interrupted_percent)
      ),
      panels.combo.timeSeries.current_vs_prev(
        '🚫️ % Interrupted (100 * 🚫️ Interrupted / ✳️ Started)',
        queries.start_prev_current_diff(cached_jobs.Started.Interrupted_percent),
        cached_jobs.Started.Interrupted_percent.unit
      ),

    ], 20, 7, 0
  )
)
