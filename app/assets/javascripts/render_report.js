//= require d3

jQuery(function($) {
  var renderReport = function(report) {
    var margin = { top: 20, right: 30, bottom: 30, left: 50 };
    var legend = { width: 160, margin: 20 };

    var height = 400 - margin.top - margin.bottom;
    var width = 960 - margin.right - margin.left - legend.width - legend.margin;

    var timeOnly = d3.time.format("%H:%M");
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
          .ticks(7);

        svg.append("g")
          .attr("class", "x axis")
          .attr("transform", "translate(" + margin.left + "," + (margin.top + height) + ")")
          .call(xAxis)
          .append("text")
          .attr("transform", "translate(0,30)")
          .attr("class", "hover-text x-text")
          .attr("text-anchor", "middle");

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

      legend: function() {
        var g = svg.append("g")
          .attr("class", "legend " + report.type);

        var pos = 20;

        d3.entries(report.data).forEach(function(entry) {
          g.append("text")
            .attr("transform", "translate(30," + pos + ")")
            .text(entry.key);

          g.append("rect")
            .attr("class", entry.key)
            .attr("width", 15)
            .attr("height", 15)
            .attr("transform", "translate(10," + (pos - 13) + ")");

          g.append("text")
            .attr("transform", "translate(30," + (pos + 17) + ")")
            .attr("class", "hover-text " + entry.key + "-text");

          pos += 40;
        });

        g.attr("transform", "translate(" + (margin.left + width + margin.right) + "," + (margin.top + (height - pos + 27) / 2) + ")");
      },

      hoverbox: function() {
        var g = svg.append("g")
          .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

        var hoverbar = g.append("line")
          .attr("class", "hover-bar")
          .attr("x1", 400)
          .attr("x2", 400)
          .attr("y1", 0)
          .attr("y2", height + 20)
          .style("display", "none");

        var timeText = svg.select('.x-text');

        var bisectDate = d3.bisector(function(d) { return d[0]; }).left;

        g.append("rect")
          .attr("class", "hover-box")
          .attr("width", width)
          .attr("height", height)
          .on("mouseover", function() {
            hoverbar.style("display", null);
          })
          .on("mouseout", function() {
            hoverbar.style("display", "none");
            report.series.forEach(function(k) {
              svg.select('.legend .' + k + '-text').text("");
            });
            svg.select('.x-text').text("");
          })
          .on("mousemove", function() {
            var mouse = d3.mouse(this);
            var x0 = (scale.x.invert(mouse[0]) - range.start) / 1000;
            var date = 0;

            report.series.forEach(function(k) {
              var data = report.data[k];
              var i = bisectDate(data, x0, 1),
                d0 = data[i - 1],
                d1 = data[i],
                d = x0 - d0[0] > d1[0] - x0 ? d1 : d0;

              date = Math.abs(x0 - d[0]) > Math.abs(x0 - date) ? date : d[0];

              svg.select('.legend .' + k + '-text')
                .text(d3.round(d[1], 1) + ' ms');
            });

            svg.select('.x-text').text(
              timeOnly(d3.time.second.offset(range.start, date)));

            var pos = mouse[0];
            hoverbar.attr("x1", pos).attr("x2", pos);
            timeText.attr("x", pos);
          });
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
        charts.legend();
        charts.hoverbox();
      }
    };

    charts.area();
  };


  var json = $('#report-data').html();
  if (json) {
    renderReport($.parseJSON(json));
  }
});
