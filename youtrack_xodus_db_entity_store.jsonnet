local g = import 'g.libsonnet';

local row = g.panel.row;

local panels = import './panels.libsonnet';
local variables = import './variables.libsonnet';
local queries = import './queries.promql.thanos.libsonnet';
local cached_jobs = queries.Xodus_entity_store_metrics.cached_jobs;

g.dashboard.new('YouTrack Xodus entity store metrics (DB)')
+ g.dashboard.withDescription(|||
  YouTrack Xodus entity store metrics (DB)
|||)
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

      // ⚙️ Cached Jobs -> Queued | Non Queued
      row.new('⚙️ Cached Jobs -> Queued | Non Queued'),
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
      ),
      panels.combo.timeSeries.current_vs_prev(
        '✅ Queued (per 1 second)',
        queries.start_prev_current_diff(cached_jobs.Queued__Non_Queued.Queued_jobs_per_sec),
        cached_jobs.Queued__Non_Queued.Queued_jobs_per_sec.unit
      ),

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
      ),
      panels.combo.timeSeries.current_vs_prev(
        '✅ % Queued',
        queries.start_prev_current_diff(cached_jobs.Queued__Non_Queued.Queued_percent),
        cached_jobs.Queued__Non_Queued.Queued_percent.unit
      ),

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
