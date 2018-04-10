FROM ubuntu:16.04

RUN apt-get update
RUN apt-get install -y redis-server gawk bash
RUN rm -rf /var/cache/apt/archives/*

COPY run.sh /run.sh
RUN chmod u+x /run.sh
CMD [ "/run.sh" ]

ENTRYPOINT [ "bash", "-c" ]
