{a, table, thead, tr, tbody, th, td, span, form, input, select, label, div, i, b} = React.DOM
{OverlayTrigger, Popover, Button} = ReactBootstrap

Currency = React.createClass
  displayName: 'Currency'
  render: ->
    (span {className: 'currency'},
      (span {className: 'unit'}, '€ '),
      (span {className: 'number'}, parseFloat(@props.value).toFixed(2) unless @props.value == null))

Percentage = React.createClass
  displayName: 'Percentage'
  render: ->
    if @props.value
      (span {className: 'percentage'}, "#{parseFloat(@props.value).toFixed(3)}%")
    else
      (span {className: 'percentage no-value'}, 'n/a')

Float = React.createClass
  displayName: 'Float'
  render: ->
    if @props.value
      (span {className: 'float'}, parseFloat(@props.value).toFixed(2))
    else
      (span {className: 'float no-value'}, 'n/a')

DateRangePicker = React.createClass
  displayName: 'DateRangePicker'
  componentDidMount: ->
    _this = this

    options = 
      opens: @props.opens
      startDate: @props.startDate
      endDate: @props.endDate
      format: 'YYYY-MM-DD'
      ranges:
        Danes: [
          moment()
          moment()
        ]
        Včeraj: [
          moment().subtract("days", 1)
          moment().subtract("days", 1)
        ]
        "Zadnjih 7 dni": [
          moment().subtract("days", 6)
          moment()
        ]
        "Zadnjih 30 dni": [
          moment().subtract("days", 29)
          moment()
        ]
        "Zadnjih 90 dni": [
          moment().subtract("days", 89)
          moment()
        ]
      locale:
        applyLabel: "Potrdi"
        cancelLabel: "Prekliči"
        fromLabel: "Od"
        toLabel: "Do"
        customRangeLabel: "Po meri"
        daysOfWeek: [
          "Ned"
          "Pon"
          "Tor"
          "Sre"
          "Čet"
          "Pet"
          "Sob"
        ]
        monthNames: [
          "Januar"
          "Februar"
          "Marec"
          "April"
          "Maj"
          "Junij"
          "Julij"
          "Avgust"
          "September"
          "Oktober"
          "November"
          "December"
        ]
        firstDay: 1

    $("#" + @props.id).daterangepicker(options)

    $("#" + @props.id).on "apply.daterangepicker", (event, picker) ->
      _this.handleApply(picker)
  handleApply: (picker) ->
    daterange_label = picker.chosenLabel
    if picker.chosenLabel == 'Po meri'
      daterange_label = "#{moment(picker.startDate, 'YYYY-MM-DD').format("MMMM D, YYYY")} - #{moment(picker.endDate, 'YYYY-MM-DD').format("MMMM D, YYYY")}"

    @props.onChangeDateRange
      from: picker.startDate.format("YYYY-MM-DD")
      to: picker.endDate.format("YYYY-MM-DD")
      label: daterange_label
  render: ->
    (div {className: 'daterangepicker_trigger btn', id: @props.id}, [
      (i {className: 'glyphicon glyphicon-calendar fa fa-calendar'}, null),
      (span {}, @props.label),
      (b {className: 'caret'})])

Filter = React.createClass
  displayName: 'Filter'
  handleRemoveFilters: ->
    @props.onRemoveFilters(@props.column_header.name)
    return false
  render: ->
    options = @props.column_header.options.map ((option_value) ->
      id = "filter_#{@props.column_header.name}_#{option_value}"
      if $.inArray(option_value, @props.selected_options) > -1
        defaultChecked = true
      else
        defaultChecked = false
      (label {for: id}, [
        (input {type: 'checkbox', name: "filter[#{@props.column_header.name}][]", id: id, value: option_value, defaultChecked: defaultChecked, onChange: @props.onFilterChange}),
        (span {}, option_value)])).bind(this)

    if @props.selected_options.length > 0
      remove_button = (Button {bsStyle: "link", className: 'remove_filters glyphicon glyphicon-remove', onClick: @handleRemoveFilters})
    else
      remove_button = null

    (span {}, [
      (OverlayTrigger {trigger: "click", placement: "bottom", overlay: (Popover {}, options)},
        (Button {bsStyle: "link", className: "show_filters #{@props.column_header.summary.type}"}, @props.column_header.summary.value)),
        remove_button])

