defmodule WebServer.Hello do
  require Logger

  def start(port \\ 8000) do
    Logger.info "Start Hello Server on #{port} port ..."
    {:ok, listen_sock} = :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    loop_acceptor(listen_sock)
  end

  def loop_acceptor(listen_sock) do
    {:ok, accept_sock} = :gen_tcp.accept(listen_sock)
    handle_server(accept_sock)
    loop_acceptor(listen_sock)
  end

  def handle_server(accept_sock) do
    case read_req(accept_sock) do
      {:req_line, _method, _target, _prot_ver} ->
        handle_server(accept_sock)
      {:header_line, _header_field, _header_val} ->
        handle_server(accept_sock)
      :req_end ->
        send_resp(accept_sock)
    end
  end

  def read_req(accept_sock) do
    {:ok, raw_msg} = :gen_tcp.recv(accept_sock, 0)
    req_msg = String.trim(raw_msg) # 末尾の改行コードを削除
    #Logger.info "req_msg: #{req_msg}"

    case String.split(req_msg, " ") do
      # リクエストライン
      [method, target, prot_ver] ->
        #Logger.info "method: #{method}, target: #{target}, prot_ver: #{prot_ver}"
        {:req_line, method, target, prot_ver}
      # ヘッダ部
      [header_field, header_val] ->
        #Logger.info "header_field: #{header_field}, header_val: #{header_val}"
        {:header_line, header_field, header_val}
      # ヘッダ以降
      _body ->
        #Logger.info "body: #{body}"
        :req_end
    end
  end

  def send_resp(accept_sock) do
    msg = "Hello, World!"
    resp_msg = """
HTTP/1.1 200 OK
Content-Length: #{String.length(msg)}

#{msg}
"""
    :gen_tcp.send(accept_sock, resp_msg)
    :gen_tcp.close(accept_sock)
  end
end
