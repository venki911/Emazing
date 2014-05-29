###* @jsx React.DOM ###

{a, table, thead, tr, tbody, th, td, span} = React.DOM

Currency = React.createClass
  render: ->
    (span {className: 'currency'},
      (span {className: 'unit'}, '€ '),
      (span {className: 'number'}, parseFloat(@props.value).toFixed(2) if @props.value))

Percentage = React.createClass
  render: ->
    if @props.value
      (span {className: 'percentage'}, "#{@props.value}%")
    else
      (span {className: 'percentage no-value'}, 'n/a')

TableReport = React.createClass
  getInitialState: ->
    { data: column_headers: [], rows: [] }

  # getURL()
  # transaforms
  #   url_query: { order: { by: 'source', direction: 'asc' }, filter: { source: ['emazing', 'google'], medium: ['facebook'] } }
  # to
  #   "/ga_exports.json?order[by]=source&order[direction]=asc&filter[source][]=emazing&filter[source][]=google&filter[medium][]=facebook"
  getURL: (params) ->
    # url_query = @state.url_query
    # query_sections = Object.keys(url_query).map (value, index) ->
    #   params = url_query[value]
    #   if value == 'order'
    #     query_section = "order[by]=#{params.by}&order[direction]=#{params.direction}"
    #   if value == 'filter'
    #     filter_queries = Object.keys(params).map (column_name, index) ->
    #       column_values = params[column_name] # ['emazing']
    #       queries = column_values.map (value) ->
    #         "filter[#{column_name}][]=#{value}"
    #       column_filter_query = queries.join('&')
    #     query_section = filter_queries.join('&')
    #   query_section
    # url = "#{location.pathname}.json?#{query_sections.join('&')}"

    query = "order[by]=#{params.order.by}&order[direction]=#{params.order.direction}&filter[source][]=emazing"
    url = "#{location.pathname}.json?#{query}"
    url

  loadReportFromServer: (params) ->
    $.ajax
      url: @getURL(params)
      dataType: 'json'
      success: ((data) ->
        @setState
          data: data
          query: params
      ).bind(this)
      error: ((xhr, status, error) ->
        alert(status)
      ).bind(this)

  componentWillMount: ->
    @loadReportFromServer({order: {by: 'date', direction: 'desc'}})

  toggleSort: (header) ->
    if header.summary.type == 'text_filter'
      direction = 'asc'
      direction = 'asc' if @state.query.order.direction == 'desc' && header.name == @state.query.order.by
      direction = 'desc' if @state.query.order.direction == 'asc' && header.name == @state.query.order.by
    else
      direction = 'desc'
      direction = 'asc' if @state.query.order.direction == 'desc' && header.name == @state.query.order.by
      direction = 'desc' if @state.query.order.direction == 'asc' && header.name == @state.query.order.by

    @loadReportFromServer({order: {by: header.name, direction: direction}})

  openFilter: ->
    return false;

  render: ->
    column_headers = @state.data.column_headers.map ((header) ->
      class_name = 'sorting'
      class_name = "sorting_desc" if header.name == @state.query.order.by && @state.query.order.direction == 'desc'
      class_name = "sorting_asc" if header.name == @state.query.order.by && @state.query.order.direction == 'asc'
      (th {className: class_name, 'data-column-name': header.name}, (span {onClick: @toggleSort.bind(this, header)}, header.title))).bind(this)

    if @state.data.column_headers.length > 0
      filters = [
        (th {}, (a {href: "#", className: @state.data.column_headers[0].summary.type, onClick: @openFilter}, @state.data.column_headers[0].summary.value)),
        (th {}, (a {href: "#", className: @state.data.column_headers[1].summary.type, onClick: @openFilter}, @state.data.column_headers[1].summary.value)),
        (th {}, (a {href: "#", className: @state.data.column_headers[2].summary.type, onClick: @openFilter}, @state.data.column_headers[2].summary.value)),
        (th {}, (a {href: "#", className: @state.data.column_headers[3].summary.type, onClick: @openFilter}, @state.data.column_headers[3].summary.value)),
        (th {}, (a {href: "#", className: @state.data.column_headers[4].summary.type, onClick: @openFilter}, @state.data.column_headers[4].summary.value)),
        (th {}, (a {href: "#", className: @state.data.column_headers[5].summary.type, onClick: @openFilter}, @state.data.column_headers[5].summary.value)),
        (th {}, (span {className: @state.data.column_headers[6].summary.type}, Currency({value: @state.data.column_headers[6].summary.value}))),
        (th {}, (span {className: @state.data.column_headers[7].summary.type}, @state.data.column_headers[7].summary.value)),
        (th {}, (span {className: @state.data.column_headers[8].summary.type}, @state.data.column_headers[8].summary.value)),
        (th {}, (span {className: @state.data.column_headers[9].summary.type}, @state.data.column_headers[9].summary.value)),
        (th {}, (span {className: @state.data.column_headers[10].summary.type}, Currency({value: @state.data.column_headers[10].summary.value}))),
        (th {}, (span {className: @state.data.column_headers[11].summary.type}, @state.data.column_headers[11].summary.value)),
        (th {}, (span {className: @state.data.column_headers[12].summary.type}, Currency({value: @state.data.column_headers[12].summary.value}))),
        (th {}, (span {className: @state.data.column_headers[13].summary.type}, Currency({value: @state.data.column_headers[13].summary.value}))),
        (th {}, (span {className: @state.data.column_headers[14].summary.type}, Percentage({value: @state.data.column_headers[14].summary.value})))]
    else
      filters = []

    rows = @state.data.rows.map (row) ->
      class_name = 'danger' if row.profitability < 0
      class_name = 'success' if row.profitability > 0
      class_name = 'success' if row.profitability == null && row.profit > 0

      (tr {className:class_name}, [
        (td {title: row.date}, (span {className: 'cell_wrap'}, row.date)),
        (td {title: row.source}, (span {className: 'cell_wrap'}, row.source)),
        (td {title: row.campaign}, (span {className: 'cell_wrap'}, row.campaign)),
        (td {title: row.medium}, (span {className: 'cell_wrap'}, row.medium)),
        (td {title: row.ad_content}, (span {className: 'cell_wrap'}, row.ad_content)),
        (td {title: row.keyword}, (span {className: 'cell_wrap'}, row.keyword)),
        (td {}, (span {className: 'cell_wrap'}, Currency({value: row.ad_cost}))),
        (td {}, (span {className: 'cell_wrap'}, row.ad_clicks)),
        (td {}, (span {className: 'cell_wrap'}, row.sessions)),
        (td {}, (span {className: 'cell_wrap'}, row.item_quantity)),
        (td {}, (span {className: 'cell_wrap'}, Currency({value: row.transaction_revenue}))),
        (td {}, (span {className: 'cell_wrap'}, row.transactions)),
        (td {}, (span {className: 'cell_wrap'}, Currency({value: row.revenue}))),
        (td {}, (span {className: 'cell_wrap'}, Currency({value: row.profit}))),
        (td {}, (span {className: 'cell_wrap'}, Percentage({value: row.profitability})))
      ])

    (table {className: "table table-striped table-condensed report_records", onClick: @filter}, [
      (thead {}, [
        (tr {className: "headers"}, column_headers),
        (tr {className: "filters"}, filters)
      ]),
      (tbody {}, rows)
    ])

React.renderComponent (TableReport {}), document.getElementById('table_report') if document.getElementById('table_report')
