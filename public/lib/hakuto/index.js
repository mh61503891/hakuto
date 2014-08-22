// settings //////////////////////////////////////////////////////////////
var layouts = {
  content: {
    width: '100%',
    height: '100%'
  },
  stage: {
    width: (new Date().getFullYear() - new Date(0).getFullYear() + 1) * 30,
    height: '100%'
  },
  header: {
    width: 30,
    height: 10
  },
  cell: {
    height: 30,
    width: 30
  },
  inspector: {
    width: 300
  }
}

// zoom //////////////////////////////////////////////////////////////////
var zoom = d3.behavior.zoom().scaleExtent([1, 8]).on("zoom", on_zoom)

function on_zoom() {
  var current_x = d3.event.translate[0]
  var current_y = d3.event.translate[1]
  if (current_x > layouts.inspector.width) {
    var x = layouts.inspector.width
  } else if (current_x < ($(window).width() - layouts.stage.width * d3.event.scale)) {
    var x = ($(window).width() - layouts.stage.width * d3.event.scale)
  } else {
    var x = current_x
  }
  if (current_y > 0) {
    var y = 0
  } else if (current_x < $(window).height() - layouts.stage.height) {
    var y = $(window).height() - layouts.stage.height
  } else {
    var y = current_y
  }
  // console.log(d3.event.translate, [x,y], d3.event.scale)
  zoom.translate([x, y])
  stage.attr("transform", "translate(" + [x, y] + ")scale(" + d3.event.scale + ")")
  header.attr("transform", "translate(" + [x, 0] + ")scale(" + d3.event.scale + ")")
}

// svg ///////////////////////////////////////////////////////////////////
var svg = d3.select('div#display').append('svg')
  .classed('content', true)
  .attr('width', layouts.content.width)
  .attr('height', layouts.content.height)

// stage
var stage = svg.append('g')
  .attr('id', 'stage')
  .call(zoom)
  .append('g')
stage
  .append('g')
  .classed('container', true)
  .append('svg:rect')
  .attr('x', 0)
  .attr('y', 0)
  .attr('width', layouts.stage.width)
  .attr('height', layouts.stage.height)

// header
var header = svg.append('g')
  .attr('id', 'header')

// inspector
var inspector = svg.append('g')
  .attr('id', 'inspector')
inspector.append('svg:rect')
  .classed('container', true)
  .attr('x', 0)
  .attr('y', 0)
  .attr('width', layouts.inspector.width)
  .attr('height', '100%')
inspector.append('foreignObject')
  .attr('x', 0)
  .attr('y', 0)
  .attr('width', layouts.inspector.width)
  .attr('height', '100%')
  .append('xhtml:div')
  .classed('container', true)

// objects ///////////////////////////////////////////////////////////////

var papers = new function() {
  this.data = {}
  this.exist = function(id) {
    return id in this.data
  }
  this.append = function(id, paper) {
    if (!this.exist(id)) {
      this.data[id] = paper
    }
  }
  this.get = function(id) {
    return this.data[id]
  }
}()

var nodes = new function() {
  this.index = {}
  this.data = []
  this.stacks = {}
  this.exist = function(id) {
    return id in this.index
  }
  this.get = function(id) {
    return this.exist(id) ? this.data[this.index[id]] : undefined
  }
  this.append = function(id, node) {
    if (this.index[id]) {
      return false
    }
    if (!this.stacks[node.year]) {
      this.stacks[node.year] = []
    }
    node['rank'] = this.stacks[node.year].length
    this.stacks[node.year].push(node)
    this.index[id] = this.data.push(node) - 1
    return true
  }
  this.update = function(id, params) {
    if (this.exist(id)) {
      $.extend(this.data[this.index[id]], params)
    }
  }
  this.update_all = function(params) {
    this.data.forEach(function(datum) {
      $.extend(datum, params)
    })
  }
}()

// functions /////////////////////////////////////////////////////////////

function init_grid() {
  for (var year = 1970; year <= new Date().getFullYear(); year++) {
    var cell = header.append('svg:g')
    cell.append('svg:rect')
      .attr('x', function(d) {
        return (year - 1970) * layouts.header.width
      })
      .attr('y', 0)
      .attr('width', layouts.header.width)
      .attr('height', layouts.header.height)
    cell.append('svg:text')
      .attr('x', function(d) {
        return (year - 1970) * layouts.header.width + layouts.header.width * 0.5
      })
      .attr('y', layouts.header.height * 0.5)
      .attr('text-anchor', 'middle')
      .attr('dominant-baseline', 'middle')
      .text(year)
  }
}

