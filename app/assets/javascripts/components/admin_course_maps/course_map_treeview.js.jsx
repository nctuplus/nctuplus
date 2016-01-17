var TreeView = React.createClass({displayName: "TreeView",
	getInitialState: function() {
	//	console.log(this.props.data);
		return { };
  },
  propTypes: {
    levels: React.PropTypes.number,

    expandIcon: React.PropTypes.string,
    collapseIcon: React.PropTypes.string,
    emptyIcon: React.PropTypes.string,
    nodeIcon: React.PropTypes.string,

    color: React.PropTypes.string,
    backColor: React.PropTypes.string,
    borderColor: React.PropTypes.string,
    onhoverColor: React.PropTypes.string,
    selectedColor: React.PropTypes.string,
    selectedBackColor: React.PropTypes.string,

    enableLinks: React.PropTypes.bool,
    highlightSelected: React.PropTypes.bool,
    showBorder: React.PropTypes.bool,
    showTags: React.PropTypes.bool,

    nodes: React.PropTypes.arrayOf(React.PropTypes.number),
		renderList: React.PropTypes.func,
  },

  getDefaultProps: function () {
    return {
     levels: 1,

      expandIcon: 'glyphicon glyphicon-plus',
      collapseIcon: 'glyphicon glyphicon-minus',
      emptyIcon: 'glyphicon',
      nodeIcon: 'glyphicon glyphicon-stop',

      color: undefined,
      backColor: undefined,
      borderColor: undefined,
      onhoverColor: '#F5F5F5', // TODO Not implemented yet, investigate radium.js 'A toolchain for React component styling'
      selectedColor: '#FFFFFF',
      selectedBackColor: '#428bca',

      enableLinks: false,
      highlightSelected: true,
      showBorder: true,
      showTags: false,

      nodes: []
    }
  },
	
	componentWillReceiveProps: function(next_props){	
		
	},
	// no use now
	findNode: function(node, id){
		if(node.id==id){ 
				return node;				
		}	
		if(node.nodes){
			var tt = null;
			for(var i=0, n; n=node.nodes[i];++i){
					tt = this.findNode(n, id);
				if(tt) return tt ;				
			}
		}
		return null;
	},

	setSelected: function(node){
	//	console.log(node);
		if (this.state.selectedNode && this.state.selectedNode.isMounted())
				this.state.selectedNode.setState({selected: false});
		this.setState({selectedNode: node, first: false});// root record the selected node
		node.setState({selected: true});		// set select=true for the selected node
		if(node.props.node.id>0)
			this.props.renderList( node.props.node.id );
		else
			this.props.newCategory(node.props.node.id, node.props.node.parent_id, node.props.node.new_type);
	},

	setNodeId: function(node, key_cnt) {

    if (!node.nodes)
			return false ;
    var _this = this;
		//console.log(_this.props.selectedNodeId);
		var shouldExpand = false ;
    node.nodes.forEach(function checkStates(node) {
			node.nodeId = ++key_cnt;
			var selected = (node.id==_this.props.defaultSelectedNodeId)  ;
			var ex = _this.setNodeId(node, key_cnt);
			node["state"] = {} ;
			node["state"]["expanded"] = ex ;
			node["state"]["selected"] = selected ;
			shouldExpand = shouldExpand || ex || selected ;
			
      return  ;
    });
		return shouldExpand ;
		
  },
	
  render: function() {
    var children = [];
		//console.log(this.props.defaultSelectedNodeId);
    if (this.props.data) {					
      var _this = this;			
			//console.log("def sele:"+_this.props.defaultSelectedNodeId);
			this.setNodeId({ nodes: this.props.data }, 0);
      this.props.data.forEach(function (node) {
        children.push(React.createElement(TreeNode, {node: node, 
                                level: 1, 
                                visible: true, 
																key: node.nodeId,
																defaultSelectId: _this.props.defaultSelectedNodeId,
																onSelected: _this.setSelected,
                                options: _this.props}));
																
																
      });
    }
    return (
      React.createElement("div", {id: "treeview", className: "treeview"}, 
        React.createElement("ul", {className: "list-group"}, 
          children
        )
      )
    );
  }
});


