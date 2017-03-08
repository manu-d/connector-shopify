//= require bootstrapValidator.min
//= require_tree ./home

$(function () {
  $('[data-toggle="tooltip"]').tooltip()
})

var checkHistorical

function closeModal(sender)
{
  checkHistorical = sender.id == 'confirm'
  $('#myModal').modal('hide');
}

$(document).ready(function(){
    $("#myModal").on('hidden.bs.modal', function (e) {
      if (!checkHistorical) {
    document.getElementById('historical-data').checked = false
    historicalDataDisplay()
      }
      checkHistorical = false
    });
});
