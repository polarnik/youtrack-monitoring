local g = import 'g.libsonnet';

local row = g.panel.row;

local panels = import './panels.libsonnet';
local variables = import './variables.libsonnet';
local queries = import './queries.promql.thanos.libsonnet';
local cached_jobs = queries.Xodus_entity_store_metrics.cached_jobs;

g.dashboard.new('Xodus storage: ⚙️ Cached Jobs → ✅ Queued | ❌ Non Queued')
+ g.dashboard.withDescription(|||
  YouTrack Xodus entity store metrics (DB):
  ⚙️ Cached Jobs →
  ✅ Queued | ❌ Non Queued
|||)
+ g.dashboard.withUid('xodus_storage_jobs')
+ g.dashboard.withTags([
    'YouTrack Server',
    'Xodus',
    'Xodus Entity',
    '⚙️ Cached Jobs',
    '✅ Queued',
    '❌ Non Queued'])
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
      row.new('ℹ️ Info: ⚙️ Cached Jobs → ✅ Queued | ❌ Non Queued'),
//      + row.withCollapsed(true)
//      + row.withPanels([
      panels.texts.image('https://polarnik.github.io/youtrack-monitoring/Cached.png'),
//      ]),

      row.new('⚙️ Cached Jobs → ✅ Queued | ❌ Non Queued'),
      panels.combo.stat.a_bigger_value_is_better(
        '⚙️ Cached Jobs',
        queries.diff(cached_jobs.Queued__Non_Queued.Queued__and__Non_Queued_per_sec)
      ),
      panels.combo.timeSeries.current_vs_prev(
        '⚙️ Cached Jobs (per 1 second)',
        queries.start_prev_current_diff(cached_jobs.Queued__Non_Queued.Queued__and__Non_Queued_per_sec),
        cached_jobs.Queued__Non_Queued.Queued__and__Non_Queued_per_sec.unit
      ),

      // ✅ Queued
      panels.combo.stat.a_bigger_value_is_better(
        '✅ Queued',
        queries.diff(cached_jobs.Queued__Non_Queued.Queued_jobs_per_sec)
      )
      + panels.link_panel(
        [{title:'✅ Queued', UID: 'xodus_storage_queued'}])
      + g.panel.stat.standardOptions.withLinksMixin(panels.one_link('✅ Queued', 'xodus_storage_queued'))
      ,
      panels.combo.timeSeries.current_vs_prev(
        '✅ Queued (per 1 second)',
        queries.start_prev_current_diff(cached_jobs.Queued__Non_Queued.Queued_jobs_per_sec),
        cached_jobs.Queued__Non_Queued.Queued_jobs_per_sec.unit
      )
      + panels.link_panel(
        [{title:'✅ Queued', UID: 'xodus_storage_queued'}])
      ,

      // ❌ Not Queued (per 1 second)
      panels.combo.stat.a_bigger_value_is_a_problem(
        '❌ Not Queued',
        queries.diff(cached_jobs.Queued__Non_Queued.NotQueued_jobs_per_sec)
      ),
      panels.combo.timeSeries.current_vs_prev(
        '❌ Not Queued (per 1 second)',
        queries.start_prev_current_diff(cached_jobs.Queued__Non_Queued.NotQueued_jobs_per_sec),
        cached_jobs.Queued__Non_Queued.NotQueued_jobs_per_sec.unit
      ),

      // ✅ % Queued
      panels.combo.stat.a_bigger_value_is_better(
        '✅ % Queued',
        queries.diff(cached_jobs.Queued__Non_Queued.Queued_percent)
      )
      + panels.link_panel(
        [{title:'✅ Queued', UID: 'xodus_storage_queued'}])
      + g.panel.stat.standardOptions.withLinksMixin(panels.one_link('✅ Queued', 'xodus_storage_queued'))
      ,
      panels.combo.timeSeries.current_vs_prev(
        '✅ % Queued',
        queries.start_prev_current_diff(cached_jobs.Queued__Non_Queued.Queued_percent),
        cached_jobs.Queued__Non_Queued.Queued_percent.unit
      )
      + panels.link_panel(
        [{title:'✅ Queued', UID: 'xodus_storage_queued'}])
      ,

      // ❌ % Not Queued
      panels.combo.stat.a_bigger_value_is_a_problem(
        '❌ % Not Queued',
        queries.diff(cached_jobs.Queued__Non_Queued.NotQueued_percent)
      ),
      panels.combo.timeSeries.current_vs_prev(
        '❌ % Not Queued',
        queries.start_prev_current_diff(cached_jobs.Queued__Non_Queued.NotQueued_percent),
        cached_jobs.Queued__Non_Queued.NotQueued_percent.unit
      ),

    ], 20, 7, 0
  )
)
