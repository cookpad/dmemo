$.fn.editable.defaults.mode = "popup"
$.fn.editable.defaults.placement = "bottom"
$.fn.editable.defaults.ajaxOptions = { type: "PATCH", dataType: "json" }
$.fn.editable.defaults.display = false

$(document).ready(->
  $('.editable-field').editable(
    success: (response, newValue)->
      $($(this).data("target")).html(newValue)
  )
)
