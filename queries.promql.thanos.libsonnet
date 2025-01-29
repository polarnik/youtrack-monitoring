local g = import './g.libsonnet';
local prometheusQuery = g.query.prometheus;

local variables = import './variables.libsonnet';
local timeSeries = g.panel.timeSeries;

{
  units: {
    percent: 'percent',
    bool_yes_no: 'bool_yes_no',
    none: 'none',
    bytes: 'bytes',
    count_per_second: 'cps',
    count_per_minute: 'cpm'
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
        ( round( %(prev)s , 0.0001) != 0 )
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
  youtrack_Workflow : {
    local filter = 'environment="$environment", service="$service", instance=~"$instance" ',

    RuleGuard: {

    },
    OnScheduleFull: {

    },
    Rule: {

    }
  },
  youtrack_HubIntegration : {
    HubEvents: {
        local filter = 'type="Hub", environment="$environment", service="$service", instance=~"$instance" ',
        Pending: {
            unit: $.units.none,
            current:
            |||
                avg(youtrack_HubIntegration_HubEventsPending{ %(filter)s })
            ||| % { filter: filter }
            ,
            prev:
            |||
                avg(youtrack_HubIntegration_HubEventsPending{ %(filter)s } offset ${offset})
            ||| % { filter: filter }
         },
        Received_per_minute: {
            unit: $.units.count_per_minute,
            current:
            |||
                sum(increase(youtrack_HubIntegration_HubEventsReceived{ %(filter)s }[$__rate_interval]))
                * 60 * 1000 / $__rate_interval_ms
            ||| % { filter: filter }
            ,
            prev:
            |||
                sum(increase(youtrack_HubIntegration_HubEventsReceived{ %(filter)s }[$__rate_interval] offset ${offset}))
                * 60 * 1000 / $__rate_interval_ms
            ||| % { filter: filter }
        },

    Accepted_per_minute: {
        unit: $.units.count_per_minute,
        current:
        |||
            %(Processed)s
            +
            %(Failed)s
            +
            %(Ignored)s
        ||| % {
            Processed: $.youtrack_HubIntegration.HubEvents.Processed_per_minute.current,
            Failed: $.youtrack_HubIntegration.HubEvents.Failed_per_minute.current,
            Ignored: $.youtrack_HubIntegration.HubEvents.Ignored_per_minute.current
        }
        ,
        prev:
        |||
            %(Processed)s
            +
            %(Failed)s
            +
            %(Ignored)s
        ||| % {
            Processed: $.youtrack_HubIntegration.HubEvents.Processed_per_minute.prev,
            Failed: $.youtrack_HubIntegration.HubEvents.Failed_per_minute.prev,
            Ignored: $.youtrack_HubIntegration.HubEvents.Ignored_per_minute.prev
        }
    },

    Ignored_per_minute: {
        unit: $.units.count_per_minute,
        current:
        |||
            sum(increase(youtrack_HubIntegration_HubEventsIgnored{ %(filter)s }[$__rate_interval]))
            * 60 * 1000 / $__rate_interval_ms
        ||| % { filter: filter }
        ,
        prev:
        |||
            sum(increase(youtrack_HubIntegration_HubEventsIgnored{ %(filter)s }[$__rate_interval] offset ${offset}))
            * 60 * 1000 / $__rate_interval_ms
        ||| % { filter: filter }
    },

    Failed_per_minute: {
        unit: $.units.count_per_minute,
        current:
        |||
            sum(increase(youtrack_HubIntegration_HubEventsFailed{ %(filter)s }[$__rate_interval]))
            * 60 * 1000 / $__rate_interval_ms
        ||| % { filter: filter }
        ,
        prev:
        |||
            sum(increase(youtrack_HubIntegration_HubEventsFailed{ %(filter)s }[$__rate_interval] offset ${offset}))
            * 60 * 1000 / $__rate_interval_ms
        ||| % { filter: filter }
    },

    Processed_per_minute: {
        unit: $.units.count_per_minute,
        current:
        |||
            sum(increase(youtrack_HubIntegration_HubEventsProcessed{ %(filter)s }[$__rate_interval]))
            * 60 * 1000 / $__rate_interval_ms
        ||| % { filter: filter }
        ,
        prev:
        |||
            sum(increase(youtrack_HubIntegration_HubEventsProcessed{ %(filter)s }[$__rate_interval] offset ${offset}))
            * 60 * 1000 / $__rate_interval_ms
        ||| % { filter: filter }
    },

    Ignored_percent: {
        unit: $.units.percent,
        current:
        |||
            100 * (
            %(Ignored)s
            ) / (
            ( %(Accepted)s ) != 0
            )
        ||| % {
            Ignored : $.youtrack_HubIntegration.HubEvents.Ignored_per_minute.current,
            Accepted: $.youtrack_HubIntegration.HubEvents.Accepted_per_minute.current,
        }
        ,
        prev:
        |||
            100 * (
            %(Ignored)s
            ) / (
            ( %(Accepted)s ) != 0
            )
        ||| % {
            Ignored : $.youtrack_HubIntegration.HubEvents.Ignored_per_minute.prev,
            Accepted: $.youtrack_HubIntegration.HubEvents.Accepted_per_minute.prev,
        }
    },
    Processed_percent: {
        unit: $.units.percent,
        current:
        |||
            100 * (
            %(Processed)s
            ) / (
            ( %(Accepted)s ) != 0
            )
        ||| % {
            Processed : $.youtrack_HubIntegration.HubEvents.Processed_per_minute.current,
            Accepted  : $.youtrack_HubIntegration.HubEvents.Accepted_per_minute.current,
        }
        ,
        prev:
        |||
            100 * (
            %(Processed)s
            ) / (
            ( %(Accepted)s ) != 0
            )
        ||| % {
            Processed : $.youtrack_HubIntegration.HubEvents.Processed_per_minute.prev,
            Accepted  : $.youtrack_HubIntegration.HubEvents.Accepted_per_minute.prev,
        }
    },
    Failed_percent: {
        unit: $.units.percent,
        current:
        |||
            100 * (
            %(Failed)s
            ) / (
            ( %(Accepted)s ) != 0
            )
        ||| % {
            Failed  : $.youtrack_HubIntegration.HubEvents.Failed_per_minute.current,
            Accepted: $.youtrack_HubIntegration.HubEvents.Accepted_per_minute.current,
        }
        ,
        prev:
        |||
            100 * (
            %(Failed)s
            ) / (
            ( %(Accepted)s ) != 0
            )
        ||| % {
            Failed  : $.youtrack_HubIntegration.HubEvents.Failed_per_minute.prev,
            Accepted: $.youtrack_HubIntegration.HubEvents.Accepted_per_minute.prev,
        }
    },
    },
  },
  Xodus_entity_store_metrics : {
    local filter = 'path="/home/javaapp/teamsysdata/youtrack", environment="$environment", service="$service", instance=~"$instance" ',
    cached_jobs: {
        // ⚙️ Cached Jobs → ✅ Queued → (🟡|🟠) → ❇️ Execute → ✳️ Started → 🚫️ Interrupted → ⌛️ Obsolete | ⏰ Overdue
        Interrupted : {
            // 🚫️ Interrupted
            Interrupted_per_sec: {
                unit: $.units.count_per_second,
                current:
                |||
                    sum(increase(youtrack_TotalCachingJobsInterrupted{ %(filter)s }[$__rate_interval]))
                    * 1000 / $__rate_interval_ms
                ||| % { filter: filter }
                ,
                prev:
                |||
                    sum(increase(youtrack_TotalCachingJobsInterrupted{ %(filter)s }[$__rate_interval] offset ${offset}))
                    * 1000 / $__rate_interval_ms
                ||| % { filter: filter }
            },
            // ⌛️ Obsolete
            Obsolete_per_sec: {
                unit: $.units.count_per_second,
                current:
                |||
                    sum(increase(youtrack_TotalCachingJobsObsolete{ %(filter)s }[$__rate_interval]))
                    * 1000 / $__rate_interval_ms
                ||| % { filter: filter }
                ,
                prev:
                |||
                    sum(increase(youtrack_TotalCachingJobsObsolete{ %(filter)s }[$__rate_interval] offset ${offset}))
                    * 1000 / $__rate_interval_ms
                ||| % { filter: filter }
            },
            // ⏰ Overdue
            Overdue_per_sec: {
                unit: $.units.count_per_second,
                current:
                |||
                    sum(increase(youtrack_TotalCachingJobsOverdue{ %(filter)s }[$__rate_interval]))
                    * 1000 / $__rate_interval_ms
                ||| % { filter: filter }
                ,
                prev:
                |||
                    sum(increase(youtrack_TotalCachingJobsOverdue{ %(filter)s }[$__rate_interval] offset ${offset}))
                    * 1000 / $__rate_interval_ms
                ||| % { filter: filter }
            },
            // ⌛️ % Obsolete
            Obsolete_percent: {
                unit: $.units.percent,
                current:
                |||
                    100 * ( %(part)s )
                    / (
                    ( %(total)s ) != 0
                    )
                ||| % {
                    part : $.Xodus_entity_store_metrics.cached_jobs.Interrupted.Obsolete_per_sec.current,
                    total: $.Xodus_entity_store_metrics.cached_jobs.Interrupted.Interrupted_per_sec.current
                }
                ,
                prev:
                |||
                    100 * ( %(part)s )
                    / (
                    ( %(total)s ) != 0
                    )
                ||| % {
                    part : $.Xodus_entity_store_metrics.cached_jobs.Interrupted.Obsolete_per_sec.prev,
                    total: $.Xodus_entity_store_metrics.cached_jobs.Interrupted.Interrupted_per_sec.prev
                }
            },
            // ⏰ % Overdue
            Overdue_percent: {
                unit: $.units.percent,
                current:
                |||
                    100 * ( %(part)s )
                    / (
                    ( %(total)s ) != 0
                    )
                ||| % {
                    part : $.Xodus_entity_store_metrics.cached_jobs.Interrupted.Overdue_per_sec.current,
                    total: $.Xodus_entity_store_metrics.cached_jobs.Interrupted.Interrupted_per_sec.current
                }
                ,
                prev:
                |||
                    100 * ( %(part)s )
                    / (
                    ( %(total)s ) != 0
                    )
                ||| % {
                    part : $.Xodus_entity_store_metrics.cached_jobs.Interrupted.Overdue_per_sec.prev,
                    total: $.Xodus_entity_store_metrics.cached_jobs.Interrupted.Interrupted_per_sec.prev
                }
            },
        },
        // ⚙️ Cached Jobs → ✅ Queued → (🟡|🟠) → ❇️ Execute → ✳️ Started → ↩️ Retried → 🟡 Consistent | 🟠 Non Consistent
        Retried : {
            // ↩️ Retried
            Retried_per_sec: {
                unit: $.units.count_per_second,
                current:
                |||
                    %(Consistent)s
                    +
                    %(NonConsistent)s
                ||| % {
                    Consistent   : $.Xodus_entity_store_metrics.cached_jobs.Retried.Consistent_per_sec.current,
                    NonConsistent: $.Xodus_entity_store_metrics.cached_jobs.Retried.NonConsistent_per_sec.current
                    }
                ,
                prev:
                |||
                    %(Consistent)s
                    +
                    %(NonConsistent)s
                ||| % {
                    Consistent   : $.Xodus_entity_store_metrics.cached_jobs.Retried.Consistent_per_sec.prev,
                    NonConsistent: $.Xodus_entity_store_metrics.cached_jobs.Retried.NonConsistent_per_sec.prev
                    }
            },
            // 🟡 Consistent
            Consistent_per_sec: {
                unit: $.units.count_per_second,
                current:
                |||
                    sum(increase(youtrack_TotalCachingJobsRetried{ %(filter)s }[$__rate_interval]))
                    * 1000 / $__rate_interval_ms
                ||| % { filter: filter }
                ,
                prev:
                |||
                    sum(increase(youtrack_TotalCachingJobsRetried{ %(filter)s }[$__rate_interval] offset ${offset}))
                    * 1000 / $__rate_interval_ms
                ||| % { filter: filter }
            },
            // 🟠 Non Consistent
            NonConsistent_per_sec: {
                unit: $.units.count_per_second,
                current:
                |||
                    sum(increase(youtrack_TotalCachingCountJobsRetried{ %(filter)s }[$__rate_interval]))
                    * 1000 / $__rate_interval_ms
                ||| % { filter: filter }
                ,
                prev:
                |||
                    sum(increase(youtrack_TotalCachingCountJobsRetried{ %(filter)s }[$__rate_interval] offset ${offset}))
                    * 1000 / $__rate_interval_ms
                ||| % { filter: filter }
            },
            // 🟡 % Consistent
            Consistent_percent: {
                unit: $.units.percent,
                current:
                |||
                    100 * ( %(part)s )
                    / (
                    ( %(total)s ) != 0
                    )
                ||| % {
                    part : $.Xodus_entity_store_metrics.cached_jobs.Retried.Consistent_per_sec.current,
                    total: $.Xodus_entity_store_metrics.cached_jobs.Retried.Retried_per_sec.current
                }
                ,
                prev:
                |||
                    100 * ( %(part)s )
                    / (
                    ( %(total)s ) != 0
                    )
                ||| % {
                    part : $.Xodus_entity_store_metrics.cached_jobs.Retried.Consistent_per_sec.prev,
                    total: $.Xodus_entity_store_metrics.cached_jobs.Retried.Retried_per_sec.prev
                }
            },
            // 🟠 % Non Consistent
            NonConsistent_percent: {
                unit: $.units.percent,
                current:
                |||
                    100 * ( %(part)s )
                    / (
                    ( %(total)s ) != 0
                    )
                ||| % {
                    part : $.Xodus_entity_store_metrics.cached_jobs.Retried.NonConsistent_per_sec.current,
                    total: $.Xodus_entity_store_metrics.cached_jobs.Retried.Retried_per_sec.current
                }
                ,
                prev:
                |||
                    100 * ( %(part)s )
                    / (
                    ( %(total)s ) != 0
                    )
                ||| % {
                    part : $.Xodus_entity_store_metrics.cached_jobs.Retried.NonConsistent_per_sec.prev,
                    total: $.Xodus_entity_store_metrics.cached_jobs.Retried.Retried_per_sec.prev
                }
            },
        },
        // ⚙️ Cached Jobs → ✅ Queued → (🟡|🟠) → ❇️ Execute → ✳️ Started → ❎ Completed | ↩️ Retried | 🚫️ Interrupted
        Started : {
            // ✳️ Started
            Started_per_sec: {
                unit: $.units.count_per_second,
                current:
                |||
                    sum(increase(youtrack_TotalCachingJobsStarted{ %(filter)s }[$__rate_interval]))
                    * 1000 / $__rate_interval_ms
                ||| % { filter: filter }
                ,
                prev:
                |||
                    sum(increase(youtrack_TotalCachingJobsStarted{ %(filter)s }[$__rate_interval] offset ${offset}))
                    * 1000 / $__rate_interval_ms
                ||| % { filter: filter }
            },
            // ❎ Completed
            Completed_per_sec: {
                unit: $.units.count_per_second,
                current:
                |||
                    %(started)s
                    -
                    %(retried)s
                    -
                    %(interrupted)s
                ||| % {
                    started: $.Xodus_entity_store_metrics.cached_jobs.Started.Started_per_sec.current,
                    retried: $.Xodus_entity_store_metrics.cached_jobs.Started.Retried_per_sec.current,
                    interrupted: $.Xodus_entity_store_metrics.cached_jobs.Started.Interrupted_per_sec.current
                }
                ,
                prev:
                |||
                    %(started)s
                    -
                    %(retried)s
                    -
                    %(interrupted)s
                ||| % {
                    started: $.Xodus_entity_store_metrics.cached_jobs.Started.Started_per_sec.prev,
                    retried: $.Xodus_entity_store_metrics.cached_jobs.Started.Retried_per_sec.prev,
                    interrupted: $.Xodus_entity_store_metrics.cached_jobs.Started.Interrupted_per_sec.prev
                }
            },
            // ↩️ Retried
            Retried_per_sec: {
                unit: $.units.count_per_second,
                current: $.Xodus_entity_store_metrics.cached_jobs.Retried.Retried_per_sec.current,
                prev: $.Xodus_entity_store_metrics.cached_jobs.Retried.Retried_per_sec.prev
            },
            // 🚫️ Interrupted
            Interrupted_per_sec: {
                unit: $.units.count_per_second,
                current:
                |||
                    sum(increase(youtrack_TotalCachingJobsInterrupted{ %(filter)s }[$__rate_interval]))
                    * 1000 / $__rate_interval_ms
                ||| % { filter: filter }
                ,
                prev:
                |||
                    sum(increase(youtrack_TotalCachingJobsInterrupted{ %(filter)s }[$__rate_interval] offset ${offset}))
                    * 1000 / $__rate_interval_ms
                ||| % { filter: filter }
            },
            // ❎ % Completed
            Completed_percent: {
                unit: $.units.percent,
                current:
                |||
                    100 * ( %(part)s )
                    / (
                    ( %(total)s ) != 0
                    )
                ||| % {
                    part : $.Xodus_entity_store_metrics.cached_jobs.Started.Completed_per_sec.current,
                    total: $.Xodus_entity_store_metrics.cached_jobs.Started.Started_per_sec.current
                }
                ,
                prev:
                |||
                    100 * ( %(part)s )
                    / (
                    ( %(total)s ) != 0
                    )
                ||| % {
                    part : $.Xodus_entity_store_metrics.cached_jobs.Started.Completed_per_sec.prev,
                    total: $.Xodus_entity_store_metrics.cached_jobs.Started.Started_per_sec.prev
                }
            },
            // ↩️ % Retried
            Retried_percent: {
                unit: $.units.percent,
                current:
                |||
                    100 * ( %(part)s )
                    / (
                    ( %(total)s ) != 0
                    )
                ||| % {
                    part : $.Xodus_entity_store_metrics.cached_jobs.Started.Retried_per_sec.current,
                    total: $.Xodus_entity_store_metrics.cached_jobs.Started.Started_per_sec.current
                }
                ,
                prev:
                |||
                    100 * ( %(part)s )
                    / (
                    ( %(total)s ) != 0
                    )
                ||| % {
                    part : $.Xodus_entity_store_metrics.cached_jobs.Started.Retried_per_sec.prev,
                    total: $.Xodus_entity_store_metrics.cached_jobs.Started.Started_per_sec.prev
                }
            },
            // 🚫️ % Interrupted
            Interrupted_percent: {
                unit: $.units.percent,
                current:
                |||
                    100 * ( %(part)s )
                    / (
                    ( %(total)s ) != 0
                    )
                ||| % {
                    part : $.Xodus_entity_store_metrics.cached_jobs.Started.Interrupted_per_sec.current,
                    total: $.Xodus_entity_store_metrics.cached_jobs.Started.Started_per_sec.current
                }
                ,
                prev:
                |||
                    100 * ( %(part)s )
                    / (
                    ( %(total)s ) != 0
                    )
                ||| % {
                    part : $.Xodus_entity_store_metrics.cached_jobs.Started.Interrupted_per_sec.prev,
                    total: $.Xodus_entity_store_metrics.cached_jobs.Started.Started_per_sec.prev
                }
            }
        },
        // ⚙️ Cached Jobs -> Execute -> Started | Not Started
        Execute : {
            // Execute (per 1 second)
            Execute_per_sec: {
                unit: $.units.count_per_second,
                current:
                |||
                    %(started)s
                    +
                    %(notStarted)s
                ||| % {
                    started: $.Xodus_entity_store_metrics.cached_jobs.Execute.Started_per_sec.current,
                    notStarted: $.Xodus_entity_store_metrics.cached_jobs.Execute.Not_Started_per_sec.current
                }
                ,
                prev:
                |||
                    %(started)s
                    +
                    %(notStarted)s
                ||| % {
                    started: $.Xodus_entity_store_metrics.cached_jobs.Execute.Started_per_sec.prev,
                    notStarted: $.Xodus_entity_store_metrics.cached_jobs.Execute.Not_Started_per_sec.prev
                }
            },
            // ✅ Started (per 1 second)
            Started_per_sec: {
                unit: $.units.count_per_second,
                current:
                |||
                    sum(increase(youtrack_TotalCachingJobsStarted{ %(filter)s }[$__rate_interval]))
                    * 1000 / $__rate_interval_ms
                ||| % { filter: filter }
                ,
                prev:
                |||
                    sum(increase(youtrack_TotalCachingJobsStarted{ %(filter)s }[$__rate_interval] offset ${offset}))
                    * 1000 / $__rate_interval_ms
                ||| % { filter: filter }
            },
            // ❌ Not Started (per 1 second)
            Not_Started_per_sec: {
                unit: $.units.count_per_second,
                current:
                |||
                    sum(increase(youtrack_TotalCachingJobsNotStarted{ %(filter)s }[$__rate_interval]))
                    * 1000 / $__rate_interval_ms
                ||| % { filter: filter }
                ,
                prev:
                |||
                    sum(increase(youtrack_TotalCachingJobsNotStarted{ %(filter)s }[$__rate_interval] offset ${offset}))
                    * 1000 / $__rate_interval_ms
                ||| % { filter: filter }
            },
            // ✅ % Started
            Started_percent: {
                unit: $.units.percent,
                current:
                |||
                    100 * (
                        %(started)s
                    )
                    / (
                       ( %(execute)s ) != 0
                    )
                ||| % {
                    started: $.Xodus_entity_store_metrics.cached_jobs.Execute.Started_per_sec.current,
                    execute: $.Xodus_entity_store_metrics.cached_jobs.Execute.Execute_per_sec.current
                }
                ,
                prev:
                |||
                    100 * (
                        %(started)s
                    )
                    / (
                       ( %(execute)s ) != 0
                    )
                ||| % {
                    started: $.Xodus_entity_store_metrics.cached_jobs.Execute.Started_per_sec.prev,
                    execute: $.Xodus_entity_store_metrics.cached_jobs.Execute.Execute_per_sec.prev
                }
            },
            // ❌ % Not Started
            Not_Started_percent: {
                unit: $.units.percent,
                current:
                |||
                    100 * (
                        %(not_started)s
                    )
                    / (
                       ( %(execute)s ) != 0
                    )
                ||| % {
                    not_started: $.Xodus_entity_store_metrics.cached_jobs.Execute.Not_Started_per_sec.current,
                    execute    : $.Xodus_entity_store_metrics.cached_jobs.Execute.Execute_per_sec.current
                }
                ,
                prev:
                |||
                    100 * (
                        %(not_started)s
                    )
                    / (
                       ( %(execute)s ) != 0
                    )
                ||| % {
                    not_started: $.Xodus_entity_store_metrics.cached_jobs.Execute.Not_Started_per_sec.prev,
                    execute    : $.Xodus_entity_store_metrics.cached_jobs.Execute.Execute_per_sec.prev
                }
            },
        },
        Queued : {
            // ✅ Consistent (per 1 second)
            Consistent_per_sec: {
                unit: $.units.count_per_second,
                current:
                |||
                    sum(increase(youtrack_TotalCachingJobsEnqueued{ %(filter)s }[$__rate_interval]))
                    * 1000 / $__rate_interval_ms
                ||| % { filter: filter }
                ,
                prev:
                |||
                    sum(increase(youtrack_TotalCachingJobsEnqueued{ %(filter)s }[$__rate_interval] offset ${offset}))
                    * 1000 / $__rate_interval_ms
                ||| % { filter: filter }
            },
            // ❌ Non Consistent (per 1 second)
            Non_Consistent_per_sec: {
                unit: $.units.count_per_second,
                current:
                |||
                    sum(increase(youtrack_TotalCachingCountJobsEnqueued{ %(filter)s }[$__rate_interval]))
                    * 1000 / $__rate_interval_ms
                ||| % { filter: filter }
                ,
                prev:
                |||
                    sum(increase(youtrack_TotalCachingCountJobsEnqueued{ %(filter)s }[$__rate_interval] offset ${offset}))
                    * 1000 / $__rate_interval_ms
                ||| % { filter: filter }
            },
            // ✅ % Consistent ( 100 * Consistent / Queued )
            Consistent_percent: {
                unit: $.units.percent,
                current:
                |||
                    100 * ( %(part)s ) /
                    ( ( %(total)s ) != 0 )
                ||| % {
                        part: $.Xodus_entity_store_metrics.cached_jobs.Queued.Consistent_per_sec.current
                        , total: $.Xodus_entity_store_metrics.cached_jobs.Queued__Non_Queued.Queued_jobs_per_sec.current
                     }
                ,
                prev:
                |||
                    100 * ( %(part)s ) /
                    ( ( %(total)s ) != 0 )
                ||| % {
                        part: $.Xodus_entity_store_metrics.cached_jobs.Queued.Consistent_per_sec.prev
                        , total: $.Xodus_entity_store_metrics.cached_jobs.Queued__Non_Queued.Queued_jobs_per_sec.prev
                     }
            },
            // ❌ % Non Consistent ( 100 * Non Consistent / Queued )
            Non_Consistent_percent: {
                unit: $.units.percent,
                current:
                |||
                    100 * ( %(part)s ) /
                    ( ( %(total)s ) != 0 )
                ||| % {
                        part: $.Xodus_entity_store_metrics.cached_jobs.Queued.Non_Consistent_per_sec.current
                        , total: $.Xodus_entity_store_metrics.cached_jobs.Queued__Non_Queued.Queued_jobs_per_sec.current
                     }
                ,
                prev:
                |||
                    100 * ( %(part)s ) /
                    ( ( %(total)s ) != 0 )
                ||| % {
                        part: $.Xodus_entity_store_metrics.cached_jobs.Queued.Non_Consistent_per_sec.prev
                        , total: $.Xodus_entity_store_metrics.cached_jobs.Queued__Non_Queued.Queued_jobs_per_sec.prev
                     }
            }
        },
        Queued__Non_Queued : {
            // ➕ Queued + Not Queued (per 1 second)
            Queued__and__Non_Queued_per_sec: {
                unit: $.units.count_per_second,
                current:
                |||
                    (
                    sum(increase(youtrack_TotalCachingJobsEnqueued{ %(filter)s }[$__rate_interval]))
                    +
                    sum(increase(youtrack_TotalCachingCountJobsEnqueued{ %(filter)s }[$__rate_interval]))
                    +
                    sum(increase(youtrack_TotalCachingJobsNotQueued{ %(filter)s }[$__rate_interval]))
                    ) * 1000 / $__rate_interval_ms
                ||| % { filter: filter }
                ,
                prev:
                |||
                    (
                    sum(increase(youtrack_TotalCachingJobsEnqueued{ %(filter)s }[$__rate_interval] offset ${offset}))
                    +
                    sum(increase(youtrack_TotalCachingCountJobsEnqueued{ %(filter)s }[$__rate_interval] offset ${offset}))
                    +
                    sum(increase(youtrack_TotalCachingJobsNotQueued{ %(filter)s }[$__rate_interval] offset ${offset}))
                    )  * 1000 / $__rate_interval_ms
                ||| % { filter: filter }
            },
            // ✅ Queued (per 1 second)
            Queued_jobs_per_sec: {
                unit: $.units.count_per_second,
                current:
                |||
                    (
                    sum(increase(youtrack_TotalCachingJobsEnqueued{ %(filter)s }[$__rate_interval]))
                    +
                    sum(increase(youtrack_TotalCachingCountJobsEnqueued{ %(filter)s }[$__rate_interval]))
                    ) * 1000 / $__rate_interval_ms
                ||| % { filter: filter }
                ,
                prev:
                |||
                    (
                    sum(increase(youtrack_TotalCachingJobsEnqueued{ %(filter)s }[$__rate_interval] offset ${offset}))
                    +
                    sum(increase(youtrack_TotalCachingCountJobsEnqueued{ %(filter)s }[$__rate_interval] offset ${offset}))
                    )  * 1000 / $__rate_interval_ms
                ||| % { filter: filter }
            },
            // ❌ Not Queued (per 1 second)
            NotQueued_jobs_per_sec: {
                unit: $.units.count_per_second,
                current:
                |||
                    (
                    sum(increase(youtrack_TotalCachingJobsNotQueued{ %(filter)s }[$__rate_interval]))
                    ) * 1000 / $__rate_interval_ms
                ||| % { filter: filter }
                ,
                prev:
                |||
                    (
                    sum(increase(youtrack_TotalCachingJobsNotQueued{ %(filter)s }[$__rate_interval] offset ${offset}))
                    )  * 1000 / $__rate_interval_ms
                ||| % { filter: filter }
            },
            // ✅ % Queued
            Queued_percent: {
                unit: $.units.percent,
                current:
                |||
                    100 * ( %(part)s ) /
                    ( ( %(total)s ) != 0 )
                ||| % {
                        part: $.Xodus_entity_store_metrics.cached_jobs.Queued__Non_Queued.Queued_jobs_per_sec.current
                        , total: $.Xodus_entity_store_metrics.cached_jobs.Queued__Non_Queued.Queued__and__Non_Queued_per_sec.current
                     }
                ,
                prev:
                |||
                    100 * ( %(part)s ) /
                    ( ( %(total)s ) != 0 )
                ||| % {
                        part: $.Xodus_entity_store_metrics.cached_jobs.Queued__Non_Queued.Queued_jobs_per_sec.prev
                        , total: $.Xodus_entity_store_metrics.cached_jobs.Queued__Non_Queued.Queued__and__Non_Queued_per_sec.prev
                     }
            },
            // ❌ % Not Queued
            NotQueued_percent: {
                unit: $.units.percent,
                current:
                |||
                    100 * ( %(part)s ) /
                    ( ( %(total)s ) != 0 )
                ||| % {
                        part: $.Xodus_entity_store_metrics.cached_jobs.Queued__Non_Queued.NotQueued_jobs_per_sec.current
                        , total: $.Xodus_entity_store_metrics.cached_jobs.Queued__Non_Queued.Queued__and__Non_Queued_per_sec.current
                     }
                ,
                prev:
                |||
                    100 * ( %(part)s ) /
                    ( ( %(total)s ) != 0 )
                ||| % {
                        part: $.Xodus_entity_store_metrics.cached_jobs.Queued__Non_Queued.NotQueued_jobs_per_sec.prev
                        , total: $.Xodus_entity_store_metrics.cached_jobs.Queued__Non_Queued.Queued__and__Non_Queued_per_sec.prev
                     }
            },
        },

    }
  },

  process: {
    cpu: {
      unit: $.units.percent,
      current:
        '100 * process_cpu_load{ %(filter)s }' % $,
      prev:
        '100 * process_cpu_load{ %(filter)s } offset ${offset}' % $,
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
