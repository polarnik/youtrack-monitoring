local g = import 'g.libsonnet';

local row = g.panel.row;

local panels = import './panels.libsonnet';
local variables = import './variables.libsonnet';
local queries = import './queries.promql.thanos.libsonnet';
local cached_jobs = queries.Xodus_entity_store_metrics.cached_jobs;

g.dashboard.new('Xodus storage: 🚫️ Interrupted → ⌛️ Obsolete | ⏰ Overdue')
+ g.dashboard.withDescription(|||
  YouTrack Xodus entity store metrics (DB):
  ⚙️ Cached Jobs →
  ✅ Queued →
  (🟡 Consistent | 🟠 Non Consistent) →
  🛠 Execute →
  ✳️ Started →
  🚫️ Interrupted →
  ⌛️ Obsolete | ⏰ Overdue
|||)
+ g.dashboard.withUid('xodus_storage_interrupted')
+ g.dashboard.withTags([
    'YouTrack Server',
    'Xodus',
    'Xodus Entity',
    '🚫️ Interrupted',
    '⌛️ Obsolete',
    '⏰ Overdue'
    ])
+ panels.links(['YouTrack Server', 'Xodus', 'Xodus Entity'])
+ g.dashboard.graphTooltip.withSharedCrosshair()
+ g.dashboard.withVariables([
  variables.datasource,
  variables.offset,
  variables.diff_interval,
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
      row.new('ℹ️ Info: 🚫️ Interrupted → ⌛️ Obsolete | ⏰ Overdue'),
//      + row.withCollapsed(true)
//      + row.withPanels([
      panels.texts.image('https://polarnik.github.io/youtrack-monitoring/Execute-Started-Interrupted.png')
        + {
          "gridPos": {
            "h": 8,
            "w": 12,
            "x": 0,
            "y": 9
          }
        },
      panels.diagram.base(),
//      ]),
    /*
    %%{ init: { 'flowchart': { 'curve': 'monotoneX' } } }%%
    flowchart LR
        A(⚙️ Cached Jobs) ==> B(✅ Queued)
        A(⚙️ Cached Jobs) -.-> C(❌ Non Queued)
        B ==> D(🟡 Consistent)
        B ==> E(🟠 Non Consistent)
        D ==> F(🛠 Execute)
        E ==> F
        F ==> G(✳️ Started)
        F -.-> H(⛔️ Not Started)
        G -.-> I(↩️ Retried)
        G ==> J(❎ Completed)
        G -.-> K(🚫️ Interrupted)
        I -.-> L(🟡 Consistent)
        I -.-> M(🟠 Non Consistent)
        K -.-> N(⌛️ Obsolete)
        K -.-> O(⏰ Overdue)
    */
      row.new('🚫️ Interrupted → ⌛️ Obsolete | ⏰ Overdue'),
      // 🚫️ Interrupted
      panels.combo.stat.a_bigger_value_is_a_problem(
        '🚫️ Interrupted',
        queries.diff(cached_jobs.Interrupted.Interrupted_per_sec)
      ),
      panels.combo.timeSeries.current_vs_prev(
        '🚫️ Interrupted (per 1 second)',
        queries.start_prev_current_diff(cached_jobs.Interrupted.Interrupted_per_sec),
        cached_jobs.Interrupted.Interrupted_per_sec.unit
      ),

      // ⌛️ Obsolete
      panels.combo.stat.a_bigger_value_is_a_problem(
        '⌛️ Obsolete',
        queries.diff(cached_jobs.Interrupted.Obsolete_per_sec)
      ),
      panels.combo.timeSeries.current_vs_prev(
        '⌛️ Obsolete (per 1 second)',
        queries.start_prev_current_diff(cached_jobs.Interrupted.Obsolete_per_sec),
        cached_jobs.Interrupted.Obsolete_per_sec.unit
      ),

      // ⏰ Overdue
      panels.combo.stat.a_bigger_value_is_a_problem(
        '⏰ Overdue',
        queries.diff(cached_jobs.Interrupted.Overdue_per_sec)
      ),
      panels.combo.timeSeries.current_vs_prev(
        '⏰ Overdue (per 1 second)',
        queries.start_prev_current_diff(cached_jobs.Interrupted.Overdue_per_sec),
        cached_jobs.Interrupted.Overdue_per_sec.unit
      ),

      // ⌛️ % Obsolete
      panels.combo.stat.a_bigger_value_is_a_problem(
        '⌛️ % Obsolete',
        queries.diff(cached_jobs.Interrupted.Obsolete_percent)
      ),
      panels.combo.timeSeries.current_vs_prev(
        '⌛️ % Obsolete (100 * ⌛️ Obsolete / 🚫️ Interrupted)',
        queries.start_prev_current_diff(cached_jobs.Interrupted.Obsolete_percent),
        cached_jobs.Interrupted.Obsolete_percent.unit
      ),

      // ⏰ % Overdue
      panels.combo.stat.a_bigger_value_is_a_problem(
        '⏰ % Overdue',
        queries.diff(cached_jobs.Interrupted.Overdue_percent)
      ),
      panels.combo.timeSeries.current_vs_prev(
        '⏰ % Overdue (100 * ⏰ Overdue / 🚫️ Interrupted)',
        queries.start_prev_current_diff(cached_jobs.Interrupted.Overdue_percent),
        cached_jobs.Interrupted.Overdue_percent.unit
      ),
    ], 20, 7, 0
  )
)
