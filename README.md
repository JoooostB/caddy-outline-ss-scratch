# Caddy Outline ss-server in Scratch

[![Build Status](https://github.com/JoooostB/caddy-outline-ss-scratch/actions/workflows/docker.yml/badge.svg)](https://github.com/JoooostB/caddy-outline-ss-scratch/actions/workflows/docker.yml)
[![Mattermost](https://badgen.net/badge/Mattermost/Outline%20Community/blue)](https://community.internetfreedomfestival.org/community/channels/outline-community)
[![Reddit](https://badgen.net/badge/Reddit/r%2Foutlinevpn/orange)](https://www.reddit.com/r/outlinevpn/)

This project is designed to be a minimal, secure, and efficient implementation of an Outline server using Caddy. Caddy's automatic HTTPS capabilities and flexible configuration make it an excellent choice for serving your Outline server, especially when using a WebSocket transport.

## What is Caddy?

Caddy is an open-source web server known for its ease of use, automatic HTTPS, and support for various protocols. It simplifies web server configuration and offers features like:

* Automatic HTTPS: Caddy automatically obtains and renews TLS certificates, ensuring secure connections.
* HTTP/3 Support: Caddy supports the latest HTTP/3 protocol for faster and more efficient web traffic.
* Extensible with Plugins: Caddy can be extended with plugins to support various functionalities, including reverse proxying and load balancing.

## What is Outline?

Outline is a secure and easy-to-use VPN solution designed to help users bypass censorship and access the internet freely. The Outline system involves two main roles: service providers, who manage the servers, and end users, who access the internet through those servers. This project allows you to run the Outline server using Caddy as the web server, providing a secure and efficient way to serve Outline clients.

## Setup Instructions

This repository is based on the official "Automatic HTTPS with Caddy" instructions from the [Outline documentation](https://developers.google.com/outline/docs/guides/service-providers/caddy). It provides a minimal setup for running an Outline server as a Docker container with Caddy as the web server.

### Prerequisites

1. Container runtime / container orchestrator (Docker, Podman, Kubernetes, etc.)
1. Domain name pointing to your server's IP address

    * Verify DNS records: Verify your DNS records are set correctly with an authoritative lookup:  
    `curl "https://cloudflare-dns.com/dns-query?name=outline.example.com&type=A" -H "accept: application/dns-json"`
    > Replace `outline.example.com` with your actual domain name.

### Configuration

1. Copy the config.yaml.example file to config.yaml and edit it to your needs.
    * Replace the `outline.example.com` with your actual domain name.
    * Generate a new secret and replace the `secret` value in the config file.
    * _Optional: Change the `/ws` and `/api` to something else._
2. Start your container with a mount to the `config.yaml` file:

    ```bash
    docker run -d \
      --name outline-ss-server \
      -v /path/to/config.yaml:/opt/xcaddy/config.yaml \
      -p 80:80 \
      -p 443:443 \
      joooostb/caddy-outline-ss-scratch:latest
    ```

3. Verify the server is running by checking the logs:

    ```bash
    docker logs -f outline-ss-server
    ```

4. Host your Outline client configuration somewhere publicly accessible, you can include it in your Caddy deployment or cloud storage service like GitHub Gist (store as private, copy the RAW URL). The Outline client will need to access this configuration file to connect to your Outline server. The configuration file should be in the following YAML format:

```yaml
transport:
  $type: tcpudp
  tcp:
    $type: shadowsocks
    endpoint:
      $type: websocket
      url: wss://outline.example.com/stream
    cipher: chacha20-ietf-poly1305
    secret: pLaCEHolderSEcret1337
  udp:
    $type: shadowsocks
    endpoint:
      $type: websocket
      url: wss://outline.example.com/api
    cipher: chacha20-ietf-poly1305
    secret: pLaCEHolderSEcret1337
```

\* _Replace `outline.example.com` with your actual domain name and `pLaCEHolderSEcret1337` with the secret you set in the `config.yaml` file._

5. Enter the URL of your dynamic Outline client configuration file into the Outline client application. The client will use this configuration to connect to your Outline server, i.e.:
`https://gist.githubusercontent.com/JoooostB/rEsk6NMYdjsbHQTi5wZ9A5c7kS4k6hPZ/raw/rEsk6NMYdjsbHQTi5wZ9A5c7kS4k6hPZ/outline-example-com.yaml`

> As we're using Websocket transport, we're unable to statically generate the client configuration file. Instead, we provide a dynamic configuration file that the Outline client can use to connect to the server.

### Troubleshooting

#### Log times

If log times are not correct, it's because you need to set your timezone in the TZ environment variable. For example, add -e TZ=America/Montreal to your Docker run command.
