defmodule Explorer.SmartContract.SolcDownloader do
  @moduledoc """
  Checks to see if the requested solc compiler version exists, and if not it
  downloads and stores the file.
  """
  use GenServer

  alias Explorer.SmartContract.Solidity.CompilerVersion

  @latest_compiler_refetch_time :timer.minutes(30)

  def ensure_exists(version) do
    path = file_path(version)

    if File.exists?(path) do
      path
    else
      {:ok, compiler_versions} = CompilerVersion.fetch_versions()

      if version in compiler_versions do
        GenServer.call(__MODULE__, {:ensure_exists, version}, 60_000)
      else
        false
      end
    end
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  # sobelow_skip ["Traversal"]
  @impl true
  def init([]) do
    File.mkdir(compiler_dir())

    {:ok, []}
  end

  # sobelow_skip ["Traversal"]
  @impl true
  def handle_call({:ensure_exists, version}, _from, state) do
    path = file_path(version)

    if fetch?(version, path) do
      temp_path = file_path("#{version}-tmp")

      contents = download(version)

      file = File.open!(temp_path, [:write, :exclusive])

      IO.binwrite(file, contents)

      File.rename(temp_path, path)
    end

    {:reply, path, state}
  end

  defp fetch?("latest", path) do
    case File.stat(path) do
      {:error, :enoent} ->
        true

      {:ok, %{mtime: mtime}} ->
        last_modified = NaiveDateTime.from_erl!(mtime)
        diff = Timex.diff(NaiveDateTime.utc_now(), last_modified, :milliseconds)

        diff > @latest_compiler_refetch_time
    end
  end

  defp fetch?(_, path) do
    not File.exists?(path)
  end

  defp file_path(version) do
    Path.join(compiler_dir(), "#{version}.js")
  end

  defp compiler_dir do
    Application.app_dir(:explorer, "priv/solc_compilers/")
  end

  defp download(version) do
    download_path = "https://ethereum.github.io/solc-bin/bin/soljson-#{version}.js"

    download_path
    |> HTTPoison.get!([], timeout: 60_000)
    |> Map.get(:body)
  end
end
