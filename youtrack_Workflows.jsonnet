local g = import 'g.libsonnet';

local row = g.panel.row;

local panels = import './panels.libsonnet';
local variables = import './variables.libsonnet';
local queries = import './queries.promql.thanos.libsonnet';

g.dashboard.new('YouTrack Workflows')
+ g.dashboard.withDescription(|||
  Dashboard for YouTrack Workflows: 🛡 Rule Guard, ❇️ Rule, 🗓 On Schedule Full
|||)
+ g.dashboard.withUid('yt_workflows')
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
])
+ g.dashboard.withPanels(
  g.util.grid.wrapPanels(
    [
      // Version
      row.new('Version'),
      panels.texts.version,
      panels.timeseries.version('Version', queries.version),

      row.new('Scripts that affect the duration of responses: ❇️ Rule, 🛡 Rule Guard'),

      row.new('All workflow scripts: ❇️ Rule, 🛡 Rule Guard, 🗓 On Schedule Full'),
      row.new('❇️ Rule'),
        panels.combo.stat.a_bigger_value_is_a_problem(
          '❌ Failed ❇️ Rule', queries.diff(queries.workflows.Rule.average_failed_per_minute)
        ),
        panels.combo.timeSeries.current_vs_prev(
          '❌ Failed count per minute for ❇️ Rule',
          queries.start_prev_current_diff(queries.workflows.Rule.average_failed_per_minute),
          queries.workflows.Rule.average_failed_per_minute.unit
        ),

        panels.combo.stat.a_bigger_value_is_better(
          '✴️ Events ❇️ Rule', queries.diff(queries.workflows.Rule.average_events_per_minute)
        ),
        panels.combo.timeSeries.current_vs_prev(
          '✴️ Events count per minute for ❇️ Rule',
          queries.start_prev_current_diff(queries.workflows.Rule.average_events_per_minute),
          queries.workflows.Rule.average_events_per_minute.unit
        ),

        panels.combo.stat.a_bigger_value_is_a_problem(
          '🕒 Duration of ❇️ Rule', queries.diff(queries.workflows.Rule.average_duration_per_minute)
        ),
        panels.combo.timeSeries.current_vs_prev(
          '🕒 Duration (per 1 minute) of ❇️ Rule',
          queries.start_prev_current_diff(queries.workflows.Rule.average_duration_per_minute),
          queries.workflows.Rule.average_duration_per_minute.unit
        ),
        panels.combo.stat.a_bigger_value_is_a_problem(
          '🕒 Duration of ❇️ Rule', queries.diff(queries.workflows.Rule.average_duration_per_hour)
        ),
        panels.combo.timeSeries.current_vs_prev(
          '🕒 Duration (per 1 hour) of ❇️ Rule',
          queries.start_prev_current_diff(queries.workflows.Rule.average_duration_per_hour),
          queries.workflows.Rule.average_duration_per_hour.unit
        ),
        panels.combo.stat.a_bigger_value_is_a_problem(
          '🕒 Average Duration of one ❇️ Rule', queries.diff(queries.workflows.Rule.average_duration_per_event)
        ),
        panels.combo.timeSeries.current_vs_prev(
          '🕒 Average Duration (per request) of one ❇️ Rule',
          queries.start_prev_current_diff(queries.workflows.Rule.average_duration_per_event),
          queries.workflows.Rule.average_duration_per_event.unit
        ),
      row.new('🛡 Rule Guard'),
        panels.combo.stat.a_bigger_value_is_a_problem(
          '❌ Failed 🛡 Rule Guard', queries.diff(queries.workflows.RuleGuard.average_failed_per_minute)
        ),
        panels.combo.timeSeries.current_vs_prev(
          '❌ Failed count per minute for 🛡 Rule Guard',
          queries.start_prev_current_diff(queries.workflows.RuleGuard.average_failed_per_minute),
          queries.workflows.RuleGuard.average_failed_per_minute.unit
        ),

        panels.combo.stat.a_bigger_value_is_better(
          '✴️ Events 🛡 Rule Guard', queries.diff(queries.workflows.RuleGuard.average_events_per_minute)
        ),
        panels.combo.timeSeries.current_vs_prev(
          '✴️ Events count per minute for 🛡 Rule Guard',
          queries.start_prev_current_diff(queries.workflows.RuleGuard.average_events_per_minute),
          queries.workflows.RuleGuard.average_events_per_minute.unit
        ),

        panels.combo.stat.a_bigger_value_is_a_problem(
          '🕒 Duration of 🛡 Rule Guard', queries.diff(queries.workflows.RuleGuard.average_duration_per_minute)
        ),
        panels.combo.timeSeries.current_vs_prev(
          '🕒 Duration (per 1 minute) of 🛡 Rule Guard',
          queries.start_prev_current_diff(queries.workflows.RuleGuard.average_duration_per_minute),
          queries.workflows.RuleGuard.average_duration_per_minute.unit
        ),
        panels.combo.stat.a_bigger_value_is_a_problem(
          '🕒 Duration of 🛡 Rule Guard', queries.diff(queries.workflows.RuleGuard.average_duration_per_hour)
        ),
        panels.combo.timeSeries.current_vs_prev(
          '🕒 Duration (per 1 hour) of 🛡 Rule Guard',
          queries.start_prev_current_diff(queries.workflows.RuleGuard.average_duration_per_hour),
          queries.workflows.RuleGuard.average_duration_per_hour.unit
        ),
        panels.combo.stat.a_bigger_value_is_a_problem(
          '🕒 Average Duration of one 🛡 Rule Guard', queries.diff(queries.workflows.RuleGuard.average_duration_per_event)
        ),
        panels.combo.timeSeries.current_vs_prev(
          '🕒 Average Duration (per request) of one 🛡 Rule Guard',
          queries.start_prev_current_diff(queries.workflows.RuleGuard.average_duration_per_event),
          queries.workflows.RuleGuard.average_duration_per_event.unit
        ),
      row.new('🗓 On Schedule Full'),
        panels.combo.stat.a_bigger_value_is_a_problem(
        '❌ Failed 🗓 On Schedule Full', queries.diff(queries.workflows.OnScheduleFull.average_failed_per_minute)
        ),
        panels.combo.timeSeries.current_vs_prev(
        '❌ Failed count per minute for 🗓 On Schedule Full',
        queries.start_prev_current_diff(queries.workflows.OnScheduleFull.average_failed_per_minute),
        queries.workflows.OnScheduleFull.average_failed_per_minute.unit
        ),

        panels.combo.stat.a_bigger_value_is_better(
        '✴️ Events 🗓 On Schedule Full', queries.diff(queries.workflows.OnScheduleFull.average_events_per_minute)
        ),
        panels.combo.timeSeries.current_vs_prev(
        '✴️ Events count per minute for 🗓 On Schedule Full',
        queries.start_prev_current_diff(queries.workflows.OnScheduleFull.average_events_per_minute),
        queries.workflows.OnScheduleFull.average_events_per_minute.unit
        ),

        panels.combo.stat.a_bigger_value_is_a_problem(
        '🕒 Duration of 🗓 On Schedule Full', queries.diff(queries.workflows.OnScheduleFull.average_duration_per_minute)
        ),
        panels.combo.timeSeries.current_vs_prev(
        '🕒 Duration (per 1 minute) of 🗓 On Schedule Full',
        queries.start_prev_current_diff(queries.workflows.OnScheduleFull.average_duration_per_minute),
        queries.workflows.OnScheduleFull.average_duration_per_minute.unit
        ),
        panels.combo.stat.a_bigger_value_is_a_problem(
        '🕒 Duration of 🗓 On Schedule Full', queries.diff(queries.workflows.OnScheduleFull.average_duration_per_hour)
        ),
        panels.combo.timeSeries.current_vs_prev(
        '🕒 Duration (per 1 hour) of 🗓 On Schedule Full',
        queries.start_prev_current_diff(queries.workflows.OnScheduleFull.average_duration_per_hour),
        queries.workflows.OnScheduleFull.average_duration_per_hour.unit
        ),
        panels.combo.stat.a_bigger_value_is_a_problem(
        '🕒 Average Duration of one 🗓 On Schedule Full', queries.diff(queries.workflows.OnScheduleFull.average_duration_per_event)
        ),
        panels.combo.timeSeries.current_vs_prev(
        '🕒 Average Duration (per request) of one 🗓 On Schedule Full',
        queries.start_prev_current_diff(queries.workflows.OnScheduleFull.average_duration_per_event),
        queries.workflows.OnScheduleFull.average_duration_per_event.unit
        ),
    ], 20, 7, 0
  )
)