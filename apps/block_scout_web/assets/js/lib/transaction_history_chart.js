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
          stepSize: 7
        }
      }],
      yAxes: [{
        id: 'transaction',
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
  constructor (el, transactionHistoryData) {
    this.transaction = {
      label: 'Transactions',
      yAxisID: 'transaction',
      data: [],
      fill: false,
      pointRadius: 0,
      backgroundColor: sassVariables.primary,
      borderColor: sassVariables.primary,
      lineTension: 0
    }

    config.data.datasets = [this.transaction]
    this.chart = new Chart(el, config)
  }

  update (transactionHistoryData) {
    this.transaction.data = getTransactionHistoryData(transactionHistoryData)
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
