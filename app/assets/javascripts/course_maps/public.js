/*
 * Copyright (C) 2014 NCTU+
 *
 * Scroll&圖表&使用教學
 * For course_maps/index
 * Modified at 2015/3/24
 */

//= require jquery.scrollTo.min
//= require highcharts-custom
//= require page-tour-custom
//= require user_course_stat/checker

var takedColor="#AAAAAA";
function genCourseGrid(user_courses,category,course){
	var taked=false;
	var color="";
	if(user_courses==null||user_courses.length==0){
		for(var i=0; i< category.length; i++){
			if(course.cf.cf_name==category[i].cf_name||(course.parent_cf!=null&&course.parent_cf.cf_name==category[i].cf_name)){
				color=category[i].color;
				break;
			}
		}
		
	}
	else{
		//
		var foundCourse=FindUserCourse(user_courses,course);
		if(foundCourse&&checkPass(foundCourse.pass_score,foundCourse.score)){		
			taked=true;
		}
		else if(course.cg_courses){
			for(var i=0,c;c=course.cg_courses[i];i++){
				foundCourse=FindUserCourse(user_courses,c);
				if(foundCourse&&checkPass(foundCourse.pass_score,foundCourse.score))
					taked=true;
			}
		}
		if(taked)
			color=takedColor;
	}
	
	var res='<div class="btn-course " style="background:';
	res+=color+';';
	res+=taked ? "color:black;/*border:2px #FFFF00 solid;*/" : "";
	res+=+'" data-cf-name="';
	res+= course.parent_cf==null ? course.cf.cf_name : course.parent_cf.cf_name;
	res+='" data-taked="'+taked;
	res+='" data='+JSON.stringify(course)+' >';
	res+=course.name+'</div>';
	return res;
}
function loadCm(dept_id,year){	//Load from server & initial
	$.getJSON("/course_maps/public",{
		dept_id: dept_id,
		year: year
		},
		function(data){
			console.log(data);
			$("#cm-desc").html(tmpl("cm_public", data));//tmpl 插件
			$("#year-"+year).addClass("disabled");				
			$("#sem-btn").click();
			neededCourseBarChart("#chart-content", data.course_map);
			$('#joyRideTipContent').joyride({
				autoStart : true,
				cookieMonster: true,           
				cookieName: 'CourseMapPublicTip', 
				modal:true,
				expose: true
			});
			initCourseHoverTip();
		}
	);
}
function toggleCourseGrids(className){
	$("div[data-cf-name='"+className+"']").toggle();
}
function toggleTakedCourseGrids(){
	$("div[data-taked='true']").toggle();
}
function initCourseHoverTip(){
	$( ".btn-course" ).mouseover(function(event){
		var course=JSON.parse($(this).attr('data'));
		var offset = $( this ).offset();
		var id1 = $(this).attr('id');			
		var color4 = $(this).css('background-color');			
		var str="#"+id1;
		var content = "永久課號 : "+course.real_id;
		var sty=("2px "+ $(str).css("background")+" solid");				
		$( ".tooltip-course" ).css({
			"left": (event.pageX+1000),
			"top": (event.pageY+1000),
			"display": "block"
		});		
		var group = "";
		var content2;
		var i = 0;				
		content2 = "學分數 : " + course.credit + "<br>" + "選課別 : " + course.cf.cf_name + "<br>";
		if(course.cg_courses){
			content2 = content2 + "互抵課程 : "+"<br>"
			while(course.cg_courses[i])
			{
				group = course.cg_courses[i].name;
				group_course_id = course.cg_courses[i].real_id;
				content2 = content2 + "<b>" + group + "(課號 : " +
									group_course_id  + ")" + "</b>" + "<br>";
				i++;
			}
		}				
		$( ".course-name" ).html(course.name+"<br>"+content).css("background",color4);
		$( ".course-content" ).html(content2);
		$( ".tooltip-course" ).css("border-color",color4);
	}).mousemove(function(event){
		var color4 = $(this).css('background-color');			
		var id1 = $(this).attr('id');
		var color1="#FF0080";
		var str="#"+id1;
		var sty=("2px "+$(str).css("background")+" solid");
		var w = $( window ).width();			
		if(w < 1266)w = 0;
		else w = (w - 1266)*1266/w;			
		$( ".tooltip-course" ).css({
			"left": (event.pageX/*-w-50*/),
			"top": (event.pageY/*-95*/),
			"display": "block",
			"border-color":(color4)
		});
		$( ".course-name" ).css({
			"background-color":$(str).css("background-color")});
		$( ".tooltip-course" ).css("border-color",color4);			
	}).mouseout(function(event){				
		var id1 = $(this).attr('id');
		var color1="#FF0080";			
		$( ".tooltip-course" ).css({
			"display": "none",
			});
	});
	$( ".tooltip-course" ).mouseover(function(){
		$( this ).css({"display": "block"});
	}).mousemove(function(event){
		$( this ).css({"display": "block"});
	}).mouseout(function(event){
		$( this).css({"display": "none"});
	});
}

