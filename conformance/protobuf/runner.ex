defmodule Conformance.Protobuf.Runner do
  @moduledoc false

  def main(_args) do
    Logger.configure_backend(:console, device: :standard_error)
    :io.setopts(:standard_io, encoding: :latin1)
    loop()
  end

  defp loop() do
    case IO.binread(:stdio, 4) do
      :eof ->
        :ok

      {:error, reason} ->
        raise reason

      <<len::unsigned-little-32>> ->
        IO.binread(:stdio, len)
        |> decode(Conformance.ConformanceRequest)
        |> handle_request()
        |> cast_response()
        |> encode(Conformance.ConformanceResponse)
        |> reply()

        loop()
    end
  end

  defp handle_request(
         {:ok,
          %Conformance.ConformanceRequest{
            requested_output_format: :PROTOBUF,
            message_type: message_type,
            payload: {:protobuf_payload, msg}
          }}
       ) do
    test_proto_type = to_test_proto_type(message_type)

    case decode(msg, test_proto_type) do
      {:error, err} ->
        {:parse_error, Exception.format_banner(:error, err)}

      {:ok, decoded_msg} ->
        case encode(decoded_msg, test_proto_type) do
          {:error, err} ->
            {:serialize_error, Exception.format_banner(:error, err)}

          {:ok, encoded_msg} ->
            {:protobuf_payload, encoded_msg}
        end
    end
  end

  defp handle_request({:ok, _}), do: {:skipped, "unsupported conformance test"}
  defp handle_request({:error, err}), do: {:runtime_error, Exception.format_banner(:error, err)}

  defp cast_response(result), do: Conformance.ConformanceResponse.new(result: result)

  defp reply({:ok, data}),
    do: IO.binwrite(:stdio, <<byte_size(data)::unsigned-little-32, data::binary>>)

  defp reply({:error, reason}), do: raise(reason)

  defp to_test_proto_type(name) do
    case name do
      "protobuf_test_messages.proto3.TestAllTypesProto3" ->
        ProtobufTestMessages.Proto3.TestAllTypesProto3

      "protobuf_test_messages.proto2.TestAllTypesProto2" ->
        ProtobufTestMessages.Proto2.TestAllTypesProto2

      "conformance.FailureSet" ->
        Conformance.FailureSet

      "" ->
        ProtobufTestMessages.Proto3.TestAllTypesProto3
    end
  end

  defp decode(msg, proto_type), do: apply_codec(msg, &proto_type.decode/1)
  defp encode(msg, proto_type), do: apply_codec(msg, &proto_type.encode/1)

  defp apply_codec(msg, codec) do
    try do
      {:ok, codec.(msg)}
    rescue
      e in _ -> {:error, e}
    end
  end
end
