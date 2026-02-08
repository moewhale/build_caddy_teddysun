package main

import (
    caddycmd "github.com/caddyserver/caddy/v2/cmd"
    // plug in Caddy modules here
    _ "github.com/caddyserver/caddy/v2/modules/standard"
    _ "github.com/caddyserver/forwardproxy"
    _ "github.com/caddyserver/nginx-adapter"
    _ "github.com/caddyserver/transform-encoder"
    _ "github.com/caddyserver/replace-response"
    _ "github.com/mholt/caddy-webdav"
    _ "github.com/caddy-dns/cloudflare"
)

func main() {
    caddycmd.Main()
}

