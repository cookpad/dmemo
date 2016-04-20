$(document).ready(->
  $('.shorten_url_link').on("click", ->
    target = $(this).data("target")
    $(target).toggleClass("hidden")
  )
)
