# cf-mini
Docker image running Cloud Foundry Stack - listens on ports 80/443/4443

[![](https://badge.imagelayers.io/tchughesiv/cf-mini.svg)](https://imagelayers.io/?images=tchughesiv/cf-mini:latest 'Get your own badge on imagelayers.io')

    Ubuntu Precise 12.04.05
    Cloud Foundry v205

docker run -t --privileged -p 80:80 -p 443:443 -p 4443:4443 -di tchughesiv/cf-mini
