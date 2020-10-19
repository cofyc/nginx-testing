# KeepAlive

See http://nginx.org/en/docs/http/ngx_http_upstream_module.html#keepalive.

## Usage

1. let upstream donot close connection
2. use `keepalive` to keep idle connections

### without websocket

```
upstream {
    keepalive <num>;
}
location / {
    proxy_http_version 1.1;
    proxy_set_header Connection "";
}
```

### with websocket

```
upstream {
    keepalive <num>;
}
proxy_http_version 1.1;
proxy_set_header Connection $http_connection;
proxy_set_header Upgrade $http_upgrade;
location / {
    proxy_pass http://upstream;
    # proxy_set_header directives inherited from the previous level if and only if there
    # are no proxy_set_header directives defined on the current level.
}
```

## Server 端是否保持连接

go server 默认保持连接，并没有时间限制，但可以通过

- https://golang.org/pkg/net/http/#Server.SetKeepAlivesEnabled 来关闭
- Server.ReadTimeout/WriteTimeout 来限定连接超时

nginx server 默认也保持链接，可以通过 `keepalive_*` 配置来调整行为，比如

- `keepalive_timeout` 来限定超时时间

## HTTP 的 Connection: close 头

HTTP/1.1 协议里约定：

- server 端假设 client 发起的是持久连接，除非头部包含 Connection: close 头。
- client 端期待连接保持开启，根据 server 段是否有 Connection: close 头。

如果双方收到 Connection: close，行为都是当当前 request/response
结束后关闭链接。

golang/nginx server 都符合这两个行为。

nginx 的 upstream proxy, 为了保持持久连接有专门的配置项：
http://nginx.org/en/docs/http/ngx_http_upstream_module.html#keepalive

## HTTP/1.0 vs HTTP/1.1

### HTTP/1.0

By default, donot keepalive. Add `Connection: keep-alive` to enable it.

### HTTP/1.1

By default, keepalive is on. Add `Connection: close` to disable it.

## Nginx 

nginx 的 upstream proxy 代理的默认行为不会保持连接。

client 每个 request 过来都会新建与 backend (server) 的连接，client 收到 request
的 response 断开连接后，中间的连接会被关闭。（如果 client 复用 client 与 proxy
的链接，继续发送 request/response，proxy -> backend (server) 的连接不会关闭，会复用）

nginx 的 upstream/keepalive 配置，是无论 client 复不复用连接，nginx
都保持可配置上线的与 upstream 的连接。
