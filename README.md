# cybroscgiserver.docker
This is a docker container for running the cybrotech scgi server in a docker container

![workflow](https://github.com/killer0071234/cybroscgiserver.docker/actions/workflows/docker-image.yml/badge.svg)


The CyBroScgiServer is used for communicating with PLCs from Cybrotech Ltd.
Supported PLCs:
- CyBro-2
- CyBro-3

## Contains

- latest Python 3.8 required for CyBroScgiServer
- CyBroScgiServer v3.1.3 from http://www.cybrotech.com/ (directly loaded from cybrotech.com)
- example configuration file(s)

## Requirements

- Docker

## Install and run

```
docker pull killer007/cybroscgiserver
docker run killer007/cybroscgiserver:latest -p 4000:4000/tcp -p 4080:80/tcp -p 8442:8442/udp
```

## Usage

For detailed usage / valid system tags check the readme of CyBroScgiServer-v3.1.3.zip under
https://cybrotech.com/software/

- web requests to SCGI socket with xml-answer (but without any http-header): http://[ip]:4000/?
  Example: http://[ip]:4000/?sys.server_uptime -> returns the ScgiServer Uptime (including a tag description) formatted as xml
- web requests to nginx web server with xml-answer: http://[ip]/?
  Example: http://[ip]/?sys.server_uptime -> returns the ScgiServer Uptime (including a tag description) formatted as xml
- Abus Push Messages (UDP) from the PLC shall go to: [ip]:8442

The configuration file for the scgi server can be found under:
./config/config.ini

For a own configuration mount the config.ini file to:
/usr/local/bin/scgi_server/config.ini
In docker-compose: 
```
volumes:
  - "./config/config.ini:/usr/local/bin/scgi_server/config.ini"
```
On commandline add:
```
-v "./config/config.ini:/usr/local/bin/scgi_server/config.ini"
```

The configuration file for the data logger can be found under:
./config/data_logger.xml
In docker-compose: 
```
volumes:
  - "./config/data_logger.xml:/usr/local/bin/scgi_server/data_logger.xml"
```
On commandline add:
```
-v "./config/data_logger.xml:/usr/local/bin/scgi_server/data_logger.xml"
```

