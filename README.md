# cf-mini
Docker image running Cloud Foundry Stack - listens on ports 80/443/4443

    Ubuntu Precise 12.04.05
    Cloud Foundry v205

docker run -p 80:80 443:443 4443:4443 -di tchughesiv/cf-mini