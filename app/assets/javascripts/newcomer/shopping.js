$(document).ready(function() {
    $('#list').click(function(event){event.preventDefault();$('#products .item').addClass('list-group-item');});
    $('#grid').click(function(event){event.preventDefault();$('#products .item').removeClass('list-group-item');$('#products .item').addClass('grid-group-item');});

    if (window.innerWidth < 768) {
    	cal = $('#calculator-switch');
    	lamp = $('#lamp-switch');

    	tcal = cal.clone();
    	tlamp = lamp.clone();

    	cal.replaceWith(tlamp);
    	lamp.replaceWith(tcal);
    }
});
