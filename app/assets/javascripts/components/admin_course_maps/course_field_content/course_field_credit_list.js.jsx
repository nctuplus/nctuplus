var CourseFieldCreditList = React.createClass({
	render: function(){
		var data = this.props.data ;
		
		var credit_list= [];
		data.credit_need.forEach(function(data, idx){
			credit_list.push(
				<div key={idx}>
					<div className="col-md-2 memo">{data.memo}</div>
					<div className="col-md-3">至少學分數</div>
					<div className="col-md-2 credit-need">{data.credit}</div>
				</div>
			);
		});
		
		var edit_but ;
		if(data.field_type!=1)
			edit_but = (
				<div className="col-md-3">				
					<button type="button" className="btn btn-circle btn-warning">
						<i className="fa fa-pencil"></i>
					</button>
					<button type="button" className="btn btn-circle btn-danger" >
						<i className="fa fa-trash-o"></i>
					</button>
				</div>
			);
		return (
			<Row>
				{credit_list}
				{edit_but}
			</Row>
		);
	}
});