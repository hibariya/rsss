$(function() {
  window.User = Backbone.Model.extend({
    url:   $("#user").attr('data-users-url')
  });

  window.Site = Backbone.Model.extend({});

  window.SiteList = Backbone.Collection.extend({
    model: Site,
    url:   $("#sites").attr('data-sites-url')
  });

  window.UserView = Backbone.View.extend({
    el: $('#user'),

    events: {
      'click #user_submit' : 'close'
    },

    initialize: function() {
      this.bio = this.$('#user_bio');
      this.url = this.$('#user_url');
      this.submit = this.$('#user_submit');

      _.bindAll(this, 'render');
      this.model.bind('change', this.render);
      return this;
    },

    render: function() {
      this.bio.val(this.model.get('bio'));
      this.url.val(this.model.get('url'));
      return this;
    },

    newAttributes: function() {
      return {
        bio: this.bio.val(),
        url: this.url.val()
      }
    },

    close: function() {
      this.loading(true);

      var view = this;
      var callback = function(model, response) {
        view.loading(false);
        view.$('.message').hide().text(response.message).show(500);
        setTimeout(function() { view.$('.message').hide(500); }, 5000);
      };

      this.model.save(this.newAttributes(), {
        success: callback,
        error:   callback
      });

      return false;
    },

    loading: function(f) {
      if (!!f) {
        this.$('.loading_img').show();
      } else {
        this.$('.loading_img').hide();
      }
    }
  });
});
