# Mining Node Setup Guide

This guide assumes that you will run Volition on a dedicated server or VPS. Our canonical spec (as of this writing) is an [Ionos VPS XXL](https://www.ionos.com/servers/vps#packages) running Ubuntu 20.04. Feel free to experiement with other configurations, but we may not be able to help you troubleshoot if you get stuck. We find the node is primarily bottlenecked by storage speed and size. CPU and memory usage is still (relatively) light. Storage speed, in particular, can have a big impact and cause your node to mine dramatically fewer blocks.

Commands listed in blocks shown below should be run on the server hosting the volition mining node:

```
example
```

## Stack Description

Currently the docker-compose stack consists of:

- Socket-Proxy (secure docker.sock to internal requests only)
- Traefik2 (as reverse proxy)
- Dozzle (Container logs vieweable over https)
- Glances (HTop over https)
- Watchtower (automatically update docker containers)
- Volition (volition node miner)
- CloudFlare DDNS (Updates CloudFlare with your most recent public IP - only needed if your server does not have a static IP)

We use [traefik](https://traefik.io) as a reverse proxy to route requests into your volition mining node. Traefik will create subdomains per our docker containers and use LetsEncrypt to issue our SSL certificates. To validate domain owenrship, we'll use LetsEcnrypts CloudFlare DNS challenge.

## Prereqs

Before you begin, if you don't already have one, or if you want to use a different account for mining, provision a new Volition account and rename it to whatever you want to use as your miner name. Volition will eventually support renaming mining accounts, but for beta it does not, so be sure your account is named what you want it to be. Also, make sure know where to find the [genesis block](https://raw.githubusercontent.com/cryptogogue/vol-blocks/main/volition-ccg/ccg-open-beta.json) for whatever network you plan to join.

You will also need:

- A domain name.
- A Volition account with the name you want to use for your miner.
- The URL of the genesis block for whatever network you intend to join.
- Port 443 open on the server used to host the mining node.
- A static IP address OR the patience to setup Cloudflare.

If you have a static IP, follow your domain host's instructions to point the domain name at your server's IP. If you don't have a static IP, see the Cloudflare setup appendix at the end of this document.

To prepare your server:

```
sudo apt update
sudo apt install curl docker docker-compose git openssl vim
```

[Set up your git account](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account) and clone this repo:

```
git clone git@github.com:cryptogogue/vol-node-setup.git
```

If you have trouble setting up git, we can't help you. If you get stuck, you can always download the repository as a .zip and manually copy it to your server.

## Setup


From inside the vol-node-setup folder, run the make-project.sh helper script:

```
./make-project.sh
```

By default, the script will set use /mnt/data/docker as the docker directory. If you want it somewhere else:

```
./make-project.sh -d /somewhere/else
```

If not do not have a static IP and plan to use Cloudflare, pass the '-c' flag to the setup script:

```
./make-project.sh -c
```

We'll use the notation `$DOCKERDIR` to show the relative path to wherever you want to store your docker directory. You can set an environment variable DOCKERDIR to make these commands copy pasteable:

```
export DOCKERDIR=/mnt/data/docker
```

Edit the docker .env file and add your information:

```
vi $DOCKERDIR/.env
```

To get the correct value for TZ (for example, TZ="America/Vancouver"), see https://en.wikipedia.org/wiki/List_of_tz_database_time_zones. If you are using Cloudflare and need an API key, see the appendix on Cloudflare setup.

Now configure the node itself:

```
vi $DOCKERDIR/volition.ini
```

Just add the name of the account you plan to use for mining and leave everything else alone:

```
miner = <your miner account name>
```

Generate the mining keys with the helper script:

```
$DOCKERDIR/make-keys.sh
```

The keys will be placed in $DOCKERDIR/volition/keys. Keep these safe and don't lose them.

Use curl to fetch the genesis block:

```
curl <URL of genesis block> -o $DOCKERDIR/volition/genesis.json
```

For example, the open beta genesis block is located at https://raw.githubusercontent.com/cryptogogue/vol-blocks/main/volition-ccg/ccg-open-beta.json.


Finally, use the helper script to provision the docker networks:

```
$DOCKERDIR/make-networks.sh
```

## Starting the Node

Run docker as a daemon:

```
$DOCKERDIR/docker-compose up -d
```

Or use the helper scripts:

```
$DOCKERDIR/up.sh
$DOCKERDIR/down.sh
```

Each service will be mounted at a subdomain. So if your domain name is "bulbousbouffant.com", you would find Dozzle at "dozzle.bulbousbouffant.com":

* https://dozzle.bulbousbouffant.com
* https://traefik.bulbousbouffant.com
* https://volition.bulbousbouffant.com

If you are using Cloudflare, it may take a little while to provision your SSL certificates, so if you don't see the services appear right away, try back in five or ten minutes.

## Upgrade Your Account

Once your node is connected to the network, you are ready to upgrade your account and start mining.

At the time of this writing, self-serve mining accounts aren't supported. Those will entail obtaining a verified digital identity from a third party.

To upgrade your account, ask someone with an administrator account to help you. You will need to send them the URL of your mining node. Alternatively, you may be able to use the Volition Discord bot, which is occasionally available in the #volbot channel:

```
volbot, upgrade <URL of your mining node>
```

That's it. If everything worked, a miner is you.

## Submit Feedback / Bugs

If you run into any issues while setting up the node, or if something stops working, please let us know on Discord or open an issue on this repo.

## Appendix 1: Updating the Node

The included stack uses watchtower to automatically update images for your docker container. At `12:30 AM` local time, watchtower will do a check against the docker-hub registry and pull any needed updates.

If you want to force an update you can do the following:

```
cd $DOCKERDIR
docker-compose pull
docker-compose up -d
```

## Appendix 2: Using a Different Node Image


```
vi $DOCKERDIR/.env
```

Change the DOCKER_IMAGE_VOLITION variable, then restart the stack.

```
$DOCKERDIR/down.sh
$DOCKERDIR/up.sh
```

You should see the new image pull down before docker restarts.

## Appendix 3: Setting Up Cloudflare

First, if you do not already have a [CloudFlare](https://www.cloudflare.com/) account, create one and log in.

If you are creating a new CloudFlare account, you can choose their "free" plan (which may be listed below the paid plans on their welcome screen; look for it).

Once logged in, add your domain to CloudFlare for DNS management. Cloudflare will instruct you to change your domain name servers, follow the instructions provided by CloudFlare. You can choose the default settings; the main thing right now is to update your domain account (with your registrar) to use CloudFlare's nameservers and wait for the changes to go through. This could take up to 24 hours. Once this is done, we can modify the DNS settings.

Once the domain has been added to CloudFlare, we need to change some settings.

Click on the domain name to open its settings.

![CloudFlare Domain Selection](images/cloudflare_domain_selection.png)

Click on the DNS options button.

![CloudFlare DNS Option](images/cloudflare_dns_option.png)

Make the following changes:

* Verify the A record IP is set correctly
* Change the root domain records Proxy status to DNS only (by clicking 'edit' and then the orange cloud icon; it should turn gray)
* Add a new CNAME record
  * Name: *
  * Target: your domain name
  * TTL: Auto
  * Proxy status: DNS Only
* Make sure your domain host is using the Cloudflare nameservers shown below
  
Your settings should look similiar to this:

![CloudFlare DNS Settings](images/cloudflare_dns_settings.png)

Once done, click on the SSL/TLS button at the top. Make sure you have SSL/TLS encryption mode set to full.

![CloudFlare SSL Settings](images/cloudflare_ssl_settings.png)

> **If your server does not have a static IP, follow the next step**

To update CloudFlare with our public IP, we'll need our CloudFlare Global API key.

Click on your account icon on the top right of the screen and click My Profile.

![CloudFlare Account Home](images/cloudflare_account_profile.png)

Click on API Tokens -> Global Api Key -> View, and copy the Global API Key.

![CloudFlare API Key](images/cloudflare_api_key.png)

This is the API key for the .env file in your docker directory. Edit the file:

```
vi $DOCKERDIR/.env
```

And set the Cloudflare environment variables:

```
CLOUDFLARE_EMAIL = <the email address associated with your Cloudflare account>
CLOUDFLARE_API_KEY = <the Cloudflare API key>
```

That should be all there is to it. Continue the node setup process described earlier in this document.
