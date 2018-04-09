FROM frolvlad/alpine-glibc

RUN apk add --no-cache redis sed bash

COPY run.sh /run.sh
RUN chmod u+x /run.sh
CMD [ "/run.sh" ]

ENTRYPOINT [ "bash", "-c" ]
