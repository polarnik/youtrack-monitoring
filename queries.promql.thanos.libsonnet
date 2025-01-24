local g = import './g.libsonnet';
local prometheusQuery = g.query.prometheus;

local variables = import './variables.libsonnet';
local timeSeries = g.panel.timeSeries;

{
  units: {
    percentunit: 'percentunit',
    bool_yes_no: 'bool_yes_no',
    none: 'none',
    bytes: 'bytes',
  },

  filter: 'environment="$environment", service="$service", instance=~"$instance"',

  start: prometheusQuery.new(
           '${%s}' % variables.datasource.name,
           |||
             (($app_start * delta(process_uptime{ %(filter)s }[$__rate_interval])) < 0)
             /
             (($app_start * delta(process_uptime{ %(filter)s }[$__rate_interval])) < 0)
           ||| % $
         )
         + prometheusQuery.withEditorMode('code')
         + prometheusQuery.withHide(false)
         + prometheusQuery.withInstant(false)
         + prometheusQuery.withLegendFormat('app start')
         + prometheusQuery.withRange(true)
         + prometheusQuery.withRefId('start')
  ,

  prev(prevQuery):
    prometheusQuery.new(
      '${%s}' % variables.datasource.name,
      prevQuery
    )
    + prometheusQuery.withEditorMode('code')
    + prometheusQuery.withLegendFormat('prev ($offset)')
    + prometheusQuery.withRange(true)
    + prometheusQuery.withRefId('prev')
  ,

  current(currentQuery):
    prometheusQuery.new(
      '${%s}' % variables.datasource.name,
      currentQuery
    )
    + prometheusQuery.withEditorMode('code')
    + prometheusQuery.withLegendFormat('current')
    + prometheusQuery.withRange(true)
    + prometheusQuery.withRefId('current')
  ,

  diff(querySet):
    prometheusQuery.new(
      '${%s}' % variables.datasource.name,
      |||
        100 * (
          ( %(current)s )
          -
          ( %(prev)s )
        )
        /
        ( ( %(prev)s )>0 )
      ||| % querySet
    )
    + prometheusQuery.withLegendFormat('diff')
    + prometheusQuery.withRange(true)
    + prometheusQuery.withRefId('diff')
  ,


  start_prev_current_diff(querySet): [
    self.start,
    self.prev(querySet.prev),
    self.current(querySet.current),
    self.diff(querySet),
  ],

  version:
    [
      prometheusQuery.new(
        '${%s}' % variables.datasource.name,
        'avg by (Version) (youtrack_version_info{ %(filter)s })' % $
      )
      + prometheusQuery.withRefId('Version')
      + prometheusQuery.withFormat('table')
      + prometheusQuery.withInstant(false)
      + prometheusQuery.withRange(true)
      ,
      prometheusQuery.new(
        '${%s}' % variables.datasource.name,
        'avg by (instance, Build) (youtrack_version_info{ %(filter)s })' % $
      )
      + prometheusQuery.withRefId('Build')
      + prometheusQuery.withFormat('table')
      + prometheusQuery.withInstant(false)
      + prometheusQuery.withRange(true),
    ],


  process: {
    cpu: {
      unit: $.units.percentunit,
      current:
        'process_cpu_load{ %(filter)s }' % $,
      prev:
        'process_cpu_load{ %(filter)s } offset ${offset}' % $,
    },
    cpu_cores: {
      unit: $.units.none,
      current:
        'sum(rate(process_cpu_seconds_total{ %(filter)s }[$__rate_interval]))' % $,
      prev:
        'sum(rate(process_cpu_seconds_total{ %(filter)s }[$__rate_interval] offset ${offset}))' % $,
    },
    resident_memory: {
      unit: $.units.bytes,
      current:
        'process_resident_memory_bytes{ %(filter)s }' % $,
      prev:
        'process_resident_memory_bytes{ %(filter)s } offset ${offset}' % $,
    },
    virtual_memory: {
      unit: $.units.bytes,
      current:
        'process_virtual_memory_bytes{ %(filter)s }' % $,
      prev:
        'process_virtual_memory_bytes{ %(filter)s } offset ${offset}' % $,
    },
    open_fds: {
      unit: $.units.none,
      current:
        'process_open_fds{ %(filter)s }' % $,
      prev:
        'process_open_fds{ %(filter)s } offset ${offset}' % $,
    },
  },
}
