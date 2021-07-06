ndef = $(if $(value $(1)),,$(error $(1) not set))

protoc-gen-elixir:
	mix escript.build .

clean:
	rm -f protoc-gen-elixir

# PROTO_LIB should be your local path to https://github.com/google/protobuf/tree/master/src/google/protobuf
gen-google-protos: protoc-gen-elixir
	$(call ndef,PROTO_LIB)
	protoc -I $(PROTO_LIB) --elixir_out=lib/google --plugin=./protoc-gen-elixir descriptor.proto
	protoc -I $(PROTO_LIB) --elixir_out=lib/google --plugin=./protoc-gen-elixir compiler/plugin.proto

benchmark_protos = \
	benchmarks.proto \
	datasets/google_message1/proto3/benchmark_message1_proto3.proto \
	datasets/google_message1/proto2/benchmark_message1_proto2.proto \
	datasets/google_message2/benchmark_message2.proto \
	datasets/google_message3/benchmark_message3.proto \
	datasets/google_message3/benchmark_message3_1.proto \
	datasets/google_message3/benchmark_message3_2.proto \
	datasets/google_message3/benchmark_message3_3.proto \
	datasets/google_message3/benchmark_message3_4.proto \
	datasets/google_message3/benchmark_message3_5.proto \
	datasets/google_message3/benchmark_message3_6.proto \
	datasets/google_message3/benchmark_message3_7.proto \
	datasets/google_message3/benchmark_message3_8.proto \
	datasets/google_message4/benchmark_message4.proto \
	datasets/google_message4/benchmark_message4_1.proto \
	datasets/google_message4/benchmark_message4_2.proto \
	datasets/google_message4/benchmark_message4_3.proto

gen-bench-protos: protoc-gen-elixir
	$(call ndef,PROTO_BENCH)
	protoc -I $(PROTO_BENCH) --elixir_out=bench/lib --plugin=./protoc-gen-elixir $(benchmark_protos)

gen-protos: protoc-gen-elixir
	protoc -I src -I test/protobuf/protoc/proto --elixir_out=test/protobuf/protoc/proto_gen --plugin=./protoc-gen-elixir test/protobuf/protoc/proto/extension.proto
	protoc -I src -I test/protobuf/protoc/proto --elixir_out=test/protobuf/protoc/proto_gen --elixir_opt=package_prefix=my --plugin=./protoc-gen-elixir test/protobuf/protoc/proto/test.proto
	protoc -I src --elixir_out=lib --plugin=./protoc-gen-elixir elixirpb.proto

.PHONY: clean gen_google_proto gen_test_protos
