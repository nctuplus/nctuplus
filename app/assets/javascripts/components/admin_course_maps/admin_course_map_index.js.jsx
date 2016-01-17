
var AdminCourseMapIndexTable = React.createClass({
	getInitialState: function() {
    return {data: [], ready: true};
  },
	componentDidMount: function() {
    $.ajax({
      url: document.location.pathname,
      dataType: 'json',
      cache: false,
      success: function(data) {
        this.setState({data: data, ready:true});
      }.bind(this),
      error: function(xhr, status, err) {
        console.error("internal server error");
				this.setState({raedy:false});
      }.bind(this)
    });
  },
	shouldComponentUpdate: function(nextProps, 	nextState){
		console.log("call");
		return true;
	},
	render: function() {
		//console.log(1);
		var content = [] ;
		if(this.state.ready){
			this.state.data.map(function(tr, idx) {
          content.push(<AdminCourseMapIndexTableTr key={idx} data={tr} />);
        })
		}else
			content.push(<tr><td colSpan="5" className="text-center">Server crashed X(</td></tr>);
		var Table = ReactBootstrap.Table ;
		return (		
			<Table>
				<thead>
				<tr>
					<th>標題</th>
					<th>適用之系所</th>
					<th>適用之入學年度</th>
					<th>建立者</th>
					<th>功能</th>
				</tr>
				</thead>
				<tbody>
				{content}
				</tbody>
			</Table>
		);
	}
});


var AdminCourseMapIndexTableTr = React.createClass({
	render: function() {
		return (
			<tr> 
				<td>
					<a href={"/admin/course_maps/" + this.props.data.id + "/edit"}>{this.props.data.name}</a>
				</td>
				<td>{ this.props.data.dep}</td>
				<td>{ this.props.data.year}</td>
				<td>{ this.props.data.creater}</td>
				<td>
					<a data-confirm="Are you sure?" data-method="delete" href={"/course_maps/"+this.props.data.id} rel="nofollow">刪除</a>
				</td>
			</tr>
		);
	}
});



