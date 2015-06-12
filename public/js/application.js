$(document).ready(function() {
  var available = true;

  $("#branch").change(function(e) {
    $("#deploy").find(":submit").toggleClass("disabled", !$(this).val() || !available);
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

  source.addEventListener("available", function() {
    available = true;

    $('.deploy-in-progress-warning').toggleClass("hide", true);
    $("#deploy").find(":submit").toggleClass("disabled", false);
  })

  source.addEventListener("unavailable", function() {
    available = false;

    $('.deploy-in-progress-warning').toggleClass("hide", false);
    $("#deploy").find(":submit").toggleClass("disabled", true);
  });

  $("#deploy").submit(function(e) {
    e.preventDefault();

    if (!confirm("Are you sure?")) return;

    $.ajax({
      url: "/deploy",
      method: "POST",
      data: $(this).serialize(),
    }).done(function() {
      terminal.find("li.data").remove();
    }).fail(function(data) {
      $('.deploy-in-progress-error').toggleClass("hide", data.responseText != "DeployInProgress")
    });
  });
});
