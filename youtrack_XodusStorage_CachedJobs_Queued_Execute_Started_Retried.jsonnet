local g = import 'g.libsonnet';

local row = g.panel.row;

local panels = import './panels.libsonnet';
local variables = import './variables.libsonnet';
local queries = import './queries.promql.thanos.libsonnet';
local cached_jobs = queries.Xodus_entity_store_metrics.cached_jobs;

g.dashboard.new('Xodus storage: ↩️ Retried → 🟡 Consistent | 🟠 Non Consistent')
+ g.dashboard.withDescription(|||
  YouTrack Xodus entity store metrics (DB):
  ⚙️ Cached Jobs →
  ✅ Queued →
  (🟡 Consistent | 🟠 Non Consistent) →
  🛠 Execute →
  ✳️ Started →
  ↩️ Retried →
  🟡 Consistent | 🟠 Non Consistent
|||)
+ g.dashboard.withUid('xodus_storage_retried')
+ g.dashboard.withTags([
    'YouTrack Server',
    'Xodus',
    'Xodus Entity',
    '↩️ Retried',
    '🟡 Consistent',
    '🟠 Non Consistent'
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
      row.new('ℹ️ Info: ⚙️ Cached Jobs → ✅ Queued → (🟡|🟠) → 🛠 Execute → ✳️ Started → ↩️ Retried → 🟡 Consistent | 🟠 Non Consistent')
      + row.withCollapsed(true)
      + row.withPanels([
      panels.texts.image('https://polarnik.github.io/youtrack-monitoring/Execute-Started-Retried.png')
      ]),

      row.new('⚙️ Cached Jobs → ✅ Queued → (🟡|🟠) → 🛠 Execute → ✳️ Started → ↩️ Retried → 🟡 Consistent | 🟠 Non Consistent'),
      // ↩️ Retried
      panels.combo.stat.a_bigger_value_is_a_problem(
        '↩️ Retried',
        queries.diff(cached_jobs.Retried.Retried_per_sec)
      ),
      panels.combo.timeSeries.current_vs_prev(
        '↩️ Retried (per 1 second)',
        queries.start_prev_current_diff(cached_jobs.Retried.Retried_per_sec),
        cached_jobs.Retried.Retried_per_sec.unit
      ),

      // 🟡 Consistent
      panels.combo.stat.a_bigger_value_is_a_problem(
        '🟡 Consistent',
        queries.diff(cached_jobs.Retried.Consistent_per_sec)
      ),
      panels.combo.timeSeries.current_vs_prev(
        '🟡 Consistent (per 1 second)',
        queries.start_prev_current_diff(cached_jobs.Retried.Consistent_per_sec),
        cached_jobs.Retried.Consistent_per_sec.unit
      ),

      // 🟠 Non Consistent
      panels.combo.stat.a_bigger_value_is_a_problem(
        '🟠 Non Consistent',
        queries.diff(cached_jobs.Retried.NonConsistent_per_sec)
      ),
      panels.combo.timeSeries.current_vs_prev(
        '🟠 Non Consistent (per 1 second)',
        queries.start_prev_current_diff(cached_jobs.Retried.NonConsistent_per_sec),
        cached_jobs.Retried.NonConsistent_per_sec.unit
      ),

      // 🟡 % Consistent
      panels.combo.stat.a_bigger_value_is_a_problem(
        '🟡 % Consistent',
        queries.diff(cached_jobs.Retried.Consistent_percent)
      ),
      panels.combo.timeSeries.current_vs_prev(
        '🟡 % Consistent (100 * 🟡 Consistent / ↩️ Retried)',
        queries.start_prev_current_diff(cached_jobs.Retried.Consistent_percent),
        cached_jobs.Retried.Consistent_percent.unit
      ),

      // 🟠 % Non Consistent
      panels.combo.stat.a_bigger_value_is_a_problem(
        '🟠 % Non Consistent',
        queries.diff(cached_jobs.Retried.NonConsistent_percent)
      ),
      panels.combo.timeSeries.current_vs_prev(
        '🟠 % Non Consistent (100 * 🟠 Non Consistent / ↩️ Retried)',
        queries.start_prev_current_diff(cached_jobs.Retried.NonConsistent_percent),
        cached_jobs.Retried.NonConsistent_percent.unit
      ),
    ], 20, 7, 0
  )
)
