# FAQs

## Config multi sites (direction roots) in nginx

- http://unix.stackexchange.com/a/134466
- http://stackoverflow.com/a/1099252/288089

## How to implement nested if statements

- http://rosslawley.co.uk/archive/old/2010/01/04/nginx-how-to-multiple-if-statements/

See also: http://wiki.nginx.org/IfIsEvil

## How nginx handle a request

http://nginx.org/en/docs/http/request_processing.html

## How to set up multiple ssl certs on one ip:port pair

See
https://www.digitalocean.com/community/tutorials/how-to-set-up-multiple-ssl-certificates-on-one-ip-with-nginx-on-ubuntu-12-04.

Check nginx SNI support

```
# /opt/nginx/sbin/nginx  -V |& grep SNI
TLS SNI support enabled:w
```

## Does nginx support transparent https proxy?

No, see https://www.zhihu.com/question/19871146.

## How nginx "location if" works

https://agentzh.blogspot.com/2011/03/how-nginx-location-if-works.html
https://www.nginx.com/resources/wiki/start/topics/depth/ifisevil/
