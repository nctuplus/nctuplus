var CourseGroupList = React.createClass({	
	getInitialState: function() {
    return { data: this.props.data };
	},
	
	componentWillReceiveProps: function(next_props){		
		this.setState({data: next_props.data});
	},
	
	findLeader: function(nodes){
		var leader = null ;
		nodes.forEach(function(node){
			if(node.leader)
				leader = node ;
		});
		return leader ;
	},
	
	
	setleaderHandler:function(new_leader){
		var nodes = this.state.data ;
		var old_leader = this.findLeader(nodes);
		if(old_leader)
			old_leader["leader"] = false ;
		new_leader["leader"] = true ;
		this.setState({data: nodes});
		this.props.setLeaderName(new_leader.id, new_leader.course_name); 
	},
	
	render: function(){
		
		var nodes = [] ;
		if(this.state.data)
			this.state.data.forEach(function(node){
				nodes.push(
					<CourseGroupListNode key={node.id} 
						node={node} 
						deleteHandler={this.props.deleteCourse} 
						setleaderHandler={this.setleaderHandler}
					/>
				);
			}.bind(this));
			
		return (
			<table className="table" >
				<thead>
					<tr className="row">
						<th className="col-md-3">課名</th>
						<th className="col-md-3">開課系所</th>
						<th className="col-md-3">永久課號</th>
						<th className="col-md-3">動作</th>
					</tr>
				</thead>
				<tbody>
					{nodes}
				</tbody>
			</table>
		);
	}
});

var CourseGroupListNode = React.createClass({
	
	deleteClickHandler: function(){
		this.props.deleteHandler(this.props.node);
	},

	setleaderClickHandler: function(){
		this.props.setleaderHandler(this.props.node);
	},
	
	
	render: function(){
		var node = this.props.node ;
		
		var setleader ;
		if(!node.leader)
			setleader = (<a href="javascript:void(0);" 
				onClick={this.setleaderClickHandler} >設為代表課
				</a>);
		
		return (
			<tr className="row">
				<td>{node.course_name}</td>
				<td>{node.dep}</td>
				<td>{node.real_id}</td>
				<td>
					{setleader} 
					{setleader ? <br/> : "" }
					<a href="javascript:void(0);" onClick={this.deleteClickHandler} >刪除</a>
				</td>
			</tr>
		);
	}
});