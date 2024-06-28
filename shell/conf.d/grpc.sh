PROTOBUF_REPO_PATH="${HOME}/projects/backend/packages/ts-protobufs"

grpc() {
  if [ "$#" -lt 4 ]; then
    echo "Usage: ${0} <host> <proto_file> <method> <data>"
    return 1
  fi
  grpcurl -d ${4} \
    -plaintext \
    -proto "${PROTOBUF_REPO_PATH}/${2}" \
    -import-path "${PROTOBUF_REPO_PATH}/src" \
    "${1}" \
    "${3}"
}

grpc-email-service() {
  if [ "$#" -lt 3 ]; then
    echo "Usage: ${0} <env> <method> <data>"
    return 1
  fi
  if [ $1 = "local" ]; then
    grpc "127.0.0.1:50051" \
      "src/ldt/email_service/v1/email_service.proto" \
      "ldt.email_service.v1.EmailService/${2}" \
      "${@:3}"
  else
    grpc "emailservice.${1}.letsdothis:50051" \
      "src/ldt/email_service/v1/email_service.proto" \
      "ldt.email_service.v1.EmailService/${2}" \
      "${@:3}"
  fi
}

grpc-event-service() {
  if [ "$#" -lt 3 ]; then
    echo "Usage: ${0} <env> <method> <data>"
    return 1
  fi
  if [ $1 = "local" ]; then
    grpc "127.0.0.1:50051" \
      "src/ldt/event_service/v1/event_service.proto" \
      "ldt.event_service.v1.EventService/${2}" \
      "${@:3}"
  else
    grpc "eventservice.${1}.letsdothis:50051" \
      "src/ldt/event_service/v1/event_service.proto" \
      "ldt.event_service.v1.EventService/${2}" \
      "${@:3}"
  fi
}

