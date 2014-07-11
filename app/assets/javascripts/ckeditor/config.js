if(typeof(CKEDITOR) != 'undefined')
{
  CKEDITOR.editorConfig = function(config) {
    config.uiColor = "#AADC6E";
	config.extraPlugins = 'CodeHighLighter';
    config.toolbar = [  ['Source', '-', 'Preview', '-'],
                        ['Undo', 'Redo', '-', 'SelectAll', 'RemoveFormat'],			    
					    ['Bold', 'Italic', 'Underline', 'Strike', '-', 'Subscript', 'Superscript'],
					    ['JustifyLeft', 'JustifyCenter', 'JustifyRight'],
						[ 'Unlink', 'CreateDiv'],
						['TextColor', 'BGColor'],
						['Font', 'FontSize','Styles','Format'],
						['NumberedList', 'BulletedList', '-', 'Blockquote'],		    
					    ['Link','Image','IMCE', 'Table', 'HorizontalRule', 'Smiley', 'SpecialChar'],
					    ['Code']]; 
	 // The location of a script that handles file uploads in the Image dialog.
  config.filebrowserImageUploadUrl = "/ckeditor/pictures";
  config.filebrowserImageBrowseUrl = "/file_infos/pictures_show";
  }
  
  
  //console.log("ckeditor not loaded");
} else{
  console.log("ckeditor not loaded");
}
