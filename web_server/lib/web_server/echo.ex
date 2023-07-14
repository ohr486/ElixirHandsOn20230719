defmodule WebServer.Echo do
  require Logger

  def start(port \\ 8000) do
    {:ok, listen_sock} = :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info "Start Echo Server 1 on #{port} port ..."
    loop_acceptor(listen_sock)
  end

  def loop_acceptor(listen_sock) do
    {:ok, accept_sock} = :gen_tcp.accept(listen_sock)
    handle_server(accept_sock)
    loop_acceptor(listen_sock)
  end

  def handle_server(accept_sock) do
    case read_line(accept_sock) do
      :closed -> :gen_tcp.close(accept_sock)
      "quit\r\n" ->
        Logger.info "quit server ..."
        :timer.sleep(1000)
        System.halt
      msg ->
        write_line(msg, accept_sock)
        handle_server(accept_sock)
    end
  end

  def read_line(accept_sock) do
    case :gen_tcp.recv(accept_sock, 0) do
      {:ok, msg} ->
        Logger.info "read_line: #{msg}"
        msg
      {:error, :clsoed} ->
        Logger.info "read_line: closed"
        :closed
    end
  end

  def write_line(msg, accept_sock) do
    Logger.info "write_line: #{msg}"
    :gen_tcp.send(accept_sock, msg)
  end
end
