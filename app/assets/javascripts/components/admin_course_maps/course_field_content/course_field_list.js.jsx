var CourseFieldList = React.createClass({	
	getInitialState: function() {
    return { 
			data: this.props.data,
			expanded_node_ids: []
		};
	},
		
	componentWillReceiveProps: function(next_props){
		this.setState({data: next_props.data, expanded_node_ids: []});
	},

	
	deleteNode: function(node_id){
		var data = this.state.data;
		data.courses = _.reject(this.state.data.courses, function(node){
			return node.id == node_id ;
		});
		this.setState({data: data});
		//TODO: ajax delete course
	},
	
	expandHandler:function(node_id, action){
		var ids = this.state.expanded_node_ids ;
		if(action=="add")
			ids.push(node_id) ;		
		else
			ids = _.without(ids, node_id);
		
		this.setState({expanded_node_ids: ids });
	},
	
	render: function(){
			
		var nodes = [];
		//console.log(this.state.data);
		if(this.state.data && this.state.data.courses)		
			this.state.data.courses.forEach(function (node) {
					var expand = (_.indexOf(this.state.expanded_node_ids, node.id)!=-1);
					nodes.push(
						<CourseFieldListNode key={node.course_id} node={node} expanded={expand} delete_node={this.deleteNode} expandHandler={this.expandHandler} />
					);
					if(node.courses){
						node.courses.forEach(function (child_node){											
							nodes.push(
								<CourseFieldListNodeChild key={child_node.course_id} node={child_node} visible={expand} />
							);
						}.bind(this));				
					}
				}.bind(this));
		
		return (
			<table className="table course-table" >
				<thead>
					<tr className="row">
						<th className="col-md-1"></th>
						<th className="col-md-2">課名</th>
						<th className="col-md-2">開課系所</th>
						<th className="col-md-2">永久課號</th>
						<th className="col-md-1">學分</th>
						<th className="col-md-1">學期</th>
						<th className="col-md-1">採計學分</th>
						<th className="col-md-2">動作</th>
					</tr>
				</thead>
				<tbody>
					{nodes}
				</tbody>		
			</table>
		);
	}
});

var CourseFieldListNode = React.createClass({	
	getInitialState: function() {
    return {};
	},
	
	deleteClickHandler: function(){
		if(confirm("確定要刪除嗎?"))
			this.props.delete_node(this.props.node.id);
	},
	
	expandClickHandler: function(){	
		this.props.expandHandler(this.props.node.id, ((!this.props.expanded) ? "add" : "delete") );
	},
	
	render: function(){
		
		var node = this.props.node ;
		
		var tr_className = "row", tr_style={};
		var tds = [] ;
		var courses = [] ;

		// 0
		if(node.courses && !this.props.isChild){
			tr_className+= " zopl";
			tr_style["backgroundColor"] = "#BBFFEE";
			var icon ;
			if(!this.props.expanded)	
				icon	= <i className="fa fa-plus" /> ;
			else
				icon	= <i className="fa fa-minus" /> ;
			tds.push(
				<td className="col-md-1 clickable-hover" onClick={this.expandClickHandler}>
					{icon}
				</td>
			);
		}else
			tds.push(<td className="col-md-1" />);

		// 1
		tds.push(<td><CourseSemesterSelect grade={node.grade} half={node.half} /></td>);//year, half
		tds.push(<td><CourseFieldListRecord record={this.props.node.record_type } /></td>);//學分採記
		
		return (
			<tr className={tr_className} style={tr_style}>
				{tds[0]}
				<td>{node.course_name}</td>
				<td>{node.dep}</td>
				<td>{node.real_id}</td>
				<td>{node.credit}</td>
				{tds[1]}
				{tds[2]}
				<td>
					<a href="javascript:void(0);" onClick={this.deleteClickHandler} >刪除</a>
				</td>		
			</tr>
		);
	}
});

var CourseFieldListRecord = React.createClass({
	getInitialState: function() {
    return { record: this.props.record };
	},
	recordClickHandler: function(){
		this.setState({record: !this.state.record });
		//TODO: ajax update record type
	},
	render: function(){
		var class_name; 
		if(this.state.record)
			class_name = "clickable-hover fa fa-check text-color-green";
		else
			class_name = "clickable-hover fa fa-times text-color-red" ;
		
		return (
			<i className={class_name}
				onClick={this.recordClickHandler} />
		);
	}
});

var CourseFieldListNodeChild = React.createClass({	
	
	render: function(){
		var node = this.props.node; 
		var tr_style ;
		if(!this.props.visible)
			tr_style = {display: "none"};
		
		return (
			<tr className="row" style={tr_style}>
				<td><i className="fa fa-angle-right" /></td>
				<td>{node.course_name}</td>
				<td />
				<td>{node.real_id}</td>
				<td>{node.credit}</td>
				<td />
				<td />
				<td />				
			</tr>
		);
	}
});

var CourseSemesterSelect = React.createClass({
	getInitialState: function() {
    return { grade: this.props.grade, half: this.props.half };
	},
		
	componentWillReceiveProps: function(next_props){
		this.setState({ grade: next_props.grade, half: next_props.half });
	},
	
	selectChange1: function(e){
		this.setState({grade: e.target.value});
		//TODO
	},
	selectChange2: function(e){
		this.setState({half: e.target.value});
		//TODO 
	},
	
	render: function(){
		return (
			<div>
				<select value={this.state.grade} onChange={this.selectChange1}>
					<option value="*">*</option>
					<option value="1">大一</option>
					<option value="2">大二</option>
					<option value="3">大三</option>
					<option value="4">大四</option>
				</select>
				<select value={this.state.half} onChange={this.selectChange2}>
					<option value="*">*</option>
					<option value="1">上</option>
					<option value="2">下</option>
				</select>
			</div>
		);
	}
});