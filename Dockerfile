# See README first!
FROM ubuntu
WORKDIR /
RUN apt-get -qq update && apt-get -qq install -y --no-install-recommends ca-certificates curl
COPY ./HealthCheckin /
RUN chmod +x HealthCheckin
# Uncomment the following line to simple copy your config file to the container,
# which would be useful if you don't want to mount it to the container.
#COPY ./config.yaml /config.yaml
CMD ["/HealthCheckin"]
