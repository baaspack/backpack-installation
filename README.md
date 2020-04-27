# How to deploy backpack

1. Acquire a VPS like a Droplet on Digital Ocean.

2. Configure the following DNS A record for the VPS's public IP address: *.yourdomain.

3. Install Docker on the VPS.
  - `curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh`

4. Initialize Swarm mode on the VPS by running `docker swarm init`.
  - You may need to run this command with the `--advertise-addr` option if the VPS has multiple IP addresses. Choose the public one. The full command will look like `docker swarm init --advertise-addr pub.lic.ip.add`

5. Download backpack's installation scripts by running `git clone https://github.com/baaspack/backpack-installation.git`.

6. From within the `backpack-installation` folder, update the `.env` file:
  - Fill in the domain name you used in Step 2 into the DOMAIN variable.
  - Fill in the email address you used to register your domain name in the SSL_EMAIL variable.

7. From within the `backpack-installation` folder, run the following command. This will read the env variables from the `.env` & use them to configure your stack:
  - `set -a && . .env && set +a && docker stack deploy -c docker-admin-stack.yml admin`
  - The first time you run this, it will take a minute or two for all the containers to spin up since Docker needs to download their images first. If you'd like to watch their progress, run `watch docker service ls` until you see the `REPLICAS` column show `1/1`.

8. After a few minutes, see if you can hit https://admin.yourdomain.tld from your browser.

Optional, but recommended:
  - add more nodes to your swarm.
  - secure your nodes' firewalls by following [these instructions](https://www.digitalocean.com/community/tutorials/how-to-configure-the-linux-firewall-for-docker-swarm-on-ubuntu-16-04). Don't forget to allow traffic through ports 443 & 80 for HTTP/S.
