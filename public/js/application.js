$(document).ready(function() {
  $("#branch").change(function(e) {
    $("#deploy").find(":submit").toggleClass("disabled", !$(this).val());
  });

  appendToTerminal = function(item) {
    item.insertBefore(terminal.find(".cursor"));
    terminal.scrollTop(terminal.prop("scrollHeight"));
  };

  var source = new EventSource("/deploy");
  var terminal = $(".terminal");

  source.onmessage = function(e) {
    appendToTerminal($("<li class=\"data\">" + e.data + "</li>"));
  };

  $("#deploy").submit(function(e) {
    e.preventDefault();

    if (!confirm("Are you sure?")) return;

    $.ajax({
      url: "/deploy",
      method: "POST",
      data: $(this).serialize(),
    }).fail(function(data) {
      alert("Error")
    });
  });
});
