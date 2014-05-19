# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready ->
	table = $('.report_records').DataTable
						paging: false
						"info": false
						"order": [[ 9, "desc" ]]
						"language":
						  "search": "Iskanje:"
						  "sZeroRecords": "Iskanje ni obrodilo sadov."