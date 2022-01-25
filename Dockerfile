FROM python:3.8-buster

LABEL org.opencontainers.image.authors="Daniel Gangl <killer007@gmx.at>"
LABEL SCGI_SERVER_VERSION="3.1.3"

WORKDIR /tmp/

RUN apt-get update

RUN apt-get upgrade -y

RUN apt-get install -y curl

RUN wget https://www.cybrotech.com/wp-content/uploads/2022/01/CyBroScgiServer-v3.1.3.zip

RUN unzip *.zip

RUN mv */scgi_server/ /usr/local/bin/

RUN rm -r *

WORKDIR /usr/local/bin/scgi_server/

RUN pip install -r src/requirements.txt

RUN mkdir /usr/local/bin/scgi_server/log && touch /usr/local/bin/scgi_server/log/scgi.log && ln -sf /dev/stdout /usr/local/bin/scgi_server/log/scgi.log

COPY ./sh /usr/local/bin/scgi_server/

COPY ./config /usr/local/bin/scgi_server/

RUN chmod +x run.sh

CMD /usr/local/bin/scgi_server/run.sh

HEALTHCHECK --interval=5s --timeout=2s --retries=12 \
  CMD curl --silent --fail http://localhost:4000/?sys.server_uptime || exit 1

EXPOSE 4000/tcp
EXPOSE 8442/udp