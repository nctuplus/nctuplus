function get_cf_type(cf_type){
	switch (cf_type){
		case 1:
			return "必修";
		case 2:
			return "修選";
		case 3:
			return "領域群組";
		case 4:
			return "領域";
	}
}

function green_check(){
	return '<i class="fa fa-check fa-2x" style="color:#5cb85c"></i>'
}
function dimension_class(cos_type){
	var prefix='dimension-';
	switch (cos_type){
		case "通識":
			prefix+='world';
			break;
		case "歷史":
			prefix+='history';
			break;
		case "群已":
			prefix+='youandme';
			break;
		case "公民":
			prefix+='civil';
			break;
		case "自然":
			prefix+='nature';
			break;
		case "文化":
			prefix+='culture';
			break;
	}
	return prefix;
}

function cos_type_class(cos_type){
	var prefix="course-"
	switch (cos_type){
		case "共同必修":
			prefix+="common-required";
			break;
		case "共同選修":
			prefix+="common-elective";
			break;
		case "通識":
			prefix+="general";
			break;
		case "必修":
			prefix+="required";
			break;
		case "選修":
			prefix+="elective";
			break;
		case "外語":
			prefix+="foreign";
			break;
	}	
	return prefix;
}