function toggleGroup(obj,cf_id,id){
	var $target=$(".cf-"+cf_id+"-"+id);
	$target.toggle(600,function(){
		if($target.is(":visible")){
			obj.find(".fa-plus").toggleClass("fa-minus fa-plus");
		}
		else{
			obj.find(".fa-minus").toggleClass("fa-minus fa-plus");
		}
	});
}

function toggleBtn(obj){
	var x=obj.attr('type');
	if(x=="show"){
		obj.text("收回互抵課程");
		$("[class*=cf-]").show();
		obj.attr('type','hide');
		$(".fa-plus").attr("class","fa fa-minus");
	}
	else{
		obj.text("展開互抵課程");
		$("[class*=cf-]").hide();
		obj.attr('type','show');
		$(".fa-minus").attr("class","fa fa-plus");
	}
}
	

function toggle_cf_table(type){
	var _class={true:'cf',false:'sem'};
	//alert(_class[type]);
	$("#list_by_"+_class[type]).show();
	$("#list_by_"+_class[!type]).hide();
	$("."+_class[type]+"-li").show();
	$("."+_class[!type]+"-li").hide();
	$("#"+_class[type]+"-btn").attr("disabled", true);
	$("#"+_class[!type]+"-btn").attr("disabled", false);
	$('body').scrollspy('refresh');

}

function neededCourseBarChart(target,raw_data){ // input is json format
	if(!raw_data || $(target).length==0)return;
	var grade = [0,0,0,0,0,0,0,0,0] ;
				
	function _parse_grade(sem, half, credit){
		if(half>2){
			grade[8]+=1 ;
			return ;
		}
		sem = parseInt(sem); half = parseInt(half);
		half = (half==1) ? 0 : 1 ;
		switch(sem)
		{
			case 1:
				grade[0+half]+=credit ;
				break;
			case 2:
				grade[2+half]+=credit ;
				break;
			case 3:
				grade[4+half]+=credit ;
				break ;
			case 4:
				grade[6+half]+=credit ;
				break;
			default:
				grade[8]+=credit ;		
		}
		return ;
	}
	
	for(var i=0, cf; cf = raw_data.cfs[i];++i){
		if(cf.cf_type==1){
			for(var j=0, cg; cg = cf.course_groups[j];j++){
				_parse_grade(cg.grade, cg.half, cg.credit);
			}				
			for(var j=0, c; c = cf.courses[j];j++){
				_parse_grade(c.grade, c.half, c.credit);
			}
		}
	}

	// Build the chart
	var piechart = $(target).highcharts({
		chart: {type: 'column'},
		title: {text: '學年表定建議必修學分'},
		xAxis: {
		categories: [
						"大一上","大一下",
						"大二上","大二下",
						"大三上","大三下",
						"大四上","大四下",
						"不限"
				]
		},
		yAxis:{
			title: {text: '學分'},
			tickInterval:2
		},
		series: [{
				name: "建議修習",
				data: grade
		}]
	});
	return piechart;
}// piechart_data
	


