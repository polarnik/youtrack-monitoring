local g = import 'g.libsonnet';

local row = g.panel.row;

local panels = import './panels.libsonnet';
local variables = import './variables.libsonnet';
local queries = import './queries.promql.thanos.libsonnet';

g.dashboard.new('YouTrack Workflow Details')
+ g.dashboard.withDescription(|||
  Dashboard with details about some YouTrack Workflow
|||)
+ g.dashboard.withUid('yt_workflow_details')
+ g.dashboard.withTags([
  'YouTrack Server',
  'YouTrack Workflows'
])
+ panels.links(['YouTrack Server', 'YouTrack Workflows'])
+ g.dashboard.graphTooltip.withSharedCrosshair()
+ g.dashboard.withVariables([
  variables.datasource,
  variables.offset,
  variables.diff_interval,
  variables.instance,
  variables.app_start,
  variables.workflow_group,
  variables.workflow_script,
])
+ g.dashboard.withPanels(
  g.util.grid.wrapPanels(
    [
      // Version
      row.new('Version'),
      panels.texts.version,
      panels.timeseries.version('Version', queries.version),

    ], 20, 7, 0
  )
)