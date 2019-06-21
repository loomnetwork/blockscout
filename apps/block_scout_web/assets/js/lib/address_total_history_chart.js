import $ from 'jquery'
import Chart from 'chart.js'
import sassVariables from '../../css/app.scss'

const config = {
  type: 'line',
  responsive: true,
  data: {
    datasets: []
  },
  options: {
    title: {
      display: true,
      text: 'New Addresses In 14 Days'
    },
    legend: {
      display: false
    },
    scales: {
      xAxes: [{
        gridLines: {
          display: false,
          drawBorder: false
        },
        type: 'time',
        time: {
          unit: 'day',
          stepSize: 1
        }
      }],
      yAxes: [{
        id: 'addressTotal',
        display: true,
        gridLines: {
          display: true,
          drawBorder: false
        }
      }]
    },
    tooltips: {
      mode: 'index',
      intersect: false,
      callbacks: {
        label: ({datasetIndex, yLabel}, {datasets}) => {
          const label = datasets[datasetIndex].label
          if (datasets[datasetIndex].yAxisID === 'time') {
            return `${label}: ${yLabel}`
          } else if (datasets[datasetIndex].yAxisID === 'addressTotal') {
            return `${label}: ${yLabel}`
          } else {
            return yLabel
          }
        }
      }
    }
  }
}

class AddressTotalHistoryChart {
  constructor (el) {
    this.addressTotal = {
      label: 'New Addresses',
      yAxisID: 'addressTotal',
      data: [],
      fill: false,
      backgroundColor: sassVariables.primary,
      borderColor: sassVariables.primary,
      lineTension: 0.3
    }

    config.data.datasets = [this.addressTotal]
    this.chart = new Chart(el, config)
  }

  update (addressTotalHistoryData) {
    if (addressTotalHistoryData) {
      this.addressTotal.data = getAddressTotalHistoryData(addressTotalHistoryData)

      const max = Math.ceil(Math.max(...this.addressTotal.data.map(d => d.y)) * 1.2)
      const min = Math.ceil(Math.min(...this.addressTotal.data.map(d => d.y)) * 0.2)

      const ticks = [max, Math.ceil(max * 0.75), Math.ceil(max * 0.5), Math.ceil(max * 0.25)]
      config.options.scales.yAxes[0].ticks = {
        autoSkip: false,
        maxTicksLimit: 4,
        startAtZero: 0,
        callback: (value) => {
          return Math.abs(value) > 999 ? Math.floor(Math.sign(value) * ((Math.abs(value) / 1000).toFixed(1))) + 'k' : Math.sign(value) * Math.abs(value)
        },
        max,
        min
      }

      config.options.scales.yAxes[0].afterBuildTicks = (scale) => {
        scale.ticks = ticks
      }

      config.options.scales.yAxes[0].beforeUpdate = () => {}

      this.chart.update()
    }
  }
}

function getAddressTotalHistoryData (addressTotalHistoryData) {
  return addressTotalHistoryData.map(txHistoryData => ({
    x: txHistoryData[0].replace('T00:00:00.000000', ''),
    y: `${txHistoryData[1]}`
  }))
}

export function createAddressTotalHistoryChart (el) {
  const dataPath = el.dataset.addressTotal_history_chart_path
  const $chartLoading = $('[data-address-total-chart-loading-message]')
  const $chartError = $('[data-address-total-chart-error-message]')
  const chart = new AddressTotalHistoryChart(el)
  $.getJSON(dataPath, {type: 'JSON'})
    .done(data => {
      const addressTotalHistoryData = JSON.parse(data.address_total_data)
      $(el).show()
      chart.update(addressTotalHistoryData)
    })
    .fail(() => {
      $chartError.show()
    })
    .always(() => {
      $chartLoading.hide()
    })
  return chart
}

$('[data-address-total-chart-error-message]').on('click', _event => {
  $('[data-address-total-chart-loading-message]').show()
  $('[data-address-total-chart-error-message]').hide()
  createAddressTotalHistoryChart($('[data-address-total-chart="AddressTotalHistoryChart"]')[0])
})
