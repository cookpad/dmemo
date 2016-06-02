timeoutId = undefined
markdownEditor = ->
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

$(document).ready(->
  $(".markdown-editor").on('keyup', markdownEditor)
  $(document).bind('cbox_complete', ->
    $("#colorbox .markdown-editor").on('keyup', markdownEditor)
  )

  $("a.colorbox").colorbox(closeButton: false, width: "600px", maxWidth: "1200px")
)


