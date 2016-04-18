$.fn.editable.defaults.mode = "popup"
$.fn.editable.defaults.placement = "bottom"
$.fn.editable.defaults.ajaxOptions = { type: "PATCH", dataType: "json" }

$(document).ready ->
  $('.editable-field').editable()
