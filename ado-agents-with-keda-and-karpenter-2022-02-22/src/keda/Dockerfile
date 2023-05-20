FROM ubuntu:18.04

# To make it easier for build and release pipelines to run apt-get,
# configure apt to not require confirmation (assume the -y argument by default)
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    jq \
    git \
    iputils-ping \
    libcurl4 \
    libicu60 \
    libunwind8 \
    netcat \
    libssl1.0 \
  && rm -rf /var/lib/apt/lists/*

RUN curl -LsS https://aka.ms/InstallAzureCLIDeb | bash \
  && rm -rf /var/lib/apt/lists/*

# Can be 'linux-x64', 'linux-arm64', 'linux-arm', 'rhel.6-x64'.
ENV TARGETARCH=linux-x64
ENV AZP_AGENT_PACKAGE_LATEST_URL="https://vstsagentpackage.azureedge.net/agent/2.198.3/vsts-agent-linux-x64-2.198.3.tar.gz"

WORKDIR /azp

COPY ./start.sh .

RUN curl -LsS $AZP_AGENT_PACKAGE_LATEST_URL | tar -xz & wait $!
    
RUN chmod +x start.sh

ENTRYPOINT ["./start.sh"]