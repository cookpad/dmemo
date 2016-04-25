$.fn.editable.defaults.mode = "popup"
$.fn.editable.defaults.placement = "bottom"
$.fn.editable.defaults.ajaxOptions = { type: "PATCH", dataType: "json" }
$.fn.editable.defaults.display = false

$(document).ready(->
  $(".editable-field").editable(
    success: (response, newValue)->
      $field = $(this)
      target = $field.data("target")
      result = $field.data("result")
      $(target).html(response[result])
  )

  $(".shorten_url_link").on("click", ->
    target = $(this).data("target")
    $(target).toggleClass("hidden")
  )
)
