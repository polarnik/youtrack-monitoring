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
                youtrack_UtilizationPercent{}
                ) > 0))
        |||, '\n', ''))
        + var.query.withDatasourceFromVariable(self.datasource)
        + var.query.withRegex('/{instance="(.*)"}.*/')
        + var.query.refresh.onTime()
        + var.custom.selectionOptions.withMulti(false),

    app_start:
        var.custom.new('app_start', [ { key: "✅ Yes", value: "1"}, { key: "🔳 No", value: "0"} ] )
        + var.custom.generalOptions.withLabel('Show app start')
        + var.custom.generalOptions.withCurrent("✅ Yes", "1")
        + var.custom.selectionOptions.withMulti(false)
}