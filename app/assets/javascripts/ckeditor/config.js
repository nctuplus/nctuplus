if(typeof(CKEDITOR) != 'undefined')
{
  CKEDITOR.editorConfig = function(config) {
    config.uiColor = "#AADC6E";
	config.extraPlugins = 'CodeHighLighter';
    config.toolbar = [  ['Source', '-', 'Preview', '-'],
                        ['Undo', 'Redo', '-', 'SelectAll', 'RemoveFormat'],			    
					    ['Bold', 'Italic', 'Underline', 'Strike', '-', 'Subscript', 'Superscript'],
					    ['JustifyLeft', 'JustifyCenter', 'JustifyRight'],
						['Link', 'Unlink', 'CreateDiv',],
						['TextColor', 'BGColor'],
						['Font', 'FontSize','Styles','Format'],
						                          
					    
					    ['NumberedList', 'BulletedList', '-', 'Blockquote'],
					    
					    ['Image', 'Table', 'HorizontalRule', 'Smiley', 'SpecialChar'],
					    ['Code']]; 
    //config.extraPlugins = 'CodePlugin';

    //config.toolbar = [ [ 'Source', 'Bold' ], ['CreatePlaceholder']];


  }
  
  //console.log("ckeditor not loaded");
} else{
  console.log("ckeditor not loaded");
}