function gradeSort(coursesbyGrade){
	coursesbyGrade.sort(function(a,b) {
		return (a[0].grade+a[0].half).localeCompare((b[0].grade+b[0].half));
	}); 
	
}
//學程群組-> 無課

function genTh(show_cf){   //學成second blank
	//str='<table class="table table-bordere">';
	
	var str='<tr class="row"><th class="col-md-1"></th>';
	str+='<th class="col-md-3 text-center">課名</th>';
	str+='<th class="col-md-2 text-center">修課學期</th>';
	str+='<th class="col-md-1 text-center">學分</th>';
	str+='<th class="col-md-2 text-center">永久課號</th>';
	//if(show_cf)
		str+='<th class="col-md-3 text-center">類別</th>';
	str+='</tr>';
	return str;
}
function packCourse(course,cf,parent_cf){ //年級 table 加上 學程群組-
	var ret=course; //除了學程以外的欄
	var _parent_cf = parent_cf!=null ? {
		cf_name:parent_cf.cf_name
	} : null;
	ret["cf"]={
		cf_name :cf.cf_name,
		type: cf.type
	};	//自己
	ret["parent_cf"]=_parent_cf;//學程(有些是空的)
	
	return ret;
}
function genCourseList(cf,show_cf,parent_cf){
	var res={};
	var courses=[];
	
	var str="";
	//str+="</thead>";
	//str+="<tbody>";

	for(var j=0,course;course=cf.courses[j];j++){
		str+=genCourseRow("",course,show_cf ? cf.cf_name :"");
		courses.push(packCourse(course,cf,parent_cf));
	}
	
	for(var i=0,cg;cg=cf.course_groups[i];i++){
		
		var lead_course=cg.lead_course;
		var tmp=packCourse(lead_course,cf,parent_cf);
		tmp["cg_courses"]=[];
		//courses.push(packCourse(lead_course,cf,parent_cf));
		//str+=genCourseRow('<i class="fa fa-plus">',lead_course,show_cf ? cf.cf_name : "");
		str+='<tr class="row lead_course">';
		str+='<td class="text-center clickable-hover toggle-group" onclick="toggleGroup($(this),'+cf.id+','+cg.id+');"><i class="fa fa-plus"></td>';
		str+=genCourseRow2(lead_course,show_cf ? cf.cf_name : "");
		str+="</tr>";
		for(var j=0,course;course=cg.courses[j];j++){
			if(course.id==lead_course.id)continue;
			str+='<tr class="row cf-'+cf.id+'-'+cg.id+'" style="display:none;">';
			str+='<td class="text-center"><i class="fa fa-angle-right"></td>';
			str+=genCourseRow2(course,"");
			str+="</tr>";
			//courses.push(packCourse(course,cf,parent_cf));
			tmp["cg_courses"].push(packCourse(course,cf,parent_cf));
		}
		courses.push(tmp);
	}
	//str+="</tbody>";
	res["html"]=str;
	res["courses"]=courses;
	return res;
}
function parseCf(cf){//修課規定 文字
	var str='<ul>';
	str+='<li>';
	str+='['+get_cf_type(cf.cf_type)+']';

	str+=cf.cf_name+" | ";//需"
	if(cf.cf_type!=1){
		str+="至少";
	}
	str+="需";
	
	for(var i = 0,credit;credit=cf.credit_list[i];i++){
		str+=" <strong>"+credit.credit_need+'</strong> 學分 或';
		
	}
	str = str.substring(0, str.length - 1);
	//str[str.length-1]='\0';
	if(cf.cf_type==3){
		str+='且需滿足 <strong>'+cf.field_need+'</strong> 個領域';
	}
		
	if(cf.cf_type<3){
		str+='</ul>';
	}
	else{			
		for(var i=0,child_cf;child_cf=cf.child_cf[i];i++){
			str+=parseCf(child_cf);
		}
		str+='</li>';	
		str+='</ul>';
	}		
	return str;
}