function update_grid() {
  var node = stage.selectAll('g.node').data(nodes.data, function(paper) {
    return paper.id
  })
  var cell = node.enter()
    .append('svg:g')
    .attr("class", "cell")
  cell.on('click', function(node) {
    on_select(node)
  })
  cell.append('svg:rect')
    .attr('x', function(paper) {
      return (paper.year - 1970) * 30
    })
    .attr('y', function(paper) {
      return layouts.header.height + paper.rank * 30
    })
    .attr('width', layouts.cell.width)
    .attr('height', layouts.cell.height)
  cell.append('svg:path')
    .attr('d', function(paper) {
      s = 'M'
      s += (paper.year - 1970) * 30 + 30 - 10
      s += ','
      s += layouts.header.height + paper.rank * 30 + 30
      s += 'l'
      s += '10,0'
      s += 'l'
      s += '0,-10'
      return s
    })
    .attr("class", "existence")
  cell.append('svg:path')
    .attr('d', function(paper) {
      s = 'M'
      s += (paper.year - 1970) * 30 - 0
      s += ','
      s += layouts.header.height + paper.rank * 30 + (30 - 10)
      s += 'l'
      s += '0,10'
      s += 'l'
      s += '10,0'
      return s
    })
    .attr("class", "view")
  cell.append('svg:path')
    .attr('d', function(paper) {
      s = 'M'
      s += (paper.year - 1970) * 30
      s += ','
      s += layouts.header.height + paper.rank * 30 + 10
      s += 'l'
      s += '0,-10'
      s += 'l'
      s += '10,0'
      return s
    })
    .attr("class", "check")
  cell.append('svg:path')
    .attr('d', function(paper) {
      s = 'M'
      s += (paper.year - 1970) * 30 + 30 - 10
      s += ','
      s += layouts.header.height + paper.rank * 30
      s += 'l'
      s += '10,0'
      s += 'l'
      s += '0,10'
      return s
    })
    .attr("class", "memo")

  node
    .classed('selected', function(d) {
      return d.context == 'selected'
    })
    .classed('cited', function(d) {
      return d.context == 'cited'
    })
    .classed('citing', function(d) {
      return d.context == 'citing'
    })
    .classed('unselected', function(d) {
      return d.context == ''
    })
    .classed('exist', function(d) {
      return d.acm_id != null
    })
    .classed('not-exist', function(d) {
      return d.acm_id == null
    })
    .classed('viewed', function(d) {
      return papers.exist(d.id)
    })
    .classed('not-viewed', function(d) {
      return !papers.exist(d.id)
    })
    .classed('memoed', function(d) {
      return papers.exist(d.id)
    })
    .classed('not-memoed', function(d) {
      return !papers.exist(d.id)
    })
    .classed('checked', function(d) {
      return papers.exist(d.id)
    })
    .classed('not-checked', function(d) {
      return !papers.exist(d.id)
    })


}


function on_select(node) {
  console.log('on_select', node)
  if (papers.exist(node.id)) {
    var paper = papers.get(node.id)
    if (!nodes.exist(node.id)) {
      nodes.append(node.id, {
        id: paper.id,
        year: paper.year,
        acm_id: paper.acm_id
      })
    }
    nodes.update_all({
      context: ''
    })
    paper.references.forEach(function(child) {
      if (!nodes.exist(child.id)) {
        nodes.append(child.id, {
          id: child.id,
          year: child.year,
          acm_id: child.acm_id
        })
      }
      nodes.update(child.id, {
        context: 'cited'
      })
    })
    paper.citings.forEach(function(child) {
      if (!nodes.exist(child.id)) {
        nodes.append(child.id, {
          id: child.id,
          year: child.year,
          acm_id: child.acm_id
        })
      }
      nodes.update(child.id, {
        context: 'citing'
      })
    })

    update_inspector(node.id)

    nodes.update(node.id, {
      context: 'selected'
    })

    update_grid()



    // if (!nodes.exist(id)) {
    //   nodes.append(id, {
    //     id: paper.id,
    //     year: paper.year
    //   })
    // }
    // nodes.update_all({
    //   context: ''
    // })
    // nodes.update(id, {
    //   context: 'selected'
    // })
    // update_inspector(id)
    // update_grid()
    // //
  } else {
    $.getJSON('paper.json', node, function(paper) {
      papers.append(paper.id, paper)
      //
      if (!nodes.exist(node.id)) {
        nodes.append(node.id, {
          id: paper.id,
          year: paper.year,
          acm_id: paper.acm_id
        })
      }

      nodes.update_all({
        context: ''
      })
      paper.references.forEach(function(child) {
        if (!nodes.exist(child.id)) {
          nodes.append(child.id, {
            id: child.id,
            year: child.year,
            acm_id: child.acm_id
          })
        }
        nodes.update(child.id, {
          context: 'cited'
        })
      })
      paper.citings.forEach(function(child) {
        if (!nodes.exist(child.id)) {
          nodes.append(child.id, {
            id: child.id,
            year: child.year,
            acm_id: child.acm_id
          })
        }
        nodes.update(child.id, {
          context: 'citing'
        })
      })

      update_inspector(node.id)

      nodes.update(node.id, {
        context: 'selected'
      })

      update_grid()
    }).fail(function() {
      console.error('TODO', arguments)
    })
  }
}


function update_inspector(id) {
  if (papers.exist(id)) {
    var content = $('g#inspector div.container')
    content.empty()
    content.append($('#inspector-tmpl').tmpl(papers.get(id))).hide().fadeIn(300)
    // $('g.inspector div.content#inspector').empty()
    // $('#inspector').append($('#inspector-tmpl').tmpl(papers.get(id))).hide().fadeIn(300)
  }
}

$(function() {
  // bindings
  $('#inspector').delegate('i.ppp-suyaxa', 'click', function(event) {
    var id = $(this).data('id')
  })
  $('#inspector').delegate('i.ppp-thundoc', 'click', function(event) {
    var id = $(this).data('id')
  })
  $('#inspector').delegate('i.ppp-favo', 'click', function(event) {
    var id = $(this).data('id')
  })

  init_grid()
  // update_grid()
  // update_inspector()
  // pyon(2)
  on_select({
    id: 2,
    acm_id: 1558031
  })
  // pyon('1558031')

})
