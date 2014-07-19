{a, table, thead, tr, tbody, th, td, span, form, input, select, label, div, i, b} = React.DOM
{OverlayTrigger, Popover, Button} = ReactBootstrap

Currency = React.createClass
  displayName: 'Currency'
  render: ->
    (span {className: 'currency'},
      (span {className: 'unit'}, '€ '),
      (span {className: 'number'}, parseFloat(@props.value).toFixed(2) if @props.value))

Percentage = React.createClass
  displayName: 'Percentage'
  render: ->
    if @props.value
      (span {className: 'percentage'}, "#{@props.value}%")
    else
      (span {className: 'percentage no-value'}, 'n/a')

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
        "Ta mesec": [
          moment().startOf("month")
          moment().endOf("month")
        ]
        "Prejšnji mesec": [
          moment().subtract("month", 1).startOf("month")
          moment().subtract("month", 1).endOf("month")
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
      daterange_label = "#{moment(@props.startDate, 'YYYY-MM-DD').format("MMMM D, YYYY")} - #{moment(@props.endDate, 'YYYY-MM-DD').format("MMMM D, YYYY")}"

    @props.onChangeDateRange
      from: picker.startDate.format("YYYY-MM-DD")
      to: picker.endDate.format("YYYY-MM-DD")
      label: daterange_label
  render: ->
    (div {className: 'daterangepicker_trigger btn', id: @props.id}, [
      (i {className: 'glyphicon glyphicon-calendar fa fa-calendar'}, null),
      (span {}, @props.label),
      (b {className: 'caret'})])

TableReport = React.createClass
  displayName: 'TableReport'
  getInitialState: ->
    { data:
        column_headers: [],
        rows: []
      filters:
        source: []
        campaign: []
        medium: []
        ad_content: []
        keyword: []
      daterange:
        from: moment().format("YYYY-MM-DD")
        to: moment().format("YYYY-MM-DD")
        label: 'Danes'
      order:
        by: 'date'
        direction: 'desc'}

  # getURL()
  # transaforms
  #   url_query: { order: { by: 'source', direction: 'asc' }, filter: { source: ['emazing', 'google'], medium: ['facebook'] } }
  # to
  #   "/ga_exports.json?order[by]=source&order[direction]=asc&filter[source][]=emazing&filter[source][]=google&filter[medium][]=facebook"
  getURL: (params) ->
    "#{location.pathname}.json#{location.search}"

  loadReportFromServer: ->
    $.ajax
      url: @getURL()
      dataType: 'json'
      success: ((data) ->
        @setState
          data: data
      ).bind(this)
      error: ((xhr, status, error) ->
        alert(status)
      ).bind(this)

  componentWillMount: ->
    @loadReportFromServer()

  toggleSort: (header) ->
    if header.summary.type == 'text_filter'
      direction = 'asc'
      direction = 'asc' if @state.order.direction == 'desc' && header.name == @state.order.by
      direction = 'desc' if @state.order.direction == 'asc' && header.name == @state.order.by
    else
      direction = 'desc'
      direction = 'asc' if @state.order.direction == 'desc' && header.name == @state.order.by
      direction = 'desc' if @state.order.direction == 'asc' && header.name == @state.order.by

    @setState
      order:
        by: header.name
        direction: direction

    @loadReportFromServer()

  openFilter: ->
    return false;

  commit: (event) ->
    params = decodeURIComponent($('form').serialize())
    console.log params
    history.replaceState('string', 'title', location.origin + location.pathname + '?' + params)
    @loadReportFromServer()
    return false

  onFormChange: ->
    console.log 'yep'
    $('form').submit()
    return false

  changeDateRange: (daterange) ->
    @setState
      daterange:
        from: daterange.from
        to: daterange.to
        label: daterange.label
    return

  generatePopoverFilter: (header) ->
    options = header.options.map ((option) ->
      id = "filter_#{header.name}_#{option}"
      (label {for: id}, [
        (input {type: 'checkbox', name: "filter[#{header.name}][]", id: id, defaultValue: option}),
        (span {}, option)])).bind(this)
    options

  render: ->
    column_headers = @state.data.column_headers.map ((header) ->
      class_name = 'sorting'
      class_name = "sorting_desc" if header.name == @state.order.by && @state.order.direction == 'desc'
      class_name = "sorting_asc" if header.name == @state.order.by && @state.order.direction == 'asc'
      (th {className: class_name, 'data-column-name': header.name}, (span {onClick: @toggleSort.bind(this, header)}, header.title))).bind(this)

    if @state.data.column_headers.length > 0
      filters = [
        (th {}, null),
        (th {},
          (OverlayTrigger {trigger: "click", placement: "bottom", overlay: (Popover {}, @generatePopoverFilter(@state.data.column_headers[1]))},
            (Button {bsStyle: "link", className: @state.data.column_headers[1].summary.type}, @state.data.column_headers[1].summary.value))),
        (th {},
          (OverlayTrigger {trigger: "click", placement: "bottom", overlay: (Popover {}, @generatePopoverFilter(@state.data.column_headers[2]))},
            (Button {bsStyle: "link", className: @state.data.column_headers[2].summary.type}, @state.data.column_headers[2].summary.value))),
        (th {},
          (OverlayTrigger {trigger: "click", placement: "bottom", overlay: (Popover {}, @generatePopoverFilter(@state.data.column_headers[3]))},
            (Button {bsStyle: "link", className: @state.data.column_headers[3].summary.type}, @state.data.column_headers[3].summary.value))),
        (th {},
          (OverlayTrigger {trigger: "click", placement: "bottom", overlay: (Popover {}, @generatePopoverFilter(@state.data.column_headers[4]))},
            (Button {bsStyle: "link", className: @state.data.column_headers[4].summary.type}, @state.data.column_headers[4].summary.value))),
        (th {},
          (OverlayTrigger {trigger: "click", placement: "bottom", overlay: (Popover {}, @generatePopoverFilter(@state.data.column_headers[5]))},
            (Button {bsStyle: "link", className: @state.data.column_headers[5].summary.type}, @state.data.column_headers[5].summary.value))),
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

    (form {onSubmit: @commit}, [
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

React.renderComponent (TableReport {}), document.getElementById('table_report') if document.getElementById('table_report')
