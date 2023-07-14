defmodule WebServer.HelloServer do
  use GenServer

  require Logger

  def start_link(port) do
    #GenServer.start_link(__MODULE__, port, name: __MODULE__)
    GenServer.start_link(__MODULE__, port, name: :hel_serv)
  end

  def init(port) do
    Logger.info "Start hello server with supervisor on #{port} port ..."
    {:ok, listen_sock} = :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    loop_acceptor(listen_sock)
    {:ok, port}
  end

  def loop_acceptor(listen_sock) do
    {:ok, accept_sock} = :gen_tcp.accept(listen_sock)
    handle_server(accept_sock)
    loop_acceptor(listen_sock)
  end

  def handle_server(accept_sock) do
    case read_req(accept_sock) do
      :closed -> :gen_tcp.close(accept_sock)
      _msg ->
        #Logger.info "handle_server: #{msg}"
        send_resp(accept_sock)
        handle_server(accept_sock)
    end
  end

  def read_req(accept_sock) do
    case :gen_tcp.recv(accept_sock, 0) do
      {:ok, msg} ->
        #Logger.info "read_req: #{msg}"
        msg
      {:error, :closed} ->
        #Logger.info "read_req: closed"
        :closed
    end
  end

  def send_resp(accept_sock) do
    msg = "Hello, Elixir!"
    resp_msg = """
    HTTP/1.1 200 OK
    Content-Length: #{String.length(msg)}

    #{msg}
    """
    :gen_tcp.send(accept_sock, resp_msg)
    :gen_tcp.close(accept_sock)
  end
end
