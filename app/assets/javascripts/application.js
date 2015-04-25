// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require jquery-ui
//= require bootstrap.min

//= require tmpl.min
//= require array-groupby
//= require coursemap-helper
//= require coursemap-checker
//= require toastr.min

$('.toolTip').hover(function(){
						// Hover over code
						var title = $(this).attr('title');
						$(this).data('tipText', title).removeAttr('title');
						$('<p style="z-index:5000;"class="toolTipText "></p>')
						.text(title)
						.appendTo('body')
						.fadeIn('slow');
		}, function() {
						// Hover out code
						$(this).attr('title', $(this).data('tipText'));
						$('.toolTipText').remove();
		}).mousemove(function(e) {
						var mousex = e.pageX + 20; //Get X coordinates
						var mousey = e.pageY + 10; //Get Y coordinates
						$('.toolTipText')
						.css({ top: mousey, left: mousex })
		});