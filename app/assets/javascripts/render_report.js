//= require d3

jQuery(function($) {
  var renderReport = function(report) {
    function throttle(func, timeout) {
      var next = null, timer = null;
      return function() {
        var context = this, args = arguments;

        var invoke = function() {
          if (next) next();
          timer = null;
          next = null;
        };

        if (!timer) {
          timer = setTimeout(invoke, timeout);
          func.apply(context, args);
          return;
        }

        next = function() { func.apply(context, args); };
      };
    };

    var margin = { top: 45, right: 210, bottom: 30, left: 50 };
    var legend = { width: 160, margin: 20 };
    var header = { margin: 20 };

    var height = 400 - margin.top - margin.bottom;
    var width = 960 - margin.right - margin.left;

    var timeOnly = d3.time.format("%H:%M");
    var timeFormat = d3.time.format('%Y-%m-%d %H:%M:%S UTC');
    var prettyDateFormat = d3.time.format('%-d %b %Y');

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

    var translate = function(x, y) {
      return function(selection) {
        selection.attr('transform', 'translate(' + x + ',' + y + ')');
      };
    };

    var charts = {
      axes: function() {
        var xAxis = d3.svg.axis()
          .scale(scale.x)
          .orient('bottom')
          .ticks(7);

        svg.append("g")
          .attr("class", "x axis")
          .call(translate(margin.left, margin.top + height))
          .call(xAxis)
          .append("text")
          .call(translate(0, 30))
          .attr("class", "hover-text x-text")
          .attr("text-anchor", "middle");

        var yAxis = d3.svg.axis()
          .scale(scale.y)
          .orient('left');

        svg.append("g")
          .attr("class", "y axis")
          .call(translate(margin.left, margin.top))
          .call(yAxis);

        svg.append("g")
          .attr("class", "grid")
          .call(translate(margin.left, margin.top))
          .call(xAxis.tickSize(height, 0, 0).tickFormat(""));

        svg.append("g")
          .attr("class", "grid")
          .call(translate(margin.left, margin.top))
          .call(yAxis.tickSize(-width, 0, 0).tickFormat(""));
      },

      legend: function() {
        var g = svg.append("g")
          .attr("class", "legend " + report.type);

        var pos = 20;

        d3.entries(report.data).forEach(function(entry) {
          g.append("text")
            .call(translate(30, pos))
            .text(entry.key);

          g.append("rect")
            .attr("class", entry.key)
            .attr("width", 15)
            .attr("height", 15)
            .call(translate(10, pos - 13));

          g.append("text")
            .call(translate(30, pos + 17))
            .attr("class", "hover-text " + entry.key + "-text");

          pos += 40;
        });

        g.call(translate(margin.left + width + legend.margin, margin.top + (height - pos + 27) / 2));
      },

      hoverbox: function() {
        var g = svg.append("g")
          .call(translate(margin.left, margin.top));

        var hoverbar = g.append("line")
          .attr("class", "hover-bar")
          .attr("x1", 400)
          .attr("x2", 400)
          .attr("y1", 0)
          .attr("y2", height + 20)
          .style("display", "none");

        var timeText = svg.select('.x-text');

        var bisectDate = d3.bisector(function(d) { return d[0]; }).left;

        var update = throttle(function(mouse) {
          if (!mouse) {
            report.series.forEach(function(k) {
              svg.select('.legend .' + k + '-text').text("");
            });
            svg.select('.x-text').text("");
            return;
          }

          var date = 0;
          var x0 = (scale.x.invert(mouse[0]) - range.start) / 1000;

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
        }, 50);

        g.append("rect")
          .attr("class", "hover-box")
          .attr("width", width)
          .attr("height", height)
          .on("mouseover", function() {
            hoverbar.style("display", null);
          })
          .on("mouseout", function() {
            hoverbar.style("display", "none");
            update(null);
          })
          .on("mousemove", function() {
            var mouse = d3.mouse(this);
            update(mouse);

            var pos = mouse[0];
            hoverbar.attr("x1", pos).attr("x2", pos);
            timeText.attr("x", pos);
          });
      },

      labels: function() {
        var g = svg.append("g")
          .call(translate(margin.left, header.margin));

        g.append("text")
          .call(translate(width / 2, 0))
          .attr("class", "label title")
          .attr("text-anchor", "middle")
          .text(report.title);

        g.append("text")
          .call(translate(width / 2, 15))
          .attr("class", "label subtitle")
          .attr("text-anchor", "middle")
          .text(prettyDateFormat(range.start) + " \u2014 " + prettyDateFormat(range.end));

        var y = svg.append("g")
          .call(translate(0, margin.top))
          .append("text")
          .attr("class", "label y-axis")
          .attr("text-anchor", "middle")
          .call(translate(15, height / 2))
          .text(report.labels.y);

        y.attr("transform", y.attr("transform") + ", rotate(-90)");
      },

      area: function() {
        var area = d3.svg.area()
          .x(function(e) { return scale.x(d3.time.second.offset(range.start, e[0])); })
          .y0(height)
          .y1(function(e) { return scale.y(e[1]); });

        var g = svg.append("g")
          .attr("class", "area paths")
          .call(translate(margin.left, margin.top));

        d3.entries(report.data).forEach(function(entry) {
          g.append("path")
            .datum(entry.value)
            .attr("class", entry.key)
            .attr("d", area);
        });

        charts.axes();
        charts.legend();
        charts.hoverbox();
        charts.labels();
      }
    };

    charts.area();
  };


  var json = $('#report-data').html();
  if (json) {
    renderReport($.parseJSON(json));
  }
});
