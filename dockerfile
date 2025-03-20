# DOCKER FILE FOR WORKSHOP-ADVANCED-DATA-VISULAIZATION
# 2025 Lokesh Mano

FROM rocker/verse:4.4
LABEL Description="Docker image for NBIS workshop"
LABEL Maintainer="lokeshwaran.manoharan@nbis.se"
LABEL org.opencontainers.image.source="https://github.com/NBISweden/workshop-data-visualization-r"
ARG QUARTO_VERSION="1.6.42"

RUN apt-get update -y \
  && apt-get clean \
  && apt-get install --no-install-recommends -y \
  libxml2-dev \
  libssl-dev \
  libcurl4-openssl-dev \
  libudunits2-dev \
  libgdal-dev \
  libavfilter-dev \
  libprotobuf-dev \
  libjq-dev \
  libarchive-dev \
  cargo \
  curl \
  #&& wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
  #&& apt-get install -y ./google-chrome-stable_current_amd64.deb \
  #&& rm -rf ./google-chrome-stable_current_amd64.deb \
  && curl -o quarto-linux-amd64.deb -L https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb \
  #&& apt-get install -y ./quarto-linux-amd64.deb \
  #&& rm -rf ./quarto-linux-amd64.deb \
  && rm -rf /var/lib/apt/lists/* \
  && install2.r --error --skipinstalled remotes fontawesome here htmlTable leaflet readxl writexl \
  && rm -rf /tmp/downloaded_packages \
  && mkdir /qmd /.cache \
  && chmod 777 /qmd /.cache

USER rstudio

RUN Rscript -e 'install.packages(c("ggplot2", "ggmap","pheatmap","devtools","cowplot","reshape2", "dplyr", "wesanderson", "scales", "ggthemes", "ggrepel", "grid","ggpubr", "gridExtra", "shiny", "gganimate", "shinythemes","rsconnect", "colourpicker", "kableExtra", "highcharter", "plotly", "ggiraph", "dygraphs", "networkD3", "leaflet", "crosstalk", "fontawesome", "knitr"),dependencies = TRUE, repos = "http://cran.us.r-project.org");'

RUN Rscript -e 'install.packages(c("shinylive", "Seurat"), dependencies = TRUE, repos = "http://cran.us.r-project.org");'

WORKDIR /qmd
#ENV XDG_CACHE_HOME=/tmp/quarto_cache_home
#ENV XDG_DATA_HOME=/tmp/quarto_data_home
CMD ["quarto", "render"]

