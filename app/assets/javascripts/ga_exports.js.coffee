# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready ->
  on_daterange_change_update_label = (start, end, label) ->
    console.log label
    if label != 'Po meri'
      $("#report_daterange span").html label
    else
      $("#report_daterange span").html start.format("MMMM D, YYYY") + " - " + end.format("MMMM D, YYYY")
    
    return

  startDate = moment().subtract('days', 6)
  endDate = moment()

  options = 
    opens: 'left'
    startDate: startDate
    endDate: endDate
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
  
  $("#report_daterange span").html startDate.format("MMMM D, YYYY") + " - " + endDate.format("MMMM D, YYYY")
  $('#report_daterange').daterangepicker options, on_daterange_change_update_label

  $("#report_daterange").on "apply.daterangepicker", (ev, picker) ->
    $('input[name="daterange[from]"]').val(picker.startDate.format("YYYY-MM-DD"))
    $('input[name="daterange[to]"]').val(picker.endDate.format("YYYY-MM-DD"))
    return