function genCourseRow2(course,cf_name){

	//var str='<td class="text-center">'+group_symbol+'</td>';
	str='<td class="text-center">'+ course.name +'</td>';
	str+='<td class="text-center">'+course.suggest_sem+'</td>';
	str+='<td class="text-center">'+course.credit+'</td>';
	str+='<td class="text-center">'+course.real_id+'</td>';
	//if(cf_name!=""){
		str+='<td class="text-center">';
		
		str+=cf_name;
		str+="</td>";
	//}
	
	return str;
}

function genCourseRow(group_symbol,course,cf_name){
	var str='<tr class="lead_cours row">';
	str+='<td class="text-center">'+group_symbol+'</td>';
	str+='<td class="text-center">'+ course.name +'</td>';
	str+='<td class="text-center">'+course.suggest_sem+'</td>';
	str+='<td class="text-center">'+course.credit+'</td>';
	str+='<td class="text-center">'+course.real_id+'</td>';
	//if(cf_name!=""){
		str+='<td class="text-center">';
		
		str+=cf_name;
		str+="</td>";
	//}
	str+="</tr>";
	return str;
}
	
function parseCfToCourseWithoutHeader(cf,parent_cf){
	var res={};
	var str="";
	var courses=[];
	

	if(cf.cf_type<3){		
		temp=genCourseList(cf,true,parent_cf);
		str+=temp["html"];
		courses=courses.concat(temp["courses"]);
	}
	else{
		str+=genCfHeader(cf,false);
		if(cf.cf_type==4){				
			str+=genTh(true);
		}
		for(var i=0,child_cf;child_cf=cf.child_cf[i];i++){
			//str+=parseCfToCourseWithoutHeader(child_cf);
			temp=parseCfToCourseWithoutHeader(child_cf,cf);
			str+=temp["html"];
			courses=courses.concat(temp["courses"]);
		}
	}
	res["html"]=str;
	res["courses"]=courses;
	return res;
	//return str;
}

function genCfHeader(cf,show_h4){
	var _rowcolor=["","course-required","course-elective","dimension-youandme","dimension-world"];
	var str='<tr class="row '+_rowcolor[cf.cf_type]+'" >';

	str+='<td id="'+cf.id+'" colspan="6" class="text-center" >';
	if(show_h4)
		str+="<h4>";
	str+='['+get_cf_type(cf.cf_type)+']';
	str+=cf.cf_name+' | ';
	if(cf.cf_type!=1){
		str+="至少";
	}
	str+="需 <strong>"+cf.credit_need+'</strong> 學分';
	if(cf.cf_type==3){
		str+='且需滿足 <strong>'+cf.field_need+'</strong>個領域';
	}
	if(show_h4)
		str+="</h4>";
	str+='</td></tr>';
	return str;
}
function parseCfToCourse(cf){

	var res={};
	var courses=[];
	var str='<table class="table table-bordered">';
	str+=genCfHeader(cf,true);
	if(cf.cf_type<3){
		str+=genTh(false);
		temp=genCourseList(cf,false,null);
		str+=temp["html"];
		courses=courses.concat(temp["courses"]);
	}
	else{
		if(cf.cf_type==4){
			str+=genTh(true);
		}
		for(var i=0,child_cf;child_cf=cf.child_cf[i];i++){
			temp=parseCfToCourseWithoutHeader(child_cf,cf);
			str+=temp["html"];
			courses=courses.concat(temp["courses"]);
		}
	}

	str+="</table>";
	
	res["html"]=str;
	res["courses"]=courses;
	return res;
	
}
function initFbComment(dept_id){
	$('#fb-root').html('<div class="fb-comments" data-href="" data-numposts="5" width="100%" data-colorscheme="light"></div>');
	$('.fb-comments').attr('data-href',"http://plus.nctu.edu.tw/course_maps/?dept_id="+dept_id);
}
	