# traefik-sandbox
How to put self-hosted services in container and connect them with a smart edge router handling https certificates.
All the steps were done using the awesome [traefik documentation](https://docs.traefik.io/)

`` docker-compose.yml `` features

* Using traefik as edge router handling Letsencrypt certificate delivery
* Domain (suchtundordnung.de) with multiple subdomains (api and blog) running sample services(whoami)
* An UDP router for supporting teamspeak3 traffic
* Exposed traefik api and dashboard - Obviously not for productive use!

## Helpers
Never trust Chrome because of caching
```
curl --insecure -v https://api.suchtundordnung.de 2>&1 | awk 'BEGIN { cert=0 } /^\* SSL connection/ { cert=1 } /^\*/ { if (cert) print }'
```

