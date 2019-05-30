# BlockScout Docker integration

For now this integration is not production ready. It made only for local usage only !

## How to use ?
First of all, blockscout requires `PostgreSQL` server for working. 
It will be provided by starting script (new docker image will be created named `postgres`)

**Starting command**
`make start` - will set everything up and start blockscout in container.
To connect it to your local environment you will have to configure it using [env variables](#env-variables)

Example connecting to local `ganache` instance running on port `2000` on Mac/Windows:
```bash
COIN=LOOM \
ETHEREUM_JSONRPC_VARIANT=loom \
ETHEREUM_JSONRPC_HTTP_URL=http://host.docker.internal:2000 \
ETHEREUM_JSONRPC_WS_URL=ws://host.docker.internal:2000 \
make start
```

Blockscout will be available on `localhost:4000`

**Note**
On mac/Windows Docker provides with a special URL `host.docker.internal` that will be available into container and routed to your local machine.
On Linux docker is starting using `--network=host` and all services should be available on `localhost`

### Migrations

By default, `Makefile` will do migrations for you on `PostgreSQL` creation. 
But you could run migrations manually using `make migrate` command.

**WARNING** Migrations will clean up your local database !

## Env variables

BlockScout supports 3 different JSON RPC Variants.
Variant could be configured using `ETHEREUM_JSONRPC_VARIANT` environment variable.

Example: 
```bash
ETHEREUM_JSONRPC_VARIANT=loom make start
```

Available options are:

 * `loom` - Loom JSON RPC (**Default one**)

| Variable | Description | Default value |
| -------- | ----------- | ------------- |
| `ETHEREUM_JSONRPC_VARIANT` | Variant of your JSON RPC | `loom` |
| `ETHEREUM_JSONRPC_HTTP_URL` | HTTP JSON RPC URL | `http://localhost:46658` |
| `ETHEREUM_JSONRPC_WS_URL` | WS JSON RPC url | `ws://localhost:46658` |
| `COIN` | Default Coin | `LOOM` |
| `LOGO` | Coin logo | Empty |
| `NETWORK` | Network | Empty |
| `SUBNETWORK` | Subnetwork | Empty |
| `NETWORK_ICON` | Network icon | Empty |
| `NETWORK_PATH` | Network path | `/` |
