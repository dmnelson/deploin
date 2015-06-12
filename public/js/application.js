$(document).ready(function() {
  $("#branch").change(function(e) {
    $("#deploy").find(":submit").toggleClass("disabled", !$(this).val());
  });

  $("#deploy").submit(function(e) {
    e.preventDefault();

    if (!confirm("Are you sure?")) return;

    var branch = $(this).find('#branch').val();
    var source = new EventSource("/deploy/" + encodeURI(branch));
    var terminal = $(".terminal").show();

    appendItem = function(item) {
      item.insertBefore(terminal.find(".cursor"));
      terminal.scrollTop(terminal.prop("scrollHeight"));
    };

    source.onmessage = function(e) {
      appendItem($("<li class=\"data\">" + e.data + "</li>"));
    };

    source.addEventListener("start", function(e) {
      terminal.find("li.data").remove()

      data = JSON.parse(e.data);
      appendItem($("<li class=\"data\">Deployment of " + data.branch + " started at " + data.time + "!</li>"));
    });

    source.addEventListener("finish", function(e) {
      appendItem($("<li class=\"data\">Deploy finished successfully at " + e.data + "!</li>"));
      source.close();
    });
  });
});
