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
      text: 'Transaction History In 14 Days'
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
        id: 'transaction',
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
          } else if (datasets[datasetIndex].yAxisID === 'transaction') {
            return `${label}: ${yLabel}`
          } else {
            return yLabel
          }
        }
      }
    }
  }
}

class TransactionHistoryChart {
  constructor (el) {
    this.transaction = {
      label: 'Transactions',
      yAxisID: 'transaction',
      data: [],
      fill: false,
      backgroundColor: sassVariables.primary,
      borderColor: sassVariables.primary,
      lineTension: 0.3
    }

    config.data.datasets = [this.transaction]
    this.chart = new Chart(el, config)
  }

  update (transactionHistoryData) {
    this.transaction.data = getTransactionHistoryData(transactionHistoryData)

    const max = Math.ceil(Math.max(...this.transaction.data.map(d => d.y)) * 1.2)
    const min = Math.ceil(Math.min(...this.transaction.data.map(d => d.y)) * 0.2)

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

function getTransactionHistoryData (transactionHistoryData) {
  return transactionHistoryData.map(txHistoryData => ({
    x: txHistoryData[0].replace('T00:00:00.000000', ''),
    y: `${txHistoryData[1]}`
  }))
}

export function createTransactionHistoryChart (el) {
  const dataPath = el.dataset.transaction_history_chart_path
  const $chartLoading = $('[data-transaction-chart-loading-message]')
  const $chartError = $('[data-transaction-chart-error-message]')
  const chart = new TransactionHistoryChart(el, [])
  $.getJSON(dataPath, {type: 'JSON'})
    .done(data => {
      const transactionHistoryData = JSON.parse(data.transaction_data)
      $(el).show()
      chart.update(transactionHistoryData)
    })
    .fail(() => {
      $chartError.show()
    })
    .always(() => {
      $chartLoading.hide()
    })
  return chart
}

$('[data-transaction-chart-error-message]').on('click', _event => {
  $('[data-transaction-chart-loading-message]').show()
  $('[data-transaction-chart-error-message]').hide()
  createTransactionHistoryChart($('[data-transaction-chart="TransactionHistoryChart"]')[0])
})
