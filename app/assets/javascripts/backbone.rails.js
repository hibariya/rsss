/*
 * Drop in support for rails 3 Cross Site Request Forgery and REST parameters
 * 
 * @author - Hamish Evans, hamish@hevans.me
 */
Backbone.Rails = {}

Backbone.Rails.Model = function(attributes, options) {
  this.csrfvalue = $("meta[name='csrf-token']").attr('content');
  this.csrfparam = $("meta[name='csrf-param']").attr('content');
  attributes || (attributes = {});
  attributes[this.csrfparam] = this.csrfvalue;
  Backbone.Model.call(this, attributes, options); 
} 

_.extend(Backbone.Rails.Model.prototype, Backbone.Model.prototype, {

  toJSON : function() {
    jsonhash = {};
    jsonhash[this.constructor.name.toLowerCase().replace(/model/, "")] = _.clone(this.attributes);
    jsonhash[this.csrfparam] = this.csrfvalue;
    return jsonhash;
  },

  url : function() {
          default_url = Backbone.Model.prototype.url.call(this);  
          return default_url+"?"+this.csrfparam+"="+this.csrfvalue;
        }
});
