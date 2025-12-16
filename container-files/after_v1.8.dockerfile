# DOCKER FILE FOR WORKSHOP-ADVANCED-DATA-VISULAIZATION
# 2025 Lokesh Mano

FROM ghcr.io/nbisweden/workshop-adv-data-viz:1.8.0
LABEL Description="Docker image for NBIS workshop"
LABEL Maintainer="lokeshwaran.manoharan@nbis.se"
LABEL org.opencontainers.image.source="https://github.com/NBISweden/workshop-data-visualization-r"
ARG QUARTO_VERSION="1.8.26"

USER root

RUN apt-get update -y \
  && apt-get clean \
  && curl -o quarto-linux-amd64.deb -L https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb \
  && apt-get install -y ./quarto-linux-amd64.deb \
  && rm -rf ./quarto-linux-amd64.deb

# Install VS Code
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y gnupg \
    && wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg \
    && install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg \
    && rm packages.microsoft.gpg \
    && wget https://go.microsoft.com/fwlink/?LinkID=760868 -O vscode.deb \
    && apt install -y ./vscode.deb \
    && rm vscode.deb

RUN apt update && apt upgrade -y 
RUN apt-get install -y python3 python3-pip python3-venv \
      && apt-get clean
RUN pip install --break-system-packages polars seaborn plotly altair

USER rstudio

WORKDIR /qmd
#ENV XDG_CACHE_HOME=/tmp/quarto_cache_home
#ENV XDG_DATA_HOME=/tmp/quarto_data_home
CMD ["quarto", "render"]

