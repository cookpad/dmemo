let timeoutId = undefined;
function markdownEditor() {
  if (timeoutId) {
    clearTimeout(timeoutId);
    timeoutId = undefined;
  }
  const $editor = $(this);
  timeoutId = setTimeout(() => {
    $.ajax('/markdown_preview', {
      type: 'POST',
      data: {
        md: $editor.val()
      },
    }).done((data) => {
      $($editor.data('target')).html(data.html);
    });
  }, 300);
};

$(() => {
  $('.markdown-editor').on('keyup', markdownEditor);
  $(document).on('cbox_complete', () => $('#colorbox .markdown-editor').on('keyup', markdownEditor));

  $('a.colorbox').colorbox({closeButton: false, width: '600px', maxWidth: '1200px'});

  $('.unfavorite-table-link').on('ajax:success', (data) => {
    console.log(data);
    $('.favorite-table-block').addClass('unfavorited');
    $('.favorite-table-block').removeClass('favorited');
  });

  $('.favorite-table-link').on('ajax:success', (data) => {
    console.log(data);
    $('.favorite-table-block').addClass('favorited');
    $('.favorite-table-block').removeClass('unfavorited');
  });

  $('.disable-click').on('click', (e) => e.stopPropagation());
});
