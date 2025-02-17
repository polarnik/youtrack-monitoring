local g = import './g.libsonnet';
local prometheusQuery = g.query.prometheus;

local variables = import './variables.libsonnet';
local timeSeries = g.panel.timeSeries;

{
  // Global common filter.
  // It is used in queries via the expression "string-with-filter-var % $".
  // If you want to modify the global filter - let's do it here.
  filter: ' instance=~"$instance"',

  units: {
    percent: 'percent',
    bool_yes_no: 'bool_yes_no',
    none: 'none',
    ms: 'ms',
    bytes: 'bytes',
    count_per_second: 'cps',
    count_per_minute: 'cpm',
  },

  start: prometheusQuery.new(
           '${%s}' % variables.datasource.name,
           |||
             (($app_start * delta({__name__=~"process_uptime.*", %(filter)s }[$__interval:])) < 0)
             /
             (($app_start * delta({__name__=~"process_uptime.*", %(filter)s }[$__interval:])) < 0)
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
  youtrack_Workflow: {
    RuleGuard: {

    },
    OnScheduleFull: {

    },
    Rule: {

    },
  },
  youtrack_HubIntegration: {
    HubEvents: {
      Pending: {
        unit: $.units.none,
        current:
          |||
            avg(youtrack_HubIntegration_HubEventsPending{ %(filter)s })
          ||| % $
        ,
        prev:
          |||
            avg(youtrack_HubIntegration_HubEventsPending{ %(filter)s } offset ${offset})
          ||| % $,
      },
      Received_per_minute: {
        unit: $.units.count_per_minute,
        current:
          |||
            60 * sum(rate(youtrack_HubIntegration_HubEventsReceived{ %(filter)s }[$__interval:]))
          ||| % $
        ,
        prev:
          |||
            60 * sum(rate(youtrack_HubIntegration_HubEventsReceived{ %(filter)s }[$__interval:] offset ${offset}))
          ||| % $,
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
            Ignored: $.youtrack_HubIntegration.HubEvents.Ignored_per_minute.current,
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
            Ignored: $.youtrack_HubIntegration.HubEvents.Ignored_per_minute.prev,
          },
      },

      Ignored_per_minute: {
        unit: $.units.count_per_minute,
        current:
          |||
            60 * sum(rate(youtrack_HubIntegration_HubEventsIgnored{ %(filter)s }[$__interval:]))
          ||| % $
        ,
        prev:
          |||
            60 * sum(rate(youtrack_HubIntegration_HubEventsIgnored{ %(filter)s }[$__interval:] offset ${offset}))
          ||| % $,
      },

      Failed_per_minute: {
        unit: $.units.count_per_minute,
        current:
          |||
            60 * sum(rate(youtrack_HubIntegration_HubEventsFailed{ %(filter)s }[$__interval:]))
          ||| % $
        ,
        prev:
          |||
            60 * sum(rate(youtrack_HubIntegration_HubEventsFailed{ %(filter)s }[$__interval:] offset ${offset}))
          ||| % $,
      },

      Processed_per_minute: {
        unit: $.units.count_per_minute,
        current:
          |||
            60 * sum(rate(youtrack_HubIntegration_HubEventsProcessed{ %(filter)s }[$__interval:]))
          ||| % $
        ,
        prev:
          |||
            60 * sum(rate(youtrack_HubIntegration_HubEventsProcessed{ %(filter)s }[$__interval:] offset ${offset}))
          ||| % $,
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
            Ignored: $.youtrack_HubIntegration.HubEvents.Ignored_per_minute.current,
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
            Ignored: $.youtrack_HubIntegration.HubEvents.Ignored_per_minute.prev,
            Accepted: $.youtrack_HubIntegration.HubEvents.Accepted_per_minute.prev,
          },
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
            Processed: $.youtrack_HubIntegration.HubEvents.Processed_per_minute.current,
            Accepted: $.youtrack_HubIntegration.HubEvents.Accepted_per_minute.current,
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
            Processed: $.youtrack_HubIntegration.HubEvents.Processed_per_minute.prev,
            Accepted: $.youtrack_HubIntegration.HubEvents.Accepted_per_minute.prev,
          },
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
            Failed: $.youtrack_HubIntegration.HubEvents.Failed_per_minute.current,
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
            Failed: $.youtrack_HubIntegration.HubEvents.Failed_per_minute.prev,
            Accepted: $.youtrack_HubIntegration.HubEvents.Accepted_per_minute.prev,
          },
      },
    },
  },
  Xodus_entity_store_metrics: {
    cached_jobs: {
      // ⚙️ Cached Jobs → ✅ Queued → (🟡|🟠) → ❇️ Execute → ✳️ Started → 🚫️ Interrupted → ⌛️ Obsolete | ⏰ Overdue
      Interrupted: {
        // 🚫️ Interrupted
        Interrupted_per_sec: {
          unit: $.units.count_per_second,
          current:
            |||
              sum(rate(youtrack_TotalCachingJobsInterrupted{ %(filter)s }[$__interval:]))
            ||| % $
          ,
          prev:
            |||
              sum(rate(youtrack_TotalCachingJobsInterrupted{ %(filter)s }[$__interval:] offset ${offset}))
            ||| % $,
        },
        // ⌛️ Obsolete
        Obsolete_per_sec: {
          unit: $.units.count_per_second,
          current:
            |||
              sum(rate(youtrack_TotalCachingJobsObsolete{ %(filter)s }[$__interval:]))
            ||| % $
          ,
          prev:
            |||
              sum(rate(youtrack_TotalCachingJobsObsolete{ %(filter)s }[$__interval:] offset ${offset}))
            ||| % $,
        },
        // ⏰ Overdue
        Overdue_per_sec: {
          unit: $.units.count_per_second,
          current:
            |||
              sum(rate(youtrack_TotalCachingJobsOverdue{ %(filter)s }[$__interval:]))
            ||| % $
          ,
          prev:
            |||
              sum(rate(youtrack_TotalCachingJobsOverdue{ %(filter)s }[$__interval:] offset ${offset}))
            ||| % $,
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
              part: $.Xodus_entity_store_metrics.cached_jobs.Interrupted.Obsolete_per_sec.current,
              total: $.Xodus_entity_store_metrics.cached_jobs.Interrupted.Interrupted_per_sec.current,
            }
          ,
          prev:
            |||
              100 * ( %(part)s )
              / (
              ( %(total)s ) != 0
              )
            ||| % {
              part: $.Xodus_entity_store_metrics.cached_jobs.Interrupted.Obsolete_per_sec.prev,
              total: $.Xodus_entity_store_metrics.cached_jobs.Interrupted.Interrupted_per_sec.prev,
            },
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
              part: $.Xodus_entity_store_metrics.cached_jobs.Interrupted.Overdue_per_sec.current,
              total: $.Xodus_entity_store_metrics.cached_jobs.Interrupted.Interrupted_per_sec.current,
            }
          ,
          prev:
            |||
              100 * ( %(part)s )
              / (
              ( %(total)s ) != 0
              )
            ||| % {
              part: $.Xodus_entity_store_metrics.cached_jobs.Interrupted.Overdue_per_sec.prev,
              total: $.Xodus_entity_store_metrics.cached_jobs.Interrupted.Interrupted_per_sec.prev,
            },
        },
      },
      // ⚙️ Cached Jobs → ✅ Queued → (🟡|🟠) → ❇️ Execute → ✳️ Started → ↩️ Retried → 🟡 Consistent | 🟠 Non Consistent
      Retried: {
        // ↩️ Retried
        Retried_per_sec: {
          unit: $.units.count_per_second,
          current:
            |||
              %(Consistent)s
              +
              %(NonConsistent)s
            ||| % {
              Consistent: $.Xodus_entity_store_metrics.cached_jobs.Retried.Consistent_per_sec.current,
              NonConsistent: $.Xodus_entity_store_metrics.cached_jobs.Retried.NonConsistent_per_sec.current,
            }
          ,
          prev:
            |||
              %(Consistent)s
              +
              %(NonConsistent)s
            ||| % {
              Consistent: $.Xodus_entity_store_metrics.cached_jobs.Retried.Consistent_per_sec.prev,
              NonConsistent: $.Xodus_entity_store_metrics.cached_jobs.Retried.NonConsistent_per_sec.prev,
            },
        },
        // 🟡 Consistent
        Consistent_per_sec: {
          unit: $.units.count_per_second,
          current:
            |||
              sum(rate(youtrack_TotalCachingJobsRetried{ %(filter)s }[$__interval:]))
            ||| % $
          ,
          prev:
            |||
              sum(rate(youtrack_TotalCachingJobsRetried{ %(filter)s }[$__interval:] offset ${offset}))
            ||| % $,
        },
        // 🟠 Non Consistent
        NonConsistent_per_sec: {
          unit: $.units.count_per_second,
          current:
            |||
              sum(rate(youtrack_TotalCachingCountJobsRetried{ %(filter)s }[$__interval:]))
            ||| % $
          ,
          prev:
            |||
              sum(rate(youtrack_TotalCachingCountJobsRetried{ %(filter)s }[$__interval:] offset ${offset}))
            ||| % $,
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
              part: $.Xodus_entity_store_metrics.cached_jobs.Retried.Consistent_per_sec.current,
              total: $.Xodus_entity_store_metrics.cached_jobs.Retried.Retried_per_sec.current,
            }
          ,
          prev:
            |||
              100 * ( %(part)s )
              / (
              ( %(total)s ) != 0
              )
            ||| % {
              part: $.Xodus_entity_store_metrics.cached_jobs.Retried.Consistent_per_sec.prev,
              total: $.Xodus_entity_store_metrics.cached_jobs.Retried.Retried_per_sec.prev,
            },
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
              part: $.Xodus_entity_store_metrics.cached_jobs.Retried.NonConsistent_per_sec.current,
              total: $.Xodus_entity_store_metrics.cached_jobs.Retried.Retried_per_sec.current,
            }
          ,
          prev:
            |||
              100 * ( %(part)s )
              / (
              ( %(total)s ) != 0
              )
            ||| % {
              part: $.Xodus_entity_store_metrics.cached_jobs.Retried.NonConsistent_per_sec.prev,
              total: $.Xodus_entity_store_metrics.cached_jobs.Retried.Retried_per_sec.prev,
            },
        },
      },
      // ⚙️ Cached Jobs → ✅ Queued → (🟡|🟠) → ❇️ Execute → ✳️ Started → ❎ Completed | ↩️ Retried | 🚫️ Interrupted
      Started: {
        // ✳️ Started
        Started_per_sec: {
          unit: $.units.count_per_second,
          current:
            |||
              sum(rate(youtrack_TotalCachingJobsStarted{ %(filter)s }[$__interval:]))
            ||| % $
          ,
          prev:
            |||
              sum(rate(youtrack_TotalCachingJobsStarted{ %(filter)s }[$__interval:] offset ${offset}))
            ||| % $,
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
              interrupted: $.Xodus_entity_store_metrics.cached_jobs.Started.Interrupted_per_sec.current,
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
              interrupted: $.Xodus_entity_store_metrics.cached_jobs.Started.Interrupted_per_sec.prev,
            },
        },
        // ↩️ Retried
        Retried_per_sec: {
          unit: $.units.count_per_second,
          current: $.Xodus_entity_store_metrics.cached_jobs.Retried.Retried_per_sec.current,
          prev: $.Xodus_entity_store_metrics.cached_jobs.Retried.Retried_per_sec.prev,
        },
        // 🚫️ Interrupted
        Interrupted_per_sec: {
          unit: $.units.count_per_second,
          current:
            |||
              sum(rate(youtrack_TotalCachingJobsInterrupted{ %(filter)s }[$__interval:]))
            ||| % $
          ,
          prev:
            |||
              sum(rate(youtrack_TotalCachingJobsInterrupted{ %(filter)s }[$__interval:] offset ${offset}))
            ||| % $,
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
              part: $.Xodus_entity_store_metrics.cached_jobs.Started.Completed_per_sec.current,
              total: $.Xodus_entity_store_metrics.cached_jobs.Started.Started_per_sec.current,
            }
          ,
          prev:
            |||
              100 * ( %(part)s )
              / (
              ( %(total)s ) != 0
              )
            ||| % {
              part: $.Xodus_entity_store_metrics.cached_jobs.Started.Completed_per_sec.prev,
              total: $.Xodus_entity_store_metrics.cached_jobs.Started.Started_per_sec.prev,
            },
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
              part: $.Xodus_entity_store_metrics.cached_jobs.Started.Retried_per_sec.current,
              total: $.Xodus_entity_store_metrics.cached_jobs.Started.Started_per_sec.current,
            }
          ,
          prev:
            |||
              100 * ( %(part)s )
              / (
              ( %(total)s ) != 0
              )
            ||| % {
              part: $.Xodus_entity_store_metrics.cached_jobs.Started.Retried_per_sec.prev,
              total: $.Xodus_entity_store_metrics.cached_jobs.Started.Started_per_sec.prev,
            },
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
              part: $.Xodus_entity_store_metrics.cached_jobs.Started.Interrupted_per_sec.current,
              total: $.Xodus_entity_store_metrics.cached_jobs.Started.Started_per_sec.current,
            }
          ,
          prev:
            |||
              100 * ( %(part)s )
              / (
              ( %(total)s ) != 0
              )
            ||| % {
              part: $.Xodus_entity_store_metrics.cached_jobs.Started.Interrupted_per_sec.prev,
              total: $.Xodus_entity_store_metrics.cached_jobs.Started.Started_per_sec.prev,
            },
        },
      },
      // ⚙️ Cached Jobs -> Execute -> Started | Not Started
      Execute: {
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
              notStarted: $.Xodus_entity_store_metrics.cached_jobs.Execute.Not_Started_per_sec.current,
            }
          ,
          prev:
            |||
              %(started)s
              +
              %(notStarted)s
            ||| % {
              started: $.Xodus_entity_store_metrics.cached_jobs.Execute.Started_per_sec.prev,
              notStarted: $.Xodus_entity_store_metrics.cached_jobs.Execute.Not_Started_per_sec.prev,
            },
        },
        // ✅ Started (per 1 second)
        Started_per_sec: {
          unit: $.units.count_per_second,
          current:
            |||
              sum(rate(youtrack_TotalCachingJobsStarted{ %(filter)s }[$__interval:]))
            ||| % $
          ,
          prev:
            |||
              sum(rate(youtrack_TotalCachingJobsStarted{ %(filter)s }[$__interval:] offset ${offset}))
            ||| % $,
        },
        // ❌ Not Started (per 1 second)
        Not_Started_per_sec: {
          unit: $.units.count_per_second,
          current:
            |||
              sum(rate(youtrack_TotalCachingJobsNotStarted{ %(filter)s }[$__interval:]))
            ||| % $
          ,
          prev:
            |||
              sum(rate(youtrack_TotalCachingJobsNotStarted{ %(filter)s }[$__interval:] offset ${offset}))
            ||| % $,
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
              execute: $.Xodus_entity_store_metrics.cached_jobs.Execute.Execute_per_sec.current,
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
              execute: $.Xodus_entity_store_metrics.cached_jobs.Execute.Execute_per_sec.prev,
            },
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
              execute: $.Xodus_entity_store_metrics.cached_jobs.Execute.Execute_per_sec.current,
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
              execute: $.Xodus_entity_store_metrics.cached_jobs.Execute.Execute_per_sec.prev,
            },
        },
      },
      Queued: {
        // ✅ Consistent (per 1 second)
        Consistent_per_sec: {
          unit: $.units.count_per_second,
          current:
            |||
              sum(rate(youtrack_TotalCachingJobsEnqueued{ %(filter)s }[$__interval:]))
            ||| % $
          ,
          prev:
            |||
              sum(rate(youtrack_TotalCachingJobsEnqueued{ %(filter)s }[$__interval:] offset ${offset}))
            ||| % $,
        },
        // ❌ Non Consistent (per 1 second)
        Non_Consistent_per_sec: {
          unit: $.units.count_per_second,
          current:
            |||
              sum(rate(youtrack_TotalCachingCountJobsEnqueued{ %(filter)s }[$__interval:]))
            ||| % $
          ,
          prev:
            |||
              sum(rate(youtrack_TotalCachingCountJobsEnqueued{ %(filter)s }[$__interval:] offset ${offset}))
            ||| % $,
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
              ,
              total: $.Xodus_entity_store_metrics.cached_jobs.Queued__Non_Queued.Queued_jobs_per_sec.current,
            }
          ,
          prev:
            |||
              100 * ( %(part)s ) /
              ( ( %(total)s ) != 0 )
            ||| % {
              part: $.Xodus_entity_store_metrics.cached_jobs.Queued.Consistent_per_sec.prev
              ,
              total: $.Xodus_entity_store_metrics.cached_jobs.Queued__Non_Queued.Queued_jobs_per_sec.prev,
            },
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
              ,
              total: $.Xodus_entity_store_metrics.cached_jobs.Queued__Non_Queued.Queued_jobs_per_sec.current,
            }
          ,
          prev:
            |||
              100 * ( %(part)s ) /
              ( ( %(total)s ) != 0 )
            ||| % {
              part: $.Xodus_entity_store_metrics.cached_jobs.Queued.Non_Consistent_per_sec.prev
              ,
              total: $.Xodus_entity_store_metrics.cached_jobs.Queued__Non_Queued.Queued_jobs_per_sec.prev,
            },
        },
      },
      Queued__Non_Queued: {
        // ➕ Queued + Not Queued (per 1 second)
        Queued__and__Non_Queued_per_sec: {
          unit: $.units.count_per_second,
          current:
            |||
              sum(rate(youtrack_TotalCachingJobsEnqueued{ %(filter)s }[$__interval:]))
              +
              sum(rate(youtrack_TotalCachingCountJobsEnqueued{ %(filter)s }[$__interval:]))
              +
              sum(rate(youtrack_TotalCachingJobsNotQueued{ %(filter)s }[$__interval:]))
            ||| % $
          ,
          prev:
            |||
              sum(rate(youtrack_TotalCachingJobsEnqueued{ %(filter)s }[$__interval:] offset ${offset}))
              +
              sum(rate(youtrack_TotalCachingCountJobsEnqueued{ %(filter)s }[$__interval:] offset ${offset}))
              +
              sum(rate(youtrack_TotalCachingJobsNotQueued{ %(filter)s }[$__interval:] offset ${offset}))
            ||| % $,
        },
        // ✅ Queued (per 1 second)
        Queued_jobs_per_sec: {
          unit: $.units.count_per_second,
          current:
            |||
              sum(rate(youtrack_TotalCachingJobsEnqueued{ %(filter)s }[$__interval:]))
              +
              sum(rate(youtrack_TotalCachingCountJobsEnqueued{ %(filter)s }[$__interval:]))
            ||| % $
          ,
          prev:
            |||
              sum(rate(youtrack_TotalCachingJobsEnqueued{ %(filter)s }[$__interval:] offset ${offset}))
              +
              sum(rate(youtrack_TotalCachingCountJobsEnqueued{ %(filter)s }[$__interval:] offset ${offset}))
            ||| % $,
        },
        // ❌ Not Queued (per 1 second)
        NotQueued_jobs_per_sec: {
          unit: $.units.count_per_second,
          current:
            |||
              sum(rate(youtrack_TotalCachingJobsNotQueued{ %(filter)s }[$__interval:]))
            ||| % $
          ,
          prev:
            |||
              sum(rate(youtrack_TotalCachingJobsNotQueued{ %(filter)s }[$__interval:] offset ${offset}))
            ||| % $,
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
              ,
              total: $.Xodus_entity_store_metrics.cached_jobs.Queued__Non_Queued.Queued__and__Non_Queued_per_sec.current,
            }
          ,
          prev:
            |||
              100 * ( %(part)s ) /
              ( ( %(total)s ) != 0 )
            ||| % {
              part: $.Xodus_entity_store_metrics.cached_jobs.Queued__Non_Queued.Queued_jobs_per_sec.prev
              ,
              total: $.Xodus_entity_store_metrics.cached_jobs.Queued__Non_Queued.Queued__and__Non_Queued_per_sec.prev,
            },
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
              ,
              total: $.Xodus_entity_store_metrics.cached_jobs.Queued__Non_Queued.Queued__and__Non_Queued_per_sec.current,
            }
          ,
          prev:
            |||
              100 * ( %(part)s ) /
              ( ( %(total)s ) != 0 )
            ||| % {
              part: $.Xodus_entity_store_metrics.cached_jobs.Queued__Non_Queued.NotQueued_jobs_per_sec.prev
              ,
              total: $.Xodus_entity_store_metrics.cached_jobs.Queued__Non_Queued.Queued__and__Non_Queued_per_sec.prev,
            },
        },
      },

    },
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
        'sum(rate(process_cpu_seconds_total{ %(filter)s }[$__interval:]))' % $,
      prev:
        'sum(rate(process_cpu_seconds_total{ %(filter)s }[$__interval:] offset ${offset}))' % $,
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

  workflows: {
    Rule: {
      average_failed_per_minute: {
        unit: $.units.count_per_minute,
        current: |||
          60 * sum(rate(
              youtrack_Workflow_Rule_FailedCount{
                  %(filter)s
              }[$__interval:]
          ))
        ||| % $,
        prev: |||
          60 * sum(rate(
              youtrack_Workflow_Rule_FailedCount{
                  %(filter)s
              }[$__interval:] offset ${offset}
          ))
        ||| % $,
      },
      total_failed_per_interval: {
        unit: $.units.none,
        current: |||
          sum(increase(
              youtrack_Workflow_Rule_FailedCount{
                  %(filter)s
              }[$__interval:]
          ))
        ||| % $,
        pref: |||
          sum(increase(
              youtrack_Workflow_Rule_FailedCount{
                  %(filter)s
              }[$__interval:] offset ${offset}
          ))
        ||| % $,
      },
      average_events_per_minute: {
        unit: $.units.count_per_minute,
        current: |||
          60 * sum(rate(
              youtrack_Workflow_Rule_TotalCount{
                  %(filter)s
              }[$__interval:]
          ))
        ||| % $,
        prev: |||
          60 * sum(rate(
              youtrack_Workflow_Rule_TotalCount{
                  %(filter)s
              }[$__interval:] offset ${offset}
          ))
        ||| % $,
      },
      average_duration_per_minute: {
        unit: $.units.ms,
        current: |||
          60 * sum(rate(
              youtrack_Workflow_Rule_TotalDuration{
                  %(filter)s
              }[$__interval:]
          ))
        ||| % $,
        prev: |||
          60 * sum(rate(
              youtrack_Workflow_Rule_TotalDuration{
                  %(filter)s
              }[$__interval:] offset ${offset}
          ))
        ||| % $,
      },
      average_duration_per_event: {
        unit: $.units.ms,
        current: |||
          sum(
              increase(
                  youtrack_Workflow_Rule_TotalDuration{
                      %(filter)s
                  }[$__interval:]
              ) /
              (increase(
                  youtrack_Workflow_Rule_TotalCount{
                      %(filter)s
                  }[$__interval:]
              )>0)
          )
        ||| % $,
        prev: |||
          sum(
              increase(
                  youtrack_Workflow_Rule_TotalDuration{
                      %(filter)s
                  }[$__interval:] offset ${offset}
              ) /
              (increase(
                  youtrack_Workflow_Rule_TotalCount{
                      %(filter)s
                  }[$__interval:] offset ${offset}
              )>0)
          )
        ||| % $,
      },
      average_duration_per_hour: {
        unit: $.units.ms,
        current: |||
          3600 * sum(rate(
              youtrack_Workflow_Rule_TotalDuration{
                  %(filter)s
              }[$__interval:]
          ))
        ||| % $,
        prev: |||
          3600 * sum(rate(
              youtrack_Workflow_Rule_TotalDuration{
                  %(filter)s
              }[$__interval:] offset ${offset}
          ))
        ||| % $,
      },
    },
    RuleGuard: {
      average_failed_per_minute: {
        unit: $.units.count_per_minute,
        current: |||
          60 * sum(rate(
              youtrack_Workflow_RuleGuard_FailedCount{
                  %(filter)s
              }[$__interval:]
          ))
        ||| % $,
        prev: |||
          60 * sum(rate(
              youtrack_Workflow_RuleGuard_FailedCount{
                  %(filter)s
              }[$__interval:] offset ${offset}
          ))
        ||| % $,
      },
      total_failed_per_interval: {
        unit: $.units.none,
        current: |||
          sum(increase(
              youtrack_Workflow_RuleGuard_FailedCount{
                  %(filter)s
              }[$__interval:]
          ))
        ||| % $,
        pref: |||
          sum(increase(
              youtrack_Workflow_RuleGuard_FailedCount{
                  %(filter)s
              }[$__interval:] offset ${offset}
          ))
        ||| % $,
      },
      average_events_per_minute: {
        unit: $.units.count_per_minute,
        current: |||
          60 * sum(rate(
              youtrack_Workflow_RuleGuard_TotalCount{
                  %(filter)s
              }[$__interval:]
          ))
        ||| % $,
        prev: |||
          60 * sum(rate(
              youtrack_Workflow_RuleGuard_TotalCount{
                  %(filter)s
              }[$__interval:] offset ${offset}
          ))
        ||| % $,
      },
      average_duration_per_minute: {
        unit: $.units.ms,
        current: |||
          60 * sum(rate(
              youtrack_Workflow_RuleGuard_TotalDuration{
                  %(filter)s
              }[$__interval:]
          ))
        ||| % $,
        prev: |||
          60 * sum(rate(
              youtrack_Workflow_RuleGuard_TotalDuration{
                  %(filter)s
              }[$__interval:] offset ${offset}
          ))
        ||| % $,
      },
      average_duration_per_event: {
        unit: $.units.ms,
        current: |||
          sum(
              increase(
                  youtrack_Workflow_RuleGuard_TotalDuration{
                      %(filter)s
                  }[$__interval:]
              ) /
              (increase(
                  youtrack_Workflow_RuleGuard_TotalCount{
                      %(filter)s
                  }[$__interval:]
              )>0)
          )
        ||| % $,
        prev: |||
          sum(
              increase(
                  youtrack_Workflow_RuleGuard_TotalDuration{
                      %(filter)s
                  }[$__interval:] offset ${offset}
              ) /
              (increase(
                  youtrack_Workflow_RuleGuard_TotalCount{
                      %(filter)s
                  }[$__interval:] offset ${offset}
              )>0)
          )
        ||| % $,
      },
      average_duration_per_hour: {
        unit: $.units.ms,
        current: |||
          3600 * sum(rate(
              youtrack_Workflow_RuleGuard_TotalDuration{
                  %(filter)s
              }[$__interval:]
          ))
        ||| % $,
        prev: |||
          3600 * sum(rate(
              youtrack_Workflow_RuleGuard_TotalDuration{
                  %(filter)s
              }[$__interval:] offset ${offset}
          ))
        ||| % $,
      },
    },
    OnScheduleFull: {
      average_failed_per_minute: {
        unit: $.units.count_per_minute,
        current: |||
          60 * sum(rate(
              youtrack_Workflow_OnScheduleFull_FailedCount{
                  %(filter)s
              }[$__interval:]
          ))
        ||| % $,
        prev: |||
          60 * sum(rate(
              youtrack_Workflow_OnScheduleFull_FailedCount{
                  %(filter)s
              }[$__interval:] offset ${offset}
          ))
        ||| % $,
      },
      total_failed_per_interval: {
        unit: $.units.none,
        current: |||
          sum by(increase(
              youtrack_Workflow_OnScheduleFull_FailedCount{
                  %(filter)s
              }[$__interval:]
          ))
        ||| % $,
        pref: |||
          sum by(increase(
              youtrack_Workflow_OnScheduleFull_FailedCount{
                  %(filter)s
              }[$__interval:] offset ${offset}
          ))
        ||| % $,
      },
      average_events_per_minute: {
        unit: $.units.count_per_minute,
        current: |||
          60 * sum(rate(
              youtrack_Workflow_OnScheduleFull_TotalCount{
                  %(filter)s
              }[$__interval:]
          ))
        ||| % $,
        prev: |||
          60 * sum(rate(
              youtrack_Workflow_OnScheduleFull_TotalCount{
                  %(filter)s
              }[$__interval:] offset ${offset}
          ))
        ||| % $,
      },
      average_duration_per_minute: {
        unit: $.units.ms,
        current: |||
          60 * sum(rate(
              youtrack_Workflow_OnScheduleFull_TotalDuration{
                  %(filter)s
              }[$__interval:]
          ))
        ||| % $,
        prev: |||
          60 * sum(rate(
              youtrack_Workflow_OnScheduleFull_TotalDuration{
                  %(filter)s
              }[$__interval:] offset ${offset}
          ))
        ||| % $,
      },
      average_duration_per_event: {
        unit: $.units.ms,
        current: |||
          sum(
              increase(
                  youtrack_Workflow_OnScheduleFull_TotalDuration{
                      %(filter)s
                  }[$__interval:]
              ) /
              (increase(
                  youtrack_Workflow_OnScheduleFull_TotalCount{
                      %(filter)s
                  }[$__interval:]
              )>0)
          )
        ||| % $,
        prev: |||
          sum(
              increase(
                  youtrack_Workflow_OnScheduleFull_TotalDuration{
                      %(filter)s
                  }[$__interval:] offset ${offset}
              ) /
              (increase(
                  youtrack_Workflow_OnScheduleFull_TotalCount{
                      %(filter)s
                  }[$__interval:] offset ${offset}
              )>0)
          )
        ||| % $,
      },
      average_duration_per_hour: {
        unit: $.units.ms,
        current: |||
          3600 * sum(rate(
              youtrack_Workflow_OnScheduleFull_TotalDuration{
                  %(filter)s
              }[$__interval:]
          ))
        ||| % $,
        prev: |||
          3600 * sum(rate(
              youtrack_Workflow_OnScheduleFull_TotalDuration{
                  %(filter)s
              }[$__interval:] offset ${offset}
          ))
        ||| % $,
      },
    },

    Rule_Total: {
        TotalDuration:
        |||
            sum_over_time(
                (
                    sum(
                        increase(
                            label_replace(
                                youtrack_Workflow_Rule_TotalDuration{
                                    %(filter)s
                                },
                                "group", "❇️ Rule", "script", ".*"
                            )[$__interval:]
                        )
                    ) by (script, group)
                )[$__range:$__interval]
            )
        ||| % $,
        TotalCount:
        |||
            sum_over_time(
                (
                    sum(
                        increase(
                            label_replace(
                                youtrack_Workflow_Rule_TotalCount{
                                    %(filter)s
                                },
                                "group", "❇️ Rule", "script", ".*"
                            )[$__interval:]
                        )
                    ) by (script, group)
                )[$__range:$__interval]
            )
        ||| % $,
        FailedCount:
        |||
            sum_over_time(
                (
                    sum(
                        increase(
                            label_replace(
                                youtrack_Workflow_Rule_FailedCount{
                                    %(filter)s
                                },
                                "group", "❇️ Rule", "script", ".*"
                            )[$__interval:]
                        )
                    ) by (script, group)
                )[$__range:$__interval]
            )
        ||| % $,
    },
    RuleGuard_Total: {
        TotalDuration:
        |||
            sum_over_time(
                (
                    sum(
                        increase(
                            label_replace(
                                youtrack_Workflow_RuleGuard_TotalDuration{
                                    %(filter)s
                                },
                                "group", "🛡 Rule Guard", "script", ".*"
                            )[$__interval:]
                        )
                    ) by (script, group)
                )[$__range:$__interval]
            )
        ||| % $,
        TotalCount:
        |||
            sum_over_time(
                (
                    sum(
                        increase(
                            label_replace(
                                youtrack_Workflow_RuleGuard_TotalCount{
                                    %(filter)s
                                },
                                "group", "🛡 Rule Guard", "script", ".*"
                            )[$__interval:]
                        )
                    ) by (script, group)
                )[$__range:$__interval]
            )
        ||| % $,
        FailedCount:
        |||
            sum_over_time(
                (
                    sum(
                        increase(
                            label_replace(
                                youtrack_Workflow_RuleGuard_FailedCount{
                                    %(filter)s
                                },
                                "group", "🛡 Rule Guard", "script", ".*"
                            )[$__interval:]
                        )
                    ) by (script, group)
                )[$__range:$__interval]
            )
        ||| % $,
    },
    OnScheduleFull_Total: {
        TotalDuration:
        |||
            sum_over_time(
                (
                    sum(
                        increase(
                            label_replace(
                                youtrack_Workflow_OnScheduleFull_TotalDuration{
                                    %(filter)s
                                },
                                "group", "🗓 On Schedule Full", "script", ".*"
                            )[$__interval:]
                        )
                    ) by (script, group)
                )[$__range:$__interval]
            )
        ||| % $,
        TotalCount:
        |||
            sum_over_time(
                (
                    sum(
                        increase(
                            label_replace(
                                youtrack_Workflow_OnScheduleFull_TotalCount{
                                    %(filter)s
                                },
                                "group", "🗓 On Schedule Full", "script", ".*"
                            )[$__interval:]
                        )
                    ) by (script, group)
                )[$__range:$__interval]
            )
        ||| % $,
        FailedCount:
        |||
            sum_over_time(
                (
                    sum(
                        increase(
                            label_replace(
                                youtrack_Workflow_OnScheduleFull_FailedCount{
                                    %(filter)s
                                },
                                "group", "🗓 On Schedule Full", "script", ".*"
                            )[$__interval:]
                        )
                    ) by (script, group)
                )[$__range:$__interval]
            )
        ||| % $,
    },
  },
}
