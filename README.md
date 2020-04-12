# traefik-sandbox
![Deploy to Farsity](https://github.com/BenMatheja/traefik-sandbox/workflows/Deploy%20to%20Farsity/badge.svg?branch=master)

How to put self-hosted services in container and connect them with a smart edge router handling https certificates.
All the steps were done using the awesome [traefik documentation](https://docs.traefik.io/)

`` docker-compose.yml `` features

* Using traefik as edge router handling Letsencrypt certificate delivery
* Domain (http://farsity.de) with multiple subdomains (api, kibana, cloud) running sample services (whoami, kibana, owncloud)
* Redirect HTTP to HTTPS traffic
* https://api.farsity.de is secured via Forward Authentication with Google oAuth
* Add UDP router for supporting teamspeak3 traffic at (farsity.de)
* Filebeat and Metricbeat to monitor proceedings

## Secure a Service with Forward Authentication
To setup Forward Authentication via external idP i'm using the traefik-forward-auth container of thomseddon.
See more at [Blog post on how to secure the services](http://matheja.me/2020/04/10/secure-your-services-with-traefik-and-google-oauth.html)

````yaml
 traefikforward:
    image: thomseddon/traefik-forward-auth
    container_name: traefikforward
    environment:
      # These Variables are injected via environment file
      #- PROVIDERS_GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID}
      #- PROVIDERS_GOOGLE_CLIENT_SECRET=GOOGLE_CLIENT_SECRET
      #- SECRET=${SECRET}
      #- INSECURE_COOKIE=true # Example assumes no https, do not use in production
      #- WHITELIST=${WHITELIST}
      - DOMAIN=farsity.de
      - AUTH_HOST=auth.farsity.de
      - LOG_LEVEL=debug
    env_file: 
      - ./traefik-auth.env
    labels:
      - "traefik.enable=true"
      - "traefik.http.services.traefikforward.loadbalancer.server.port=4181"
      - "traefik.http.routers.traefikforward.entrypoints=websecure"
      - "traefik.http.routers.traefikforward.tls.certresolver=myresolver"
      - "traefik.http.routers.traefikforward.rule=Host(`auth.farsity.de`)"
````
To secure a service just apply the following labels.
I had a hard time to find out that middlewares have to be applied towards a router.
````yaml
 # This simply validates that traefik forward authentication is working
  whoamisecure:
    image: containous/whoami
    labels:
      - "traefik.enable=true"
#     Route which handles HTTPS Traffic
      - "traefik.http.routers.whoamisecure.rule=Host(`api.farsity.de`)"
      - "traefik.http.routers.whoamisecure.entrypoints=websecure"
      - "traefik.http.routers.whoamisecure.tls.certresolver=myresolver"
#     Apply Forward Auth to the Service 
      - "traefik.http.routers.whoamisecure.middlewares=whoamisecure"
      - "traefik.http.middlewares.whoamisecure.forwardauth.address=http://traefikforward:4181"
      - "traefik.http.middlewares.whoamisecure.forwardauth.authResponseHeaders=X-Forwarded-User"
      - "traefik.http.middlewares.whoamisecure.forwardauth.authResponseHeaders=X-Auth-User, X-Secret"
      - "traefik.http.middlewares.whoamisecure.forwardauth.trustForwardHeader=true"
````

## Helpers
Never trust Chrome because of caching
```
curl --insecure -v https://api.suchtundordnung.de 2>&1 | awk 'BEGIN { cert=0 } /^\* SSL connection/ { cert=1 } /^\*/ { if (cert) print }'
```

