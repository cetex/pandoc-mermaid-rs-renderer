# Pandoc with mmdr (Rust-based Mermaid renderer)
# No Chromium, no Node.js - much faster than mermaid-cli

# Build stage: compile mmdr (requires Rust 1.87+)
FROM rust:1.93-alpine AS build

RUN apk add --no-cache musl-dev
RUN cargo install mermaid-rs-renderer@0.1.2 --root /usr/local


# Final stage: pandoc with mmdr binary
FROM pandoc/extra:3.8.0 AS pandoc-mmdr

# Copy mmdr binary from build stage
COPY --from=build /usr/local/bin/mmdr /usr/local/bin/mmdr

# Install LaTeX svg package for native SVG support in xelatex
RUN mmdr --version && tlmgr update --self && tlmgr install svg

# Add TeX Live fonts to fontconfig so mmdr can find them
RUN mkdir -p /etc/fonts/conf.d && cat > /etc/fonts/conf.d/99-texlive-fonts.conf <<'FONTCONF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <dir>/opt/texlive/texdir/texmf-dist/fonts/opentype</dir>
  <dir>/opt/texlive/texdir/texmf-dist/fonts/truetype</dir>
</fontconfig>
FONTCONF
RUN fc-cache -fv

# Default mmdr config with fonts available in the container
RUN mkdir -p /usr/share/mmdr && cat > /usr/share/mmdr/config.json <<'MMDRCONF'
{
  "themeVariables": {
    "primaryColor": "#F8FAFF",
    "primaryTextColor": "#1C2430",
    "primaryBorderColor": "#C7D2E5",
    "lineColor": "#7A8AA6",
    "secondaryColor": "#F0F4FF",
    "tertiaryColor": "#E8EEFF",
    "edgeLabelBackground": "#FFFFFF",
    "clusterBkg": "#F8FAFF",
    "clusterBorder": "#C7D2E5",
    "background": "#FFFFFF",
    "fontFamily": "Source Sans Pro, SourceSansPro, DejaVu Sans, sans-serif",
    "fontSize": 13
  },
  "flowchart": {
    "nodeSpacing": 50,
    "rankSpacing": 50
  }
}
MMDRCONF

# Install the Lua filter
COPY mermaid-mmdr.lua /usr/local/share/pandoc/filters/mermaid-mmdr.lua

# Set default mmdr config path for the filter
ENV MMDR_CONFIG=/usr/share/mmdr/config.json
