local g = import 'g.libsonnet';

local row = g.panel.row;

local panels = import './panels.libsonnet';
local variables = import './variables.libsonnet';
local queries = import './queries.promql.thanos.libsonnet';
local hub = queries.youtrack_HubIntegration;

g.dashboard.new('YouTrack HubIntegration')
+ g.dashboard.withDescription(|||
  YouTrack HubIntegration metrics:
  ⚙️ Received, ✅ Processed, ⛔️ Ignored, ⌛️ Pending, ❌ Failed,
|||)
+ g.dashboard.withUid('yt_hubint')
+ g.dashboard.withTags([
  'YouTrack Server',
  'HubIntegration',
])
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
      row.new('ℹ️ Info')
      + row.withCollapsed(true),

      row.new('YouTrack HubIntegration: ⚙️ Received, ⌛️ Pending'),

      panels.combo.stat.a_bigger_value_is_better(
        '⚙️ Received',
        queries.diff(hub.HubEvents.Received_per_minute)
      ),
      panels.combo.timeSeries.current_vs_prev(
        '⚙️ Received (per 1 minute)',
        queries.start_prev_current_diff(hub.HubEvents.Received_per_minute),
        hub.HubEvents.Received_per_minute.unit
      )
      + g.panel.timeSeries.queryOptions.withInterval('1m')
      ,

      // ⌛️ Pending
      panels.combo.stat.a_bigger_value_is_a_problem(
        '⌛️ Pending',
        queries.diff(hub.HubEvents.Pending)
      ),
      panels.combo.timeSeries.current_vs_prev(
        '⌛️ Pending (average Queue lenght)',
        queries.start_prev_current_diff(hub.HubEvents.Pending),
        hub.HubEvents.Pending.unit
      )
      + g.panel.timeSeries.queryOptions.withInterval('1m')
      ,


      row.new('YouTrack HubIntegration (percents): ⛔️ Ignored, ✅ Processed, ❌ Failed'),

      // ⛔️ % Ignored
      panels.combo.stat.a_bigger_value_is_a_problem(
        '⛔️ % Ignored',
        queries.diff(hub.HubEvents.Ignored_percent)
      ),
      panels.combo.timeSeries.current_vs_prev(
        '⛔️ % Ignored: skip all events caused by internal actions',
        queries.start_prev_current_diff(hub.HubEvents.Ignored_percent),
        hub.HubEvents.Ignored_percent.unit
      )
      + g.panel.timeSeries.queryOptions.withInterval('1m')
      ,

      // ✅ % Processed
      panels.combo.stat.a_bigger_value_is_better(
        '✅ % Processed',
        queries.diff(hub.HubEvents.Processed_percent)
      ),
      panels.combo.timeSeries.current_vs_prev(
        '✅ % Processed',
        queries.start_prev_current_diff(hub.HubEvents.Processed_percent),
        hub.HubEvents.Processed_percent.unit
      )
      + g.panel.timeSeries.queryOptions.withInterval('1m')
      ,

      // ❌ % Failed
      panels.combo.stat.a_bigger_value_is_a_problem(
        '❌ % Failed',
        queries.diff(hub.HubEvents.Failed_percent)
      ),
      panels.combo.timeSeries.current_vs_prev(
        '❌ % Failed: see error messages "Got exception while processing Ring event" in logs',
        queries.start_prev_current_diff(hub.HubEvents.Failed_percent),
        hub.HubEvents.Failed_percent.unit
      )
      + g.panel.timeSeries.queryOptions.withInterval('1m'),

      row.new('YouTrack HubIntegration (events per minute): ⛔️ Ignored, ✅ Processed, ❌ Failed'),

      // ⛔️ Ignored
      panels.combo.stat.a_bigger_value_is_a_problem(
        '⛔️ Ignored',
        queries.diff(hub.HubEvents.Ignored_per_minute)
      ),
      panels.combo.timeSeries.current_vs_prev(
        '⛔️ Ignored (per 1 minute): skip all events caused by internal actions',
        queries.start_prev_current_diff(hub.HubEvents.Ignored_per_minute),
        hub.HubEvents.Ignored_per_minute.unit
      )
      + g.panel.timeSeries.queryOptions.withInterval('1m')
      ,

      // ✅ Processed
      panels.combo.stat.a_bigger_value_is_better(
        '✅ Processed',
        queries.diff(hub.HubEvents.Processed_per_minute)
      ),
      panels.combo.timeSeries.current_vs_prev(
        '✅ Processed (per 1 minute)',
        queries.start_prev_current_diff(hub.HubEvents.Processed_per_minute),
        hub.HubEvents.Processed_per_minute.unit
      )
      + g.panel.timeSeries.queryOptions.withInterval('1m')
      ,

      // ❌ Failed
      panels.combo.stat.a_bigger_value_is_a_problem(
        '❌ Failed',
        queries.diff(hub.HubEvents.Failed_per_minute)
      ),
      panels.combo.timeSeries.current_vs_prev(
        '❌ Failed (per 1 minute): see error messages "Got exception while processing Ring event" in logs',
        queries.start_prev_current_diff(hub.HubEvents.Failed_per_minute),
        hub.HubEvents.Failed_per_minute.unit
      )
      + g.panel.timeSeries.queryOptions.withInterval('1m')
      ,

    ], 20, 7, 0
  )
)
