FROM ocet/docker-sgx:latest

WORKDIR /app

COPY . ./

RUN ./bootstrap && \
    ./configure && \
    make

CMD ["./run-server"]