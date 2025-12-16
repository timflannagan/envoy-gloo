# This file was inspired by a combination of the following:
# Istio and platform's mesh derivative approach
# Uses upstream envoy's ubuntu versioning
# Consumed by edge to build gateway-proxy and gloo pods
# May be used as is or as a builder intermediate (e.g. for distroless)
# ON_MINOR_UPDATE: Pull from https://github.com/envoyproxy/envoy/blob/4d46da0bba54dfb849d8bf68b600e53d87310a1a/ci/Dockerfile-envoy#L1-L2
FROM ubuntu:noble

# TARGETARCH is automatically set by docker buildx for multi-arch builds
# Values: amd64, arm64
ARG TARGETARCH

ENV loglevel=info

ENV DEBIAN_FRONTEND=noninteractive

# hadolint ignore=DL3005,DL3008
RUN apt-get update && \
  apt-get install --no-install-recommends -y \
  ca-certificates \
  && apt-get upgrade -y \
  && apt-get clean \
  && rm -rf  /var/log/*log /var/lib/apt/lists/* /var/log/apt/* /var/lib/dpkg/*-old /var/cache/debconf/*-old

RUN mkdir -p /etc/envoy

# For multi-arch builds, use architecture-specific binary (envoy-amd64.stripped or envoy-arm64.stripped)
# For single-arch builds (backward compatibility), fall back to envoy.stripped
COPY envoy-${TARGETARCH}.stripped* envoy.stripped* /tmp/
RUN if [ -f /tmp/envoy-${TARGETARCH}.stripped ]; then \
      mv /tmp/envoy-${TARGETARCH}.stripped /usr/local/bin/envoy; \
    else \
      mv /tmp/envoy.stripped /usr/local/bin/envoy; \
    fi && \
    rm -f /tmp/envoy*.stripped && \
    chmod +x /usr/local/bin/envoy

ENTRYPOINT ["/usr/local/bin/envoy"]
CMD ["-c", "/etc/envoy/envoy.yaml"]