var TreeNode = React.createClass({displayName: "TreeNode",

  getInitialState: function() {
    var node = this.props.node;
    return {
      expanded: (node.state && node.state.hasOwnProperty('expanded')) ?
                  node.state.expanded :
                    (this.props.level < this.props.options.levels) ?
                      true :
                      false,
      selected: (node.state && node.state.hasOwnProperty('selected')) ? 
                  node.state.selected :
                  false 
    }
  },
	
	componentWillReceiveProps: function(next_props){	
		var node = next_props.node;
    this.setState({
      expanded: this.state.expanded || node.state.expanded,
      selected: node.state.selected 
    });
	},
	
	componentDidMount: function(){
		if(this.state.selected)
			this.props.onSelected(this);
	},

  toggleExpanded: function(id, event) {
    this.setState({ expanded: !this.state.expanded });
    event.stopPropagation();	
  },

  toggleSelected: function(nodeId, event) {
		if(!this.state.selected){
			if(this.props.onSelected)
				this.props.onSelected(this);
		//	console.log(this.props.node.text);
		}
    event.stopPropagation();
  },

  render: function() {

    var node = this.props.node;
    var options = this.props.options;
		
    var style;
    if (!this.props.visible) {

      style = { 
        display: 'none' 
      };
    }
    else {

      if (options.highlightSelected && this.state.selected) {
        style = {
          color: options.selectedColor,
          backgroundColor: options.selectedBackColor
        };
      }
      else {
        style = {
          color: node.color || options.color,
          backgroundColor: node.backColor || options.backColor
        };
      }

      if (!options.showBorder) {
        style.border = 'none';
      }
      else if (options.borderColor) {
        style.border = '1px solid ' + options.borderColor;
      }
    } 

    var indents = [];
    for (var i = 0; i < this.props.level-1; i++) {
      indents.push(React.createElement("span", {className: "indent", key: i }));
    }

    var expandCollapseIcon;
    if (node.nodes) {
      if (!this.state.expanded) {
        expandCollapseIcon = (
          React.createElement("span", {className: options.expandIcon, 
                onClick: this.toggleExpanded.bind(this, node.nodeId)}
          )
        );
      }
      else {
        expandCollapseIcon = (
          React.createElement("span", {className: options.collapseIcon, 
                onClick: this.toggleExpanded.bind(this, node.nodeId)}
          )
        );
      }
    }
    else {
      expandCollapseIcon = (
        React.createElement("span", {className: options.emptyIcon})
      );
    }

    var nodeIcon = (
      React.createElement("span", {className: "icon"}, 
        React.createElement("i", {className: node.icon || options.nodeIcon})
      )
    );

    var nodeText;
    if (options.enableLinks) {
      nodeText = (
        React.createElement("a", {href: node.href/*style="color:inherit;"*/}, 
          node.text
        )
      );
    }
    else {
      nodeText = (
        React.createElement("span", null, node.text)
      );
    }

    var badges;
    if (options.showTags && node.tags) {
      badges = node.tags.map(function (tag) {
        return (
          React.createElement("span", {className: "badge"}, tag)
        );
      });
    }

    var children = [];
    if (node.nodes) {
      var _this = this;
					
      node.nodes.forEach(function (node) {
        children.push(React.createElement(TreeNode, {node: node, 
                                level: _this.props.level+1, 
                                visible: _this.state.expanded && _this.props.visible, 
																onSelected: _this.props.onSelected,	
																defaultSelectId: _this.props.defaultSelectId,														
																key: node.nodeId,
                                options: options}));
															
      });
    }

    return (
      <li className='list-group-item'
          style={style}
          onClick={this.toggleSelected.bind(this, node.nodeId)}
      >
        {indents}
        {expandCollapseIcon}
        {nodeIcon}
        {nodeText}
        {badges}
        {children}
      </li>
    );
  }
});