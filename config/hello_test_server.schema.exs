[
  mappings: [
    "hello_test_server.listen": [
      doc: """
      Hello_Test_Server API endpoint in form of <protocol>://<host>[:<port>]

      Supported protocols are: zmq-tcp, zmq-tcp6, zmq-ipc, http

      It is possible to specify port as 0 or * to using only mdns registration
      """,
      to: "hello_test_server.listen",
      datatype: :charlist,
      default: 'zmq-tcp://127.0.0.1:26000'
    ],
    "hello_test_server.respond_path": [
      doc: """
      Folder with the responses in the format <path>/request/response1.json
      """,
      to: "hello_test_server.respond_path",
      datatype: :binary,
      default: "responses"
    ]
  ],
  translations: [
    "hello_test_server.listen": fn
    _, uri ->
      try do
        uri = to_char_list(uri)
        :ex_uri.decode(uri)
        uri
      catch
        _, _ ->
          IO.puts("Unsupported URI format: #{uri}")
        exit(1)
      end
  end,
  ]
]
