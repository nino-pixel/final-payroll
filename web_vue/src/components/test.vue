<template>
    <div>
      <h2>Test ECharts Integration</h2>
      <v-chart :option="chartOption" style="height: 400px;"></v-chart>
    </div>
  </template>
  
  <script>
  export default {
    data() {
      return {
        chartOption: {
          title: {
            text: 'Test Chart'
          },
          tooltip: {},
          xAxis: {
            data: ['A', 'B', 'C', 'D']
          },
          yAxis: {},
          series: [{
            type: 'bar',
            data: [5, 20, 36, 10]
          }]
        }
      };
    }
  };
  </script>
  