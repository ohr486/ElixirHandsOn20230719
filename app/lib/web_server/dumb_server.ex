defmodule WebServer.DumbServer do
  use GenServer

  require Logger

  def start_link(port) do
    GenServer.start_link(__MODULE__, port, name: __MODULE__)
  end

  def init(port) do
    Logger.info "Start dumb server with supervisor on #{port} port ..."
    {:ok, listen_sock} = :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    WebServer.Dumb.loop_acceptor(listen_sock)
    {:ok, port}
  end
end
