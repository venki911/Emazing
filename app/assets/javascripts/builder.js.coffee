$(document).ready ->
  $('form#builder_new').on 'submit', ->
    generate_values()
    update_location()
    false

  $('.panel input').on 'click', ->
    $(this).focus().select()
    false

  update_location = ->
    params = $.param($('form').serializeArray())
    window.history.pushState("string", "title", location.origin+location.pathname+'?'+params)


  generate_values = ->
    url = URI($('#website_url').val())
    url = url.addSearch('utm_source', standarize($('#utm_source').val())) if $('#utm_source').val()
    url = url.addSearch('utm_medium', standarize($('#utm_medium').val())) if $('#utm_medium').val()
    url = url.addSearch('utm_term', standarize($('#utm_term').val())) if $('#utm_term').val()
    url = url.addSearch('utm_content', standarize($('#utm_content').val())) if $('#utm_content').val()
    url = url.addSearch('utm_campaign', standarize($('#utm_campaign').val())) if $('#utm_campaign').val()

    name = []
    name[0] = switch url.domain()
                when 'smania.si' then 'smania'
    name[1] = standarize($('#utm_medium').val())
    name[2] = standarize($('#utm_campaign').val())

    $('#campaign_url').removeAttr('disabled').val(url)
    $('#campaign_name').removeAttr('disabled').val(name.join(' | '))
    $('#ad_name').removeAttr('disabled').val(standarize($('#utm_content').val()))

  standarize = (value) ->
    trimmed_value = $.trim(value)
    ansi_value = trimmed_value.replace(new RegExp('č', 'g'), 'c')
                                .replace(new RegExp('ž', 'g'), 'z')
                                .replace(new RegExp('š', 'g'), 's')
                                .replace(new RegExp('ć', 'g'), 'c')
    ansi_value