GaReport = React.createClass
  displayName: 'GaReport'
  getInitialState: ->
    { data:
        column_headers: [],
        rows: []
      filter:
        source: ['emazing']
        campaign: []
        medium: []
        ad_content: []
        keyword: []
      daterange:
        from: moment().subtract('days', 89).format("YYYY-MM-DD")
        to: moment().format("YYYY-MM-DD")
        label: 'Zadnjih 90 dni'
      order:
        by: 'date'
        direction: 'desc'}

  getURL: ->
    params = ["order[by]=#{@state.order.by}",
              "order[direction]=#{@state.order.direction}",
              "daterange[from]=#{@state.daterange.from}",
              "daterange[to]=#{@state.daterange.to}",
              "daterange[label]=#{@state.daterange.label}"]

    @state.filter.source.map (value) ->
      params.push("filter[source][]=#{value}")

    @state.filter.campaign.map (value) ->
      params.push("filter[campaign][]=#{value}")

    @state.filter.medium.map (value) ->
      params.push("filter[medium][]=#{value}")

    @state.filter.ad_content.map (value) ->
      params.push("filter[ad_content][]=#{value}")

    @state.filter.keyword.map (value) ->
      params.push("filter[keyword][]=#{value}")

    json_url = "#{location.pathname}.json?#{params.join('&')}"
    url = "#{location.pathname}?#{params.join('&')}"

    history.replaceState(null, null, url);
    return json_url

  loadReportFromServer: (url) ->
    $.ajax
      url: url || @getURL()
      dataType: 'json'
      success: ((response) ->
        @setState
          data: response.data
          order: response.params.order
          daterange: response.params.daterange
          filter: response.params.filter
      ).bind(this)
      error: ((xhr, status, error) ->
        alert(status)
      ).bind(this)

  componentWillMount: ->
    unless location.search == ""
      url = "#{location.pathname}.json#{location.search}"
    @loadReportFromServer(url)

  toggleSort: (header) ->
    if header.summary.type == 'text_filter'
      direction = 'asc'
      direction = 'asc' if @state.order.direction == 'desc' && header.name == @state.order.by
      direction = 'desc' if @state.order.direction == 'asc' && header.name == @state.order.by
    else
      direction = 'desc'
      direction = 'asc' if @state.order.direction == 'desc' && header.name == @state.order.by
      direction = 'desc' if @state.order.direction == 'asc' && header.name == @state.order.by

    new_state = @state
    new_state.order =
      by: header.name
      direction: direction

    @setState new_state
    @loadReportFromServer()

  changeDateRange: (daterange) ->
    new_daterange_state =
      daterange:
        from: daterange.from
        to: daterange.to
        label: daterange.label

    @setState new_daterange_state
    @loadReportFromServer()

  handleFilterChange: (event) ->
    name = event.target.name.replace('filter[', '').replace('][]', '')
    value = event.target.value
    checked = event.target.checked
    new_state = @state

    if checked
      new_state['filter'][name].push(value)
    else
      new_state['filter'][name] = $.grep new_state['filter'][name], (element) ->
        element != value

    @setState new_state
    @loadReportFromServer()  

  handleRemoveFilters: (header_name) ->
    new_state = @state
    new_state['filter'][header_name] = []

    @setState new_state
    @loadReportFromServer()  

  render: ->
    column_headers = @state.data.column_headers.map ((header) ->
      class_name = 'sorting'
      # class_name = "sorting_desc" if header.name == @state.order.by && @state.order.direction == 'desc'
      # class_name = "sorting_asc" if header.name == @state.order.by && @state.order.direction == 'asc'
      (th {className: class_name, 'data-column-name': header.name}, (span {onClick: @toggleSort.bind(this, header)}, header.title))).bind(this)

    if @state.data.column_headers.length > 0
      filters = [
        (th {}, null),
        (th {}, (Filter {column_header: @state.data.column_headers[1], selected_options: @state.filter[@state.data.column_headers[1].name], onFilterChange: @handleFilterChange, onRemoveFilters: @handleRemoveFilters})),
        (th {}, (Filter {column_header: @state.data.column_headers[2], selected_options: @state.filter[@state.data.column_headers[2].name], onFilterChange: @handleFilterChange, onRemoveFilters: @handleRemoveFilters})),
        (th {}, (Filter {column_header: @state.data.column_headers[3], selected_options: @state.filter[@state.data.column_headers[3].name], onFilterChange: @handleFilterChange, onRemoveFilters: @handleRemoveFilters})),
        (th {}, (Filter {column_header: @state.data.column_headers[4], selected_options: @state.filter[@state.data.column_headers[4].name], onFilterChange: @handleFilterChange, onRemoveFilters: @handleRemoveFilters})),
        (th {}, (Filter {column_header: @state.data.column_headers[5], selected_options: @state.filter[@state.data.column_headers[5].name], onFilterChange: @handleFilterChange, onRemoveFilters: @handleRemoveFilters})),
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

    (form {}, [
      (DateRangePicker {id: 'report_daterangepicker_trigger', startDate: this.state.daterange.from, endDate: this.state.daterange.to, label: this.state.daterange.label, opens: 'left', onChangeDateRange: @changeDateRange}),
      (input {type: "hidden", onChange: @onFormChange, name: "daterange[from]", defaultValue: "2014-05-01"}),
      (input {type: "hidden", onChange: @onFormChange, name: "daterange[to]", defaultValue: "2014-07-17"}),
      (input {type: "hidden", onChange: @onFormChange, name: "order[by]", defaultValue: "date"}),
      (input {type: "hidden", onChange: @onFormChange, name: "order[direction]", defaultValue: "desc"}),
      (table {className: "table table-striped table-condensed report_records", onClick: @filter}, [
        (thead {}, [
          (tr {className: "headers"}, column_headers),
          (tr {className: "filters", 'data-no-turbolink':true}, filters)
        ]),
        (tbody {}, rows)
    ])])

React.renderComponent (GaReport {}), document.getElementById('ga_report') if document.getElementById('ga_report')

TableReport = React.createClass
  displayName: 'TableReport'
  getInitialState: ->
    { data:
        column_headers: [],
        rows: []
      filter:
        source: ['emazing']
        campaign: []
        medium: []
        ad_content: []
        keyword: []
      daterange:
        from: moment().subtract('days', 89).format("YYYY-MM-DD")
        to: moment().format("YYYY-MM-DD")
        label: 'Zadnjih 90 dni'
      order:
        by: 'date'
        direction: 'desc'}
  loadReportFromServer: (url) ->
    $.ajax
      url: url || @getURL()
      dataType: 'json'
      success: ((response) ->
        @setState
          data: response.data
      ).bind(this)
      error: ((xhr, status, error) ->
        alert(status)
      ).bind(this)

  componentWillMount: ->
    # unless location.search == ""
      # url = "#{location.pathname}.json#{location.search}"
    url = "#{location.pathname}.json"
    @loadReportFromServer(url)
  render: ->
    _this = this
    column_headers = @state.data.column_headers.map ((column_header) ->
      class_name = 'sorting'
      # class_name = "sorting_desc" if column_header.name == @state.order.by && @state.order.direction == 'desc'
      # class_name = "sorting_asc" if column_header.name == @state.order.by && @state.order.direction == 'asc'
      (th {className: class_name, 'data-column-header-name': column_header.name}, (span {}, column_header.title))).bind(this)

    rows = @state.data.rows.map (row) ->
      class_name = ''

      fields = _this.state.data.column_headers.map ((column_header) ->
        value = row[column_header.name]

        switch column_header.type
          when 'currency'
            cell = (Currency {value: value})
          when 'percentage'
            cell = (Percentage {value: value})
          when 'float'
            cell = (Float {value: value})
          when 'date', 'string', 'integer'
            cell = value

        (td {title: value},
          (span {className: 'cell_wrap'},
            cell)))

      (tr {className:class_name}, fields)

    (form {}, [
      (input {type: "hidden", onChange: @onFormChange, name: "daterange[from]", defaultValue: "2014-05-01"}),
      (input {type: "hidden", onChange: @onFormChange, name: "daterange[to]", defaultValue: "2014-07-17"}),
      (input {type: "hidden", onChange: @onFormChange, name: "order[by]", defaultValue: "start_date"}),
      (input {type: "hidden", onChange: @onFormChange, name: "order[direction]", defaultValue: "desc"}),
      (table {className: "table table-striped table-condensed report_records", onClick: @filter}, [
        (thead {}, [
          (tr {className: "headers"}, column_headers),
        ]),
        (tbody {}, rows)
    ])])

React.renderComponent (TableReport {}), document.getElementById('table_report') if document.getElementById('table_report')


