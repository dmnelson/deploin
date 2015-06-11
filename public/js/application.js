$(document).ready(function() {
  $("#deploy").submit(function(event) {
    event.preventDefault();

    if (!confirm("Are you sure?")) return;

    var branch = $(this).find('#branch').val();
    var source = new EventSource("/deploy/" + encodeURI(branch));
    var terminal = $(".terminal").show()

    source.onmessage = function(e) {
      var item = $("<li>" + e.data + "</li>");
      item.insertBefore(terminal.find(".cursor"))

      terminal.scrollTop(terminal.prop("scrollHeight"))
    }
  })
})
