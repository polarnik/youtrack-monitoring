local variables = import './variables.libsonnet';
local g = import 'g.libsonnet';

{
  local util_one_link_dashboard(title, UID) = {
    "title": title,
    "url": "/d/%(UID)s?${__all_variables}&${__url_time_range}" % {UID: UID},
    "targetBlank": true
  },
  one_link(title, UID): util_one_link_dashboard(title, UID),
  local util_link_panel(links) = {
      "links": [
          util_one_link_dashboard(link.title, link.UID) for link in links
        ]
  },
  link_panel(links): util_link_panel(links),

    local util_link_data_row(links) = {
        "fieldConfig": {
            "defaults": {
            "links": [
                util_one_link_dashboard(link.title, link.UID) for link in links
            ]
            }
        }
    },
    link_data_row(links): util_link_data_row(links),

  local one_tag_link(tag) = {
        "title": tag,
        "tags": [
          tag
        ],
        "asDropdown": true,
        "icon": "external link",
        "includeVars": true,
        "keepTime": true,
        "targetBlank": true,
        "tooltip": "",
        "type": "dashboards",
        "url": ""
  },
  local tag_links(tags) = {
    "links": [
        one_tag_link(tag) for tag in tags
    ]
  },
  links(tags): tag_links(tags),

  combo: {
    local timeSeries = g.panel.timeSeries,

    stat: {
      local stat = g.panel.stat,
      /*
       *  Большее значение сейчас -- лучше, меньшее значение сейчас -- хуже.
       *  Hапример -- процент успешности выполнения транзакций.
       *  Нам важно не допустить падения значения. Например, было неделю назад 100, сейчас стало 80.
       *  Чем ниже, тем краснее
       */
      a_bigger_value_is_better(title, target):
        self.base_stat(title + ' (last $diff_interval vs $offset ago)', target)
        + {
          timeFrom: '$diff_interval',
          maxDataPoints: 300,
          interval: "3m",
          hideTimeOverride: true,

          fieldConfig: {
            defaults: {
              mappings: [],
              thresholds: {
                mode: 'absolute',
                steps: [
                  {
                    color: 'green',
                    value: null,
                  },
                  {
                    color: 'dark-red',
                    value: -60,
                  },
                  {
                    color: 'red',
                    value: -50,
                  },
                  {
                    value: -50,
                    color: '#EAB839',
                  },
                  {
                    color: 'orange',
                    value: -40,
                  },
                  {
                    color: 'yellow',
                    value: -30,
                  },
                  {
                    color: 'blue',
                    value: -20,
                  },
                  {
                    color: '#8e3bb84d',
                    value: -10,
                  },
                  {
                    value: 0,
                    color: '#ffffff',
                  },
                  {
                    value: 10,
                    color: 'super-light-green',
                  },
                  {
                    value: 20,
                    color: 'light-green',
                  },
                  {
                    value: 30,
                    color: 'green',
                  },
                  {
                    value: 40,
                    color: 'semi-dark-green',
                  },
                  {
                    value: 50,
                    color: 'dark-green',
                  },
                ],
              },
              color: {
                mode: 'thresholds',
              },
              unit: 'percent',
            },
            overrides: [],
          },
        }
      ,

      /*
       *  Большее значение сейчас -- хуже, меньшее значение сейчас -- лучше.
       *  Чем больше дельта, тем хуже.
       *  Измеряется процент роста текущего значения к значению до
       *  Hапример -- количество ошибок или длительность. Количество ошибок было 20, стало 100. Рост х4 или (100 - 20)/20.
       *  Чем выше, тем краснее
       */
      a_bigger_value_is_a_problem(title, target):
        self.base_stat(title + ' (last $diff_interval vs $offset ago)', target)
        + {
          timeFrom: '$diff_interval',
          maxDataPoints: 300,
          interval: "3m",
          hideTimeOverride: true,

          fieldConfig: {
            defaults: {
              mappings: [],
              thresholds: {
                mode: 'absolute',
                steps: [
                  {
                    color: '#8e3bb84d',
                    value: null,
                  },
                  {
                    color: 'blue',
                    value: 10,
                  },
                  {
                    color: 'green',
                    value: 20,
                  },
                  {
                    color: 'yellow',
                    value: 30,
                  },
                  {
                    color: 'orange',
                    value: 40,
                  },
                  {
                    color: 'red',
                    value: 50,
                  },
                  {
                    color: 'dark-red',
                    value: 60,
                  },
                ],
              },
              color: {
                mode: 'thresholds',
              },
              unit: 'percent',
            },
            overrides: [],
          },
        }
      ,

      base_stat(title, target):
        stat.new(title)
        + stat.options.reduceOptions.withValues(false)
        + stat.options.reduceOptions.withCalcs('mean')
        + stat.options.withWideLayout(true)
        + stat.options.withColorMode('background')
        + stat.options.withGraphMode('none')

        + stat.gridPos.withH(7)
        + stat.gridPos.withW(4)
        + stat.gridPos.withX(0)

        + stat.datasource.withType('prometheus')
        + stat.datasource.withUid('${' + variables.datasource.name + '}')
        + stat.queryOptions.withTargets(target),
    },

    timeSeries: {
      current_vs_prev(title, target, unit):
        timeSeries.new(title + ' (🟥 current vs 🟦 prev)')
        + timeSeries.gridPos.withH(7)
        + timeSeries.gridPos.withW(20)
        + timeSeries.gridPos.withX(4)
        + timeSeries.datasource.withType('prometheus')
        + timeSeries.datasource.withUid('${' + variables.datasource.name + '}')
        + timeSeries.queryOptions.withTargets(target)
        + {
          maxDataPoints: 300,
          interval: "3m",
          options: {
            tooltip: {
              mode: 'multi',
              sort: 'none',
            },
            legend: {
              showLegend: false,
              displayMode: 'list',
              placement: 'bottom',
              calcs: [],
            },
          },
          fieldConfig: {
            defaults: {
              custom: {
                drawStyle: 'line',
                lineInterpolation: 'smooth',
                barAlignment: 0,
                lineWidth: 1,
                fillOpacity: 30,
                gradientMode: 'opacity',
                spanNulls: false,
                insertNulls: false,
                showPoints: 'never',
                pointSize: 5,
                stacking: {
                  mode: 'none',
                  group: 'A',
                },
                axisPlacement: 'auto',
                axisLabel: '',
                axisColorMode: 'text',
                axisBorderShow: false,
                scaleDistribution: {
                  type: 'linear',
                },
                axisCenteredZero: false,
                hideFrom: {
                  tooltip: false,
                  viz: false,
                  legend: false,
                },
                thresholdsStyle: {
                  mode: 'off',
                },
                axisWidth: 65,
              },
              color: {
                mode: 'palette-classic',
              },
              mappings: [],
              thresholds: {
                mode: 'absolute',
                steps: [
                  {
                    color: 'green',
                    value: null,
                  },
                  {
                    color: 'red',
                    value: 80,
                  },
                ],
              },
              fieldMinMax: false,
              unit: 'none',
            },
            overrides: [
              {
                matcher: {
                  id: 'byFrameRefID',
                  options: 'current',
                },
                properties: [
                  {
                    id: 'custom.lineWidth',
                    value: 5,
                  },
                  {
                    id: 'color',
                    value: {
                      fixedColor: 'red',
                      mode: 'fixed',
                    },
                  },
                ],
              },
              {
                matcher: {
                  id: 'byFrameRefID',
                  options: 'prev',
                },
                properties: [
                  {
                    id: 'color',
                    value: {
                      fixedColor: 'dark-blue',
                      mode: 'fixed',
                    },
                  },
                ],
              },
              {
                matcher: {
                  id: 'byFrameRefID',
                  options: 'diff',
                },
                properties: [
                  {
                    id: 'custom.lineStyle',
                    value: {
                      fill: 'solid',
                    },
                  },
                  {
                    id: 'custom.axisPlacement',
                    value: 'hidden',
                  },
                  {
                    id: 'color',
                    value: {
                      fixedColor: 'yellow',
                      mode: 'fixed',
                    },
                  },
                  {
                    id: 'custom.fillOpacity',
                    value: 0,
                  },
                  {
                    id: 'unit',
                    value: 'percent',
                  },
                  {
                    id: 'custom.lineWidth',
                    value: 0,
                  },
                ],
              },
              {
                matcher: {
                  id: 'byFrameRefID',
                  options: 'start',
                },
                properties: [
                  {
                    id: 'custom.drawStyle',
                    value: 'bars',
                  },
                  {
                    id: 'custom.lineWidth',
                    value: 2,
                  },
                  {
                    id: 'custom.axisPlacement',
                    value: 'right',
                  },
                  {
                    id: 'custom.axisSoftMin',
                    value: 0,
                  },
                  {
                    id: 'custom.axisSoftMax',
                    value: 1,
                  },
                  {
                    id: 'color',
                    value: {
                      fixedColor: 'green',
                      mode: 'fixed',
                    },
                  },
                  {
                    id: 'unit',
                    value: 'bool_yes_no',
                  },
                  {
                    id: 'custom.axisWidth',
                    value: 1,
                  },
                ],
              },
            ],
          },
        }
        + timeSeries.standardOptions.withUnit(unit),

    },
  },

  diagram: {
    base():
    {
      "datasource": {
        "type": "grafana",
        "uid": "grafana"
      },
      "fieldConfig": {
        "defaults": {
          "custom": {
            "valueName": "last"
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          }
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 12,
        "y": 9
      },
      "id": 17,
      "options": {
        "useBackground": false,
        "content": "%%{ init: { 'flowchart': { 'curve': 'monotoneX' } } }%%\nflowchart LR\n    A(⚙️ Cached Jobs) ==> B(✅ Queued)\n    A(⚙️ Cached Jobs) -.-> C(❌ Non Queued)\n    B ==> D(🟡 Consistent)\n    B ==> E(🟠 Non Consistent)\n    D ==> F(🛠 Execute)\n    E ==> F\n    F ==> G(✳️ Started)\n    F -.-> H(⛔️ Not Started)\n    G -.-> I(↩️ Retried)\n    G ==> J(❎ Completed)\n    G -.-> K(🚫️ Interrupted)\n    I -.-> L(🟡 Consistent)\n    I -.-> M(🟠 Non Consistent)\n    K -.-> N(⌛️ Obsolete)\n    K -.-> O(⏰ Overdue)",
        "nodeSize": {
          "minWidth": 30,
          "minHeight": 30
        },
        "legend": {
          "show": false,
          "asTable": true,
          "displayMode": "table",
          "gradient": {
            "enabled": true,
            "show": true
          },
          "hideEmpty": false,
          "hideZero": false,
          "placement": "bottom",
          "sortBy": "last",
          "sortDesc": true,
          "stats": [
            "mean",
            "last",
            "min",
            "max",
            "sum"
          ]
        },
        "mermaidThemeVariablesDark": {
          "common": {
            "fontFamily": "Roboto,Helvetica Neue,Arial,sans-serif"
          },
          "classDiagram": {},
          "flowChart": {},
          "sequenceDiagram": {},
          "stateDiagram": {},
          "userJourneyDiagram": {}
        },
        "mermaidThemeVariablesLight": {
          "common": {
            "fontFamily": "Roboto,Helvetica Neue,Arial,sans-serif"
          },
          "classDiagram": {},
          "flowChart": {},
          "sequenceDiagram": {},
          "stateDiagram": {},
          "userJourneyDiagram": {}
        },
        "style": "",
        "authPassword": "",
        "authUsername": "",
        "composites": [],
        "maxWidth": true,
        "mermaidServiceUrl": "",
        "metricCharacterReplacements": [],
        "moddedSeriesVal": 0,
        "mode": "content",
        "pluginVersion": "",
        "useBasicAuth": false,
        "valueName": "last"
      },
      "pluginVersion": "1.10.4",
      "targets": [
        {
          "datasource": {
            "type": "datasource",
            "uid": "grafana"
          },
          "queryType": "randomWalk",
          "refId": "A"
        }
      ],
      "transparent": true,
      "type": "jdbranham-diagram-panel"
    }
  },

  texts: {
    local text = g.panel.text,
    local canvas = g.panel.canvas,

    image(url):
        $.texts.base(
        "<img src='" + url + "' style='height: 100%' />"
        )
        + text.gridPos.withW(24),

    base(content):
        text.new('')
         + text.gridPos.withH(7)
         + text.gridPos.withW(4)
         + text.gridPos.withX(0)
         + text.options.withMode('markdown')
         + text.options.code.withLanguage('plaintext')
         + text.options.code.withShowLineNumbers(false)
         + text.options.code.withShowMiniMap(false)
         + text.options.withContent(content)
         ,

    version:
      $.texts.base(
        |||
          ### Version of <a href="https://www.jetbrains.com/youtrack/" target="_blank" rel="author" title="YouTrack. Project management for all your teams"><img src="https://youtrack.jetbrains.com/youtrack-wide-dark.svg" height="30" /></a>
          Different colours 🟩🟨🟦 are different versions.

          Move a cursor 👆to the head of the line to get version info.
        |||
      ),

  },
  timeseries: {
    local timeSeries = g.panel.timeSeries,

    base(title, targets):
      timeSeries.new(title)
      + timeSeries.queryOptions.withTargets(targets)
      + timeSeries.fieldConfig.defaults.custom.withAxisWidth(65)
      + timeSeries.gridPos.withH(7)
      + timeSeries.gridPos.withW(20)
      + timeSeries.gridPos.withX(4)
      + timeSeries.datasource.withType('prometheus')
      + timeSeries.datasource.withUid('${' + variables.datasource.name + '}'),

    version(title, targets):
      $.timeseries.base(title, targets)
      + timeSeries.queryOptions.withMaxDataPoints(300)
      + timeSeries.queryOptions.withInterval('3m')
      + timeSeries.options.withTooltipMixin({
        hoverProximity: 30,
        mode: 'single',
        sort: 'desc',
      })
      + timeSeries.options.legend.withShowLegend(false)
      + timeSeries.options.legend.withIsVisible(false)
      + timeSeries.fieldConfig.defaults.custom.withLineWidth(10)
      + timeSeries.fieldConfig.defaults.custom.withShowPoints('never')
      + timeSeries.fieldConfig.defaults.custom.withFillOpacity(100)
      + timeSeries.fieldConfig.defaults.custom.withDrawStyle('line')
      + timeSeries.fieldConfig.defaults.custom.withGradientMode('opacity')
      + timeSeries.standardOptions.withUnit('none')
      + timeSeries.standardOptions.withMin(0)
      + timeSeries.standardOptions.withMax(1)
      + timeSeries.standardOptions.withDecimals(0)
      + {
        transformations: [
          {
            id: 'merge',
            options: {},
          },
          {
            id: 'filterByValue',
            options: {
              filters: [
                {
                  config: {
                    id: 'regex',
                    options: {
                      value: '.+',
                    },
                  },
                  fieldName: 'Version',
                },
                {
                  config: {
                    id: 'regex',
                    options: {
                      value: '.+',
                    },
                  },
                  fieldName: 'Build',
                },
              ],
              match: 'all',
              type: 'include',
            },
          },
          {
            id: 'organize',
            options: {
              excludeByName: {
                'Value #Build': true,
                instance: true,
              },
              includeByName: {},
              indexByName: {
                Build: 3,
                Time: 0,
                'Value #Build': 5,
                'Value #Version': 4,
                Version: 2,
                instance: 1,
              },
              renameByName: {
                'Value #Version': 'Version info',
              },
            },
          },
          {
            id: 'prepareTimeSeries',
            options: {
              format: 'multi',
            },
          },
        ],
      },

  },
}
