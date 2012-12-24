;(function($){
  window.CPANTS = function(){};

  CPANTS.prototype = {
    init_linechart: function(id) {
      var chart = new Highcharts.Chart({
        credits: { enabled: false },
        title: { text: '' },
        chart: {
          renderTo: id,
          type: 'line',
          marginRight: 130,
          marginTop: 25,
          marginBottom: 75
        },
        xAxis: { title: '' },
        yAxis: {
          title: '',
          min: 0
        },
        tooltip: {
          formatter: function() {
            return '<b>'+ this.series.name +'</b><br/>'+
            this.point.name +': '+ this.y;
          }
        },
        legend: { borderWidth: 0 }
      });
      return chart;
    },
    init_columnchart: function(id) {
      var chart = new Highcharts.Chart({
        credits: { enabled: false },
        title: { text: '' },
        chart: {
          renderTo: id,
          type: 'column',
          marginRight: 130,
          marginTop: 25,
          marginBottom: 75
        },
        plotOptions: {
          column: { stacking: 'normal' }
        },
        xAxis: { title: '', labels: { style: { display: "none" } } },
        yAxis: {
          title: '',
          min: 0
        },
        tooltip: {
          formatter: function() {
            return '<b>'+ this.series.name +'</b><br/>'+
            this.x +': '+ this.y;
          }
        },
        legend: { borderWidth: 0 }
      });
      return chart;
    },
    load_chart: function(chart, url, opts) {
      jQuery.ajax({
        type: 'GET',
        url: url,
        data: opts,
        success: function(json) {
          var series = json.series;
          for (var i in series) {
            chart.addSeries(series[i], false);
          }
          if (json.xaxis) {
            chart.xAxis[0].setCategories(json.xaxis, false);
          }
          if (json.yaxis) {
            chart.yAxis[0].setCategories(json.yaxis, false);
          }
          chart.redraw()
        },
        error: function(req, status, error) {
          // FIXME
        },
        complete: function(req, status) {
          // FIXME
        },
        timeout: 10000
      });
    },
    init_tablesorter: function() {
      $.tablesorter.addParser({
        id: "integer",
        is: function() { return false },
        format: function(s) { return parseInt(s); },
        type: "numeric"
      });
      $('.tablesorter').tablesorter({
        textExtraction: function(e) {
          return $(e).attr('sort') || e.innerHTML;
        }
      });
    },
    init_tab: function(id) {
      $('#'+id+' a').click(function(e) {
        e.preventDefault(); $(this).tab('show');
      });
    }
  };
}(jQuery));
