$(document).ready(function() {
  $("#deploy").submit(function(event) {
    event.preventDefault();

    if (!confirm("Are you sure?")) return;

    var branch = $(this).find('#branch').val();
    var source = new EventSource("/deploy/" + encodeURI(branch));
    var terminal = $(".terminal").show();

    appendItem = function(item) {
      item.insertBefore(terminal.find(".cursor"));
      terminal.scrollTop(terminal.prop("scrollHeight"));
    };

    source.onmessage = function(e) {
      appendItem($("<li>" + e.data + "</li>"));
    };

    source.addEventListener("start", function(e) {
      data = JSON.parse(e.data);
      appendItem($("<li>Deployment of " + data.branch + " started at " + data.time + "!</li>"));
    });

    source.addEventListener("finish", function(e) {
      appendItem($("<li>Deploy finished successfully at " + e.data + "!</li>"));
      source.close();
    });
  })
})
