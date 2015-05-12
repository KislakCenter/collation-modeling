jQuery ->
  $('form').on 'click', '.remove_fields', (event) ->
    $(this).prev('input[type=hidden]').val('1')
    $(this).closest('.form-group').hide()
    event.preventDefault()

  $('form').on 'click', '.add_leaf', (event) ->
    folio_num = next_folio()
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('fields').replace(regexp, time))
    $(this).prev('.form-group').find('input[name*=folio_number]').val(folio_num)
    event.preventDefault()

  next_folio = ->
    last_leaf = $('.leaf_fields:visible').last()
    val = if last_leaf.size() == 0
      $('input[name=last_folio_number]').val()
    else
      last_leaf.find('input[name*=folio_number]').val()

    # parseInt will return 4 for '4a'; not what we want
    # Number('4a') returns NaN
    val = Number(val)
    if isNaN(val) then '' else ++val
