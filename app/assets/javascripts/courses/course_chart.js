function show_chart_reg(data){	
	if(!data.show_reg){
		$('#container-reg-num').hide();
		return false ;
	}
			
    $('#container-reg-num').highcharts({
    	chart:{defaultSeriesType: "column"},
		colors: [
					'#50B432', '#AA4643', '#FF3EFF', '#80699B', '#3D96AE', 
  				'darkslategray', '#92A8CD', '#ED561B', 'orchid', '#24CBE5',
					'#64E572', '#FF9655','#FFF263','#6AF9C4', '#0d233a',
					'#8bbc21', '#910000', '#1aadce', '#492970','#f28f43',
					'#77a1e5', '#c42525', '#a6c96a','#4572A7'
					],
        title: {
            text: '歷年選課統計'
        },      
        xAxis: {
					
            categories: data.semester_name
        },         
        yAxis: {
       			min: 0,
                title: {
                    text: '人數'
                }
        },
        tooltip: {
          formatter: function() {
        		return '<b>' + this.series.name + '</b>老師<br>修課人數: <b>' + this.y + '</b>';
    		}
        },
        series: data.reg_data
        	
    });
}
        
function show_chart_score(data){
	if(!data.show_score){
		$('#container-score').hide();
		return false ;
	}	
    $('#container-score').highcharts({
    	chart:{type: 'column'/*defaultSeriesType: "column"*/},
		colors: [
					'#50B432', '#AA4643', '#FF3EFF', '#80699B', '#3D96AE', 
  				'darkslategray', '#92A8CD', '#ED561B', 'orchid', '#24CBE5',
					'#64E572', '#FF9655','#FFF263','#6AF9C4', '#0d233a',
					'#8bbc21', '#910000', '#1aadce', '#492970','#f28f43',
					'#77a1e5', '#c42525', '#a6c96a','#4572A7'
					],
        title: {
            text: '歷年修課平均分數'
        },      
        xAxis: {
          categories: data.semester_name
        },         
        yAxis: {
       			min: 0,
                title: {
                    text: '分'
                }
        },
        tooltip: {
          formatter: function() {
        		return '<b>' + this.series.name + '</b>老師<br>平均: <b>' + this.y + '</b>分/共<b>'+this.point.nums+"</b>人";
					}
        },
        series: data.score_data        
    });
}

