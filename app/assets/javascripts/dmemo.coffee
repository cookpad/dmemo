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

  timeoutId = undefined
  $(".markdown-editor").on('keyup', ->
    if timeoutId
      clearTimeout(timeoutId)
      timeoutId = undefined
    $editor = $(this)
    timeoutId = setTimeout(=>
      $.ajax("/markdown_preview",
        type: "POST",
        data:
          md: $editor.val(),
        success: (data)->
          $($editor.data("target")).html(data.html)
      )
    , 300)
  )
)
