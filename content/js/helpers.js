!function ($) {
  $(document).on('touchstart.dropdown', '.dropdown-menu', function(e) {
    e.stopPropagation();
  });
}(window.jQuery)
