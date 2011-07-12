$ ->
  window.User = Backbone.Model.extend
    url: $("#user").attr('data-users-url')

  window.Site = Backbone.Model.extend()

  window.SiteList = Backbone.Collection.extend
    model: Site,
    url: $("#sites").attr('data-sites-url')

  window.UserView = Backbone.View.extend
    el: $('#user')

    events:
      'click #user_submit' : 'close'

    initialize: ->
      @bio = @$('#user_bio')
      @url = @$('#user_url')
      @submit = @$('#user_submit')
      _.bindAll this, 'render'
      @model.bind 'change', @render
      this

    render: ->
      @bio.val @model.get('bio')
      @url.val @model.get('url')
      this

    newAttributes: ->
      bio: @bio.val()
      url: @url.val()

    close: ->
      @loading true

      callback = (model, response) =>
        @loading false
        @$('.message').hide().text(response.message).show(500)
        @$('.message').hide().text(response.message).show(500)
        setTimeout (-> @$('.message').hide(500)), 5000

      @model.save @newAttributes(),
        success: callback
        error:   callback

      false

    loading: (f) ->
      if !!f
        @$('.loading_img').show()
      else
        @$('.loading_img').hide()

