!function ($) {
  $(function() {
      // Enable data-api queries for tooltips in footer
      $('footer').tooltip({
        selector: "a[rel=tooltip]"
      })
  })
}(window.jQuery)
