$ -> new Request() if $('[data-action=request]').length > 0

class Request extends BarcodeReader
  cacheElements: ->
    @$request_urls = $('#request-urls')

    @$user = $('#people')
    @$request = $('#request')
    @$barcode = $('#barcode')
    @$table_request = $('#table_request')
    @$material = $('#material')
    @$article = $('#article')
    @$subarticle = $('#subarticle')
    @$inputSubarticle = $('input#subarticle')
    @$subarticles = $('#subarticles')
    @$selectionSubarticles = $('#selection_subarticles')
    @$selected_subarticles = $('#selected_subarticles')

    @$idRequest = $('#request_id').text()

    @$btnEditRequest = $('#btn_edit_request')
    @$btnShowRequest = $('#btn-show-request')
    @$btnSaveRequest = $('#btn_save_request')
    @$btnCancelRequest = $('#btn_cancel_request')
    @$btnDeliverRequest = $('#btn_deliver_request')
    @$btnSendRequest = $('#btn_send_request')
    @btnSubarticleRequestPlus = $('#plus_sr')
    @btnSubarticleRequestMinus = $('#minus_sr')
    @btnSubarticleRequestRemove = $('#remove_sr')
    @btnShowNewRequest = $('#btn-show-new-request')
    @$btnCancelNewRequest = $('#btn_cancel_new_request')
    @$btnSaveNewRequest = $('#btn_save_new_request')

    @$templateRequestButtons = Hogan.compile $('#request_buttons').html() || ''
    @$templateRequestAccept = Hogan.compile $('#request_accept').html() || ''
    @$templateRequestInput = Hogan.compile $('#request_input').html() || ''
    @$templateRequestBarcode = Hogan.compile $('#request_barcode').html() || ''
    @$templateNewRequest = Hogan.compile $('#new_request').html() || ''
    @$templateBtnsNewRequest = Hogan.compile $('#cancel_new_request').html() || ''
    @$templateUserInfo = Hogan.compile $('#show_user_info').html() || ''

    @request_save_url = decodeURIComponent @$request_urls.data('request-id')
    @subarticles_json_url = decodeURIComponent @$request_urls.data('get-subarticles')
    @user_url = decodeURIComponent(@$request_urls.data('users-id'))

    @alert = new Notices({ele: 'div.main'})

  bindEvents: ->
    $(document).on 'click', @$btnShowRequest.selector, => @show_request()
    $(document).on 'click', @$btnEditRequest.selector, => @edit_request()
    $(document).on 'click', @$btnSaveRequest.selector, => @update_request()
    $(document).on 'click', @$btnCancelRequest.selector, => @cancel_request()
    $(document).on 'click', @$btnDeliverRequest.selector, => @deliver_request()
    $(document).on 'click', @$btnSendRequest.selector, (e) => @send_request(e)
    $(document).on 'click', @btnSubarticleRequestPlus.selector, (e) => @subarticle_request_plus(e)
    $(document).on 'click', @btnSubarticleRequestMinus.selector, (e) => @subarticle_request_minus(e)
    $(document).on 'click', @btnSubarticleRequestRemove.selector, (e) => @subarticle_request_remove(e)
    $(document).on 'click', @btnShowNewRequest.selector, => @show_new_request()
    $(document).on 'click', @$btnCancelNewRequest.selector, => @cancel_new_request()
    $(document).on 'click', @$btnSaveNewRequest.selector, => @save_new_request()
    if @$material?
      @$article.remoteChained(@$material.selector, @$request_urls.data('subarticles-articles'))
      @$subarticle.remoteChained(@$article.selector, @$request_urls.data('subarticles-array'))
    if @$inputSubarticle?
      @get_subarticles()

  show_request: ->
    sw = 0
    @$table_request.find('.col-md-2 :input').each ->
      if $(this).val() > $(this).parent().prev().text()
        $(this).parent().addClass('has-error')
        sw = 1
      else
        $(this).parent().removeClass('has-error')
    if sw == 0
      @$table_request.find('.col-md-2 :input').each ->
        val = $(this).val()
        val = if val then val else 0
        $(this).parent().html val
      @$table_request.find('.text-center').hide()
      @$table_request.append @$templateRequestButtons.render()
    else
      @open_modal('La cantidad a entregar es mayor a la cantidad solicitada')

  edit_request: ->
    @show_buttons()
    @$request.find('table thead tr').append '<th>Cantidad a entregar</th>'
    @$request.find('table tbody tr').append @$templateRequestInput.render()

  update_request: ->
    materials = $.map(@$request.find('tbody tr'), (val, i) ->
      id: val.id
      amount_delivered: $(val).find('td.col-md-2').text()
    )
    data = { status: 'pending', subarticle_requests_attributes: materials }
    $.ajax
      type: "PUT"
      url: @request_save_url.replace(/{id}/, @$idRequest)
      data: { request: data }
      complete: (data, xhr) ->
        window.location = window.location

  cancel_request: ->
    @$table_request.find('.text-center').show()
    @$table_request.find('.text-center').next().remove()
    @input_to_text()

  deliver_request: ->
    @show_buttons()
    $('#btn-show-request').remove()
    @$barcode.html @$templateRequestBarcode.render()
    $('#code').focus()

  send_request: (e) ->
    e.preventDefault()
    @$code = $('#code')
    if @$code.val()
      @changeToHyphens()
      url = @request_save_url.replace(/{id}/, @$idRequest)
      $.getJSON url, { barcode: @$code.val().trim(), user_id: @$functionary }, (data) => @request_delivered(data)
    else
      @open_modal('Debe ingresar un Código de Barras')

  show_buttons: ->
    @$request.prev().find(".buttonRequest").remove()
    @$table_request.find('.text-center').html @$templateRequestAccept.render()

  request_delivered: (data) ->
    if data
      if data.amount
        if @$table_request.find("tr##{data.id} td.delivered span.glyphicon-ok").length
          @open_modal("#{data.amount_delivered} es límite de entrega del Sub Artículo con código de barra '#{@$code.val()}'")
        else
          @$table_request.find("tr##{data.id} td.amount_delivered").html data.total_delivered
          if data.total_delivered == data.amount_delivered
            @$table_request.find("tr##{data.id} td.delivered span").addClass 'glyphicon-ok'
            window.location = window.location unless @$table_request.find('.delivered span:hidden').length
      else
        @open_modal("El inventario del Sub Artículo con código de barra '#{@$code.val()}' es 0")
    else
      @open_modal('No se encuentra el Sub Artículo en la lista')
    @$code.select()

  input_to_text: ->
    @$table_request.find('td.col-md-2').each ->
      $(this).html "<input class='form-control input-sm' type='text' value=#{$(this).text()}>" if $(this).next().text() < $(this).text()

  open_modal: (content) ->
    @alert.danger content

  get_subarticles: ->
    bestPictures = new Bloodhound(
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace("description")
      queryTokenizer: Bloodhound.tokenizers.whitespace
      limit: 100
      remote: @subarticles_json_url
    )
    bestPictures.initialize()
    @$inputSubarticle.typeahead null,
      displayKey: "description"
      source: bestPictures.ttAdapter()
    .on 'typeahead:selected', (evt, data) => @add_subarticle(evt, data)

  add_subarticle: (evt, data) ->
    if @$subarticles.find("tr##{data.id}").length
      @open_modal("El Sub Artículo '#{data.description}' ya se encuentra en lista")
    else
      if @$selectionSubarticles.find('#people').length > 0
        if data.stock == 0
          @open_modal("El stock del producto #{data.description} es 0")
        else
          @$subarticles.prepend @$templateNewRequest.render(data)
      else
        @$subarticles.prepend @$templateNewRequest.render(data)

  subarticle_request_plus: ($this) ->
    $tr = @get_amount($this)
    $amount = $tr.find('.amount')
    if $amount.text() < $tr.find('.amount').data('stock')
      $amount.text(parseInt($amount.text()) + 1)
    else
      @open_modal("Ya no se encuentra la cantidad requerida en el inventario del Sub Artículo '#{$tr.find('td:first').text()}'")

  subarticle_request_minus: ($this) ->
    $amount = @get_amount($this).find('.amount')
    $amount.text(parseInt($amount.text()) - 1) unless $amount.text() is '1'

  subarticle_request_remove: ($this) ->
    @get_amount($this).remove()

  get_amount: ($this) ->
    $($this.currentTarget).parent().parent()

  show_new_request: ->
    if @$subarticles.find('tr').length
      @btnShowNewRequest.hide()
      @$selectionSubarticles.hide()
      table = @$subarticles.parent().clone()
      table.find('.actions-request').remove()
      table.find('thead tr').prepend '<th>#</th>'
      table.find('#subarticles tr').each (i) ->
        $(this).prepend "<td>#{ i+1 }</td>"
      @$selected_subarticles.append table
      @$selected_subarticles.append @$templateBtnsNewRequest.render()
      @showUserInfo @$user.val()
    else
      @open_modal("Debe seleccionar al menos un Sub Artículo")

  cancel_new_request: ->
    @btnShowNewRequest.show()
    @$selectionSubarticles.show()
    @$selected_subarticles.empty()

  save_new_request: ->
    subarticles = $.map(@$subarticles.find('tr'), (val, i) ->
      subarticle_id: val.id
      amount: $(val).find('td.amount').text()
    )
    json_data = { status: 'initiation', user_id: @$user.val(), subarticle_requests_attributes: subarticles }
    $.post @request_save_url.replace(/{id}/, ''), { request: json_data }, null, 'script'

  showUserInfo: (user_id) ->
    $.getJSON @user_url.replace(/{id}/g, user_id), (data) =>
      $user = @$templateUserInfo.render(data)
      $table = @$selected_subarticles.find("table")
      $($user).insertBefore($table)
