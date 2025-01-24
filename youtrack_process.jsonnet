local g = import 'g.libsonnet';

local row = g.panel.row;

local panels = import './panels.libsonnet';
local variables = import './variables.libsonnet';
local queries = import './queries.promql.thanos.libsonnet';

g.dashboard.new('YouTrack Process')
+ g.dashboard.withDescription(|||
  Dashboard for YouTrack based processes
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
      row.new('Version'),
      panels.texts.version,
      panels.timeseries.version('Version', queries.version),
      row.new('CPU'),
      panels.combo.stat.a_bigger_value_is_a_problem(
        'CPU %', queries.diff(queries.process.cpu)
      ),
      panels.combo.timeSeries.current_vs_prev(
        'CPU %', queries.start_prev_current_diff(queries.process.cpu), queries.process.cpu.unit
      ),

      panels.combo.stat.a_bigger_value_is_a_problem(
        'CPU Cores', queries.diff(queries.process.cpu_cores)
      ),
      panels.combo.timeSeries.current_vs_prev(
        'CPU Cores', queries.start_prev_current_diff(queries.process.cpu_cores), queries.process.cpu_cores.unit
      ),

      row.new('Memory'),
      panels.combo.stat.a_bigger_value_is_a_problem(
        'Resident Memory', queries.diff(queries.process.resident_memory)
      ),
      panels.combo.timeSeries.current_vs_prev(
        'Resident Memory', queries.start_prev_current_diff(queries.process.resident_memory), queries.process.resident_memory.unit
      ),

      panels.combo.stat.a_bigger_value_is_a_problem(
        'Virtual Memory', queries.diff(queries.process.virtual_memory)
      ),
      panels.combo.timeSeries.current_vs_prev(
        'Virtual Memory', queries.start_prev_current_diff(queries.process.virtual_memory), queries.process.virtual_memory.unit
      ),

      row.new('File Descriptors'),
      panels.combo.stat.a_bigger_value_is_a_problem(
        'FDS', queries.diff(queries.process.open_fds)
      ),
      panels.combo.timeSeries.current_vs_prev(
        'FDS', queries.start_prev_current_diff(queries.process.open_fds), queries.process.open_fds.unit
      ),
    ], 20, 7, 0
  )
)
