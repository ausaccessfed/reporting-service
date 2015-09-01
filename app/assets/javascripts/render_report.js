//= require d3

jQuery(function($) {
  var renderReport = function(report) {
    var margin = { top: 20, right: 30, bottom: 30, left: 50 };
    var height = 400 - margin.top - margin.bottom;
    var width = 900 - margin.right - margin.left;

    var timeFormat = d3.time.format('%Y-%m-%d %H:%M:%S UTC');
    var range = {
      start: timeFormat.parse(report.range.start),
      end: timeFormat.parse(report.range.end)
    };

    var scale = {
      x: d3.time.scale()
        .range([0, width])
        .domain([range.start, range.end]),

      y: (function() {
        var yExtents = [];
        var ySelector = function(item) { return item[1]; };

        d3.values(report.data).forEach(function(a) {
          yExtents = yExtents.concat(d3.extent(a, ySelector));
        });

        var domain = d3.extent(yExtents);
        if (domain[0] > 0) domain[0] = 0;
        return d3.scale.linear().range([0, height]).domain(domain.reverse());
      })()
    };

    var svg = d3.select('svg#report-output')
      .attr("class", report.type);
    svg.select("text.placeholder").remove();

    var charts = {
      axes: function() {
        var xAxis = d3.svg.axis()
          .scale(scale.x)
          .orient('bottom')
          .ticks(14);

        svg.append("g")
          .attr("class", "x axis")
          .attr("transform", "translate(" + margin.left + "," + (margin.top + height) + ")")
          .call(xAxis);

        var yAxis = d3.svg.axis()
          .scale(scale.y)
          .orient('left');

        svg.append("g")
          .attr("class", "y axis")
          .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
          .call(yAxis);

        svg.append("g")
          .attr("class", "grid")
          .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
          .call(xAxis.tickSize(height, 0, 0).tickFormat(""));

        svg.append("g")
          .attr("class", "grid")
          .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
          .call(yAxis.tickSize(-width, 0, 0).tickFormat(""));
      },

      area: function() {
        var area = d3.svg.area()
          .interpolate("cardinal")
          .x(function(e) { return scale.x(d3.time.second.offset(range.start, e[0])); })
          .y0(height)
          .y1(function(e) { return scale.y(e[1]); });

        var g = svg.append("g")
          .attr("class", "area paths")
          .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
        d3.entries(report.data).forEach(function(entry) {
          g.append("path")
            .datum(entry.value)
            .attr("class", entry.key)
            .attr("d", area);
        });

        charts.axes();
      }
    };

    charts.area();
  };


  var json = $('#report-data').html();
  if (json) {
    renderReport($.parseJSON(json));
  }
});
