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
          stepSize: 7
        }
      }],
      yAxes: [{
        id: 'addressTotal',
        type: 'logarithmic',
        display: true,
        gridLines: {
          display: false,
          drawBorder: false
        },
        ticks: {
          beginAtZero: true,
          callback: (value) => `${value}`,
          maxTicksLimit: 4
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
      pointRadius: 0,
      backgroundColor: sassVariables.primary,
      borderColor: sassVariables.primary,
      lineTension: 0
    }

    config.data.datasets = [this.addressTotal]
    this.chart = new Chart(el, config)
  }

  update (addressTotalHistoryData) {
    this.addressTotal.data = getAddressTotalHistoryData(addressTotalHistoryData)
    this.chart.update()
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
