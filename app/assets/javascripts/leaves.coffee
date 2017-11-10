ready = ->
  jQuery ->
    $('form').on 'click', '.remove_fields', (event) ->
      $(this).prev('input[type=hidden]').val('1')
      $(this).closest('.form-group').hide('slow')
      event.preventDefault()

    $('form').on 'click', '.add_leaf', (event) ->
      folio_num = next_folio()
      time = new Date().getTime()
      regexp = new RegExp($(this).data('id'), 'g')
      $('#leaves_list').append($(this).data('fields').replace(regexp, time))
      # $('.leaf_fields').last().find('input[name*=folio_number]').val(folio_num).focus()
      $('.leaf_fields').last().hide().find('input[name*=folio_number]').val(folio_num)
      $('.leaf_fields').last().show('slow')
      $('.leaf_fields').last().find('input[name*=folio_number]').focus().select()
      scroll_to_id('#control-buttons')
      event.preventDefault()

    $('form').on 'click', '.add_quire_leaf', (event) ->
      folio_num = next_folio()
      time = new Date().getTime()
      regexp = new RegExp($(this).data('id'), 'g')
      $('#leaves_list').append($(this).data('fields').replace(regexp, time))
      # $('.leaf_fields').last().find('input[name*=folio_number]').val(folio_num).focus()
      $('.leaf_fields').last().hide().find('input[name*=folio_number]').val(folio_num)
      $('.leaf_fields').last().show('slow')
      $('.leaf_fields').last().find('input[name*=folio_number]').focus().select()
      scroll_to_id('#control-buttons')
      event.preventDefault()

    next_folio = ->
      last_leaf = $('.leaf_fields:visible').last()
      val = if last_leaf.size() == 0
        $('input[name*=preceding_folio_number]').val()
      else
        last_leaf.find('input[name*=folio_number]').val()

      # parseInt('4a') returns 4; not what we want
      # Number('4a') returns NaN
      val = Number(val)
      if isNaN(val) then '' else ++val

    scroll_to_id = (id) ->
      off_set = 50
      id_top = $(id).offset().top
      target_offset = id_top - off_set
      $('body').stop().animate({scrollTop:target_offset}, 'slow')


    enable_quire_uncertain = ->
      # clear disabling from all quire_uncertain checkboxes
      $('input[type=checkbox][name*=quire_uncertain]')
        .removeClass('disabled')
        .removeAttr('disabled')

      # disable and hide all unchecked quire_uncertain boxes except the last one
      $('input[type=checkbox][name*=quire_uncertain]:not(:checked):not(:last)')
        .addClass('disabled')
        .attr('disabled', 'disabled')
        .hide()

      # show and enable the last unchecked box
      $('input[type=checkbox][name*=quire_uncertain]:not(:checked):last')
        .removeClass('disabled')
        .removeAttr('disabled')
        .show()

      # disble all but the first checked boxes
      $('input[type=checkbox][name*=quire_uncertain]:checked:not(:first)')
        .addClass('disabled')
        .attr('disabled', 'disabled')

      # enable the first checked box
      $('input[type=checkbox][name*=quire_uncertain]:checked:first')
        .removeClass('disabled')
        .removeAttr('disabled')

      if $('input[type=checkbox][name*=quire_uncertain]:checked').size() > 0
        $('a.add_quire_leaf').attr('disabled', 'disabled')
      else
        $('a.add_quire_leaf').removeAttr('disabled')

    # $('form input[name*=quire_uncertain]').on 'change', enable_quire_uncertain

    # enable_quire_uncertain()

$(document).ready(ready)
$(document).on('turbolinks:load', ready)
