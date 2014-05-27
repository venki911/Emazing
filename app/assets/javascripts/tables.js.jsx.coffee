###* @jsx React.DOM ###

{a, table, thead, tr, tbody, th, td, span} = React.DOM

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

    query = "order[by]=#{params.order.by}&order[direction]=#{params.order.direction}"
    url = "#{location.pathname}.json?#{query}"
    console.log url
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

    filters = @state.data.column_headers.map ((header) ->
      header_summary = switch header.summary.type
        when 'date_filter', 'text_filter' then (a {href: "#", className: header.summary.type, onClick: @openFilter}, header.summary.value)
        when 'float_sum', 'integer_sum', 'custom_sum' then (span {className: header.summary.type}, header.summary.value)
        else (span {className: header.summary.type}, header.summary.value)

      (th {}, header_summary)).bind(this)

    rows = @state.data.rows.map (row) ->
      class_name = 'danger' if row.profitability < 0
      class_name = 'success' if row.profitability > 0

      (tr {className:class_name}, [
        (td {title: row.date}, (span {}, row.date)),
        (td {title: row.source}, (span {}, row.source)),
        (td {title: row.campaign}, (span {}, row.campaign)),
        (td {title: row.medium}, (span {}, row.medium)),
        (td {title: row.ad_content}, (span {}, row.ad_content)),
        (td {title: row.keyword}, (span {}, row.keyword)),
        (td {}, (span {}, row.ad_cost)),
        (td {}, (span {}, row.ad_clicks)),
        (td {}, (span {}, row.sessions)),
        (td {}, (span {}, row.item_quantity)),
        (td {}, (span {}, row.transaction_revenue)),
        (td {}, (span {}, row.transactions)),
        (td {}, (span {}, row.revenue)),
        (td {}, (span {}, row.profit)),
        (td {}, (span {}, row.profitability))
      ])

    (table {className: "table table-striped table-condensed report_records", onClick: @filter}, [
      (thead {}, [
        (tr {className: "headers"}, column_headers),
        (tr {className: "filters"}, filters)
      ])
      (tbody {}, rows)
    ])

React.renderComponent (TableReport {}), document.getElementById('table_report') if document.getElementById('table_report')
