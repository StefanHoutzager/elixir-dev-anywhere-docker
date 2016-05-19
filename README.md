# elixir-dev-anywhere-docker
Develop elixir /phoenix applications in your browser from anywhere, using docker and noVNC

Docker is mostly used to containerize applications for deployment into production. But development is a production environment also, from a certain viewpoint, and it can be handy to ship developmentcontainers.
  I don't like installing on my host with files being placed everywhere, not knowing if an eventual deinstall will completely remove
everything. I want to be able to delete an application and know for sure it is removed completely. Docker gives that. Moreover you 
can control how much CPU and memory the application uses. 
  With noVNC you can connect with your browser from anywhere to docker containers on a server. No install of a vnc viewer on the
client needed. This connection will be via https, password protected. You're not bound to a windows client as with RDP. And with x11 in your container you can run GUI apps in the browser! 
  Of course this repo can be improved. At the end of this readme I will name my own wishlist, suggestions welcome.
  On the server we will have two images and volumes with mutable data. One image with the application
(erlang/elixir/phoenix/node/pgadmin3), an x11vncserver and clientsoftware (javascript) for noVNC and one image with postgresql. Get this one with docker pull postgres (from https://hub.docker.com/_/postgres/). The containers will be started with docker-compose. I assume docker and docker-compose known and installed on your host, documentation can be found online.
  For the noVNC part I used the following repo and made some small modifications:
https://github.com/mccahill/docker-eclipse-novnc. Have a look there for 
- where to point your browser to 
- how to enable the encrypted noVNC session (you will have to place the certificate - a .pem file - in the noVNC folder)

Look for the string badpassword in the Dockerfile and replace it with the one you will use.
Edit docker-compose.yml, replace each volume_name_in_container, volume_name_onhost. Edit further environment variables as you wish. If you uncomment
#      ENABLE_HTTP: "Y" 
you can use only http in your URL, otherwise only https.
  Put the dockerfile and docker-compose.yml in a folder and git clone the repository here too. There are a couple of ADD statements
in the Dockerfile that put files from the elixir-dev-anywhere-docker folder on the host into your image. If you have another display than 1920X1080 you can edit the browser viewportsize in elixir-dev-anywhere-docker/xorg.conf before you build the image, look for Section "Screen" key Virtual and edit. Note that screen resolution !== browsevieport resolution (except width).  

My wishlist
- The applications could be spread over more images to make them more reusable, some maybe with a small FROM image like alpine. My docker knowledge is not enough to do this at the moment. There could be one image for noVNC + x11vncserver, one for pgadmin3, one for erlang/elixir/phoenix and one for postgres. 
- At the moment you have to start with sudo -i to have sufficient rights to develop and start phoenix.server. It would be nice if this is not needed anymore.
- I would like to have spacemacs added as editor. The config should be in a (mutable) volume.
- Dynamic resize of the desktop inside the browser would be great. When used the display config in docker-compose.yml can be removed and the use of the env variables in supervisord.conf.xvfb alsdo. It seems to be built in in Kanaka's sources, see 
https://github.com/kanaka/noVNC/pull/271 . I tried to use these by simply replacing my include folder with Kanaka's but got a js error in the browse and gave up for the moment. 

