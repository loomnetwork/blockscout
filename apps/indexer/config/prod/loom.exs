use Mix.Config

config :indexer,
  block_interval: :timer.seconds(5),
  blocks_batch_size: 20,
  blocks_concurrency: 1,
  receipts_concurrency: 1,
  json_rpc_named_arguments: [
    transport: EthereumJSONRPC.HTTP,
    transport_options: [
      http: EthereumJSONRPC.HTTP.HTTPoison,
      url: System.get_env("ETHEREUM_JSONRPC_HTTP_URL") || "http://localhost:46658/eth",
      http_options: [recv_timeout: :timer.minutes(1), timeout: :timer.minutes(1), hackney: [pool: :ethereum_jsonrpc]]
    ],
    variant: EthereumJSONRPC.Loom
  ],
  subscribe_named_arguments: [
    transport: EthereumJSONRPC.WebSocket,
    transport_options: [
      web_socket: EthereumJSONRPC.WebSocket.WebSocketClient,
      url: System.get_env("ETHEREUM_JSONRPC_WS_URL") || "ws://localhost:46658/eth"
    ]
  ]

config :indexer, Indexer.Fetcher.ReplacedTransaction.Supervisor, disabled?: true
config :indexer, Indexer.Fetcher.BlockReward.Supervisor, disabled?: true
