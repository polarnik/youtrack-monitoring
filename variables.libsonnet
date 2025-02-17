local g = import './g.libsonnet';
local var = g.dashboard.variable;

{
    datasource:
        var.datasource.new('source', 'prometheus'),

    offset:
        var.custom.new('offset', ['7d', '14d', '21d'])
        + var.custom.generalOptions.withCurrent('7d', '7d'),

    diff_interval:
        var.custom.new('diff_interval', ['1h', '2h', '3h', '4h', '5h', '6h', '12h', '1d', '2d', '3d', '4d', '7d'])
        + var.custom.generalOptions.withCurrent('3h', '3h'),

    queryResult(query):
    {
        "definition": 'query_result(' + query + ')',
        "options": [],
        "query": {
            "query": 'query_result(' + query + ')',
            "qryType": 3,
            "refId": "PrometheusVariableQueryEditor-VariableQuery"
        },
        "sort": 0,
        "skipUrlSync": false,
        "hide": 0,
        "type": "query"
    },


    instance:
        var.query.new('instance',std.strReplace(
        |||
            query_result(sort_desc(
                sum by (instance) (
                youtrack_UserSessions_ActiveUsers{}
                ) > 0))
        |||, '\n', ''))
        + var.query.withDatasourceFromVariable(self.datasource)
        + var.query.withRegex('/{instance="(.*)"}.*/')
        + var.query.refresh.onTime()
        + var.custom.selectionOptions.withMulti(false),

    app_start:
        var.custom.new('app_start', [
            { key: "✅ Yes", value: "1"},
            { key: "🔳 No", value: "0"}
        ] )
        + var.custom.generalOptions.withLabel('Show app start')
        + var.custom.generalOptions.withCurrent("✅ Yes", "1")
        + var.custom.selectionOptions.withMulti(false),

    workflow_group:
        var.custom.new('workflow_group', [
            { key:   "RuleGuard",
              value: "🛡 Rule Guard"},
            { key:   "Rule",
              value: "❇️ Rule"},
            { key:   "OnScheduleFull",
              value: "🗓 On Schedule Full"},
        ] )
        + var.custom.generalOptions.withLabel('Workflow group')
        + var.custom.generalOptions.withCurrent("Rule", "❇️ Rule")
        + var.custom.selectionOptions.withMulti(false),

    workflow_script:
        var.query.new('script',std.strReplace(std.strReplace(std.strReplace(std.strReplace(
        |||
            query_result(sort_desc(
                sum_over_time(
                    (
                        sum(
                            increase(
                            youtrack_Workflow_${workflow_group:text}_TotalDuration{
                                        instance=~"$instance"
                                     }[1m:]
                            )
                        ) by (script)
                    )[$__range:1m]
                )
            ))
        |||, '  ', ''),'\n ', ''),'  ', ''), '\n', ''))
        + var.query.withDatasourceFromVariable(self.datasource)
        + var.query.withRegex('/{script="(.*)"}.*/')
        + var.query.refresh.onTime()
        + var.custom.selectionOptions.withMulti(false),

    interval:
        var.custom.new('interval', [
            { key: "1m", value: "60"},
            { key: "5m", value: "300"},
            { key: "10m", value: "600"},
            { key: "15m", value: "900"},
            { key: "30m", value: "1800"},
            { key: "1h", value: "3600"},
            { key: "2h", value: "7200"},
            { key: "3h", value: "10800"},
        ] )
        + var.custom.generalOptions.withLabel('interval')
        + var.custom.generalOptions.withCurrent("1h", "3600")
        + var.custom.selectionOptions.withMulti(false),

}