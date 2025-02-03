local g = import 'g.libsonnet';

local row = g.panel.row;

local panels = import './panels.libsonnet';
local variables = import './variables.libsonnet';
local queries = import './queries.promql.thanos.libsonnet';
local cached_jobs = queries.Xodus_entity_store_metrics.cached_jobs;

g.dashboard.new('Xodus storage: 🛠 Execute → ✳️ Started | ⛔️ Not Started')
+ g.dashboard.withDescription(|||
  YouTrack Xodus entity store metrics (DB):
  ⚙️ Cached Jobs →
  ✅ Queued →
  (🟡 Consistent | 🟠 Non Consistent) →
  🛠️ Execute →
  ✳️ Started | ⛔️ Not Started
|||)
+ g.dashboard.withUid('xodus_storage_execute')
+ g.dashboard.withTags([
    'YouTrack Server',
    'Xodus',
    'Xodus Entity',
    '🛠️ Execute',
    '✳️ Started',
    '⛔️ Not Started'
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
      row.new('ℹ️ Info: 🛠 Execute → ✳️ Started | ⛔️ Not Started'),
//      + row.withCollapsed(true)
//      + row.withPanels([
      panels.texts.image('https://polarnik.github.io/youtrack-monitoring/Execute.png'),
//      ]),

      row.new('🛠 Execute → ✳️ Started | ⛔️ Not Started'),
      // 🛠 Execute
      panels.combo.stat.a_bigger_value_is_better(
        '🛠 Execute',
        queries.diff(cached_jobs.Execute.Execute_per_sec)
      ),
      panels.combo.timeSeries.current_vs_prev(
        '🛠 Execute (per 1 second)',
        queries.start_prev_current_diff(cached_jobs.Execute.Execute_per_sec),
        cached_jobs.Execute.Execute_per_sec.unit
      ),

      // ✳️ Started
      panels.combo.stat.a_bigger_value_is_better(
        '✳️ Started',
        queries.diff(cached_jobs.Execute.Started_per_sec)
      )
        + panels.link_panel(
          [{title:'✳️ Started', UID: 'xodus_storage_started'}])
        + g.panel.stat.standardOptions.withLinksMixin(panels.one_link('✳️ Started', 'xodus_storage_started'))
      ,
      panels.combo.timeSeries.current_vs_prev(
        '✳️ Started (per 1 second)',
        queries.start_prev_current_diff(cached_jobs.Execute.Started_per_sec),
        cached_jobs.Execute.Started_per_sec.unit
      )
      + panels.link_panel(
        [{title:'✳️ Started', UID: 'xodus_storage_started'}])
        ,

      // ⛔️ Not Started
      panels.combo.stat.a_bigger_value_is_a_problem(
        '⛔️ Not Started',
        queries.diff(cached_jobs.Execute.Not_Started_per_sec)
      ),
      panels.combo.timeSeries.current_vs_prev(
        '⛔️ Not Started (per 1 second)',
        queries.start_prev_current_diff(cached_jobs.Execute.Not_Started_per_sec),
        cached_jobs.Execute.Not_Started_per_sec.unit
      ),

      // ✳️ % Started
      panels.combo.stat.a_bigger_value_is_better(
        '✳️ % Started',
        queries.diff(cached_jobs.Execute.Started_percent)
      )
              + panels.link_panel(
                [{title:'✳️ Started', UID: 'xodus_storage_started'}])
              + g.panel.stat.standardOptions.withLinksMixin(panels.one_link('✳️ Started', 'xodus_storage_started'))
      ,
      panels.combo.timeSeries.current_vs_prev(
        '✳️ % Started (100 * ✳️ Started / 🛠 Execute)',
        queries.start_prev_current_diff(cached_jobs.Execute.Started_percent),
        cached_jobs.Execute.Started_percent.unit
      )
            + panels.link_panel(
              [{title:'✳️ Started', UID: 'xodus_storage_started'}])
      ,

      // ⛔️ % Not Started
      panels.combo.stat.a_bigger_value_is_a_problem(
        '⛔️ % Not Started',
        queries.diff(cached_jobs.Execute.Not_Started_percent)
      ),
      panels.combo.timeSeries.current_vs_prev(
        '⛔️ % Not Started (100 * ⛔️ Not Started / 🛠 Execute)',
        queries.start_prev_current_diff(cached_jobs.Execute.Not_Started_percent),
        cached_jobs.Execute.Not_Started_percent.unit
      ),

    ], 20, 7, 0
  )
)
