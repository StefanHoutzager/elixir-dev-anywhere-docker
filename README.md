# elixir-dev-anywhere-docker

#What it is and why I made it

With this repository you can build a docker image that makes it possible to develop and test elixir / phoenix applications in your browser from anywhere, using docker and noVNC. With noVNC you can connect to docker containers on a server. No install of a vnc viewer on the client needed. This connection will be via https or http, password protected. You're not bound to a windows client as with RDP. And with x11 in your container you can run GUI apps in the browser. See phoenix-noVNC.jpg in the repo with the erlang observer, pgadmin3 and firefox running.
  Docker is mostly used to containerize applications for deployment into production. But development is a production environment also,
from a certain viewpoint, and it can be handy to ship developmentcontainers. I don't like installing on my host with files being placed everywhere, not knowing if an eventual deinstall will completely remove everything. I want to be able to delete an application and know for sure it is removed completely. Docker gives that. Moreover you can control how much CPU and memory the application uses. 
  Of course this repo can be improved. At the end of this readme I will name my own wishlist, suggestions welcome.
  
#Building the image, composing and run   
  On the server you will have two images and volumes with mutable data. You will build the image with the application
(erlang/elixir/phoenix/node/pgadmin3), an x11vncserver and clientsoftware (javascript) for noVNC. The other image contains the postgresql database. You will get that one from dockerhub. The containers will be started and connected with docker-compose. I assume docker and docker-compose known and installed on your host, documentation can be found online. 
  Instructions:
  
0.  Make sure you have port 6080 for noVNC and 4000 for phoenix open in your router ("port forward" for the ip-address check eth0 with     ifconfig and make this address fixed), see that you have no blocking firewalls   

1.  Get the postgres image with docker pull postgres (from https://hub.docker.com/_/postgres/).

2.  Create a folder for your repo.

3.  Make sure that you have the latest version of docker-compose (my machine gives with docker-compose version 
    1.7.0rc2, build ea2d526), and also a docker version that supports this new docker-compose (mine is 1.10.3)

4.  CD to you repo folder and git clone https://github.com/StefanHoutzager/elixir-dev-anywhere-docker.git

5.  You have a elixir-dev-anywhere-docker folder in your repofolder now. Copy Dockerfile and docker-compose.yml from 
    elixir-dev-anywhere-docker to your repo folder. There are a couple of ADD statements in the Dockerfile that put files from the elixir-dev-anywhere-docker folder on the host into your image, this way you make sure you ghave the original files in the repo.

6. Look for the string badpassword in the Dockerfile and replace it with the one you will use.

7.  To enable encrypted connections, you need to (at a minimum) create a noVNC self.pem certificate file:
    https://github.com/kanaka/websockify/wiki/Encrypted-Connections, put it in elixir-dev-anywhere-docker/noVNC

8.  Edit docker-compose.yml, replace each folder_name_in_container, volume_name_onhost with your choice. Edit further environment
    variables as you wish. If you uncomment #      ENABLE_HTTP: "Y" you can use http besides https in your URL, otherwise only https.

9.  I know the following is clumsy, the solution should be dynamic. See my wishlist below. If you have another display than 1920X1080 
    you can edit the browser viewportsize in elixir-dev-anywhere-docker/xorg.conf before you build the image, look for Section "Screen" key Virtual and edit. Note that screen resolution !== browseviewport resolution (except width). 

10. Enter your repo folder and build the image with sudo docker build -t stefan/phoenix . | tee build.log

11. If the build has been succesfull start the app with sudo docker-compose up -d  

12. Note the containernames that show up in your terminal. You can use compose_postgres_1 as hostname when you start pgadmin3 later

13. If you want to check the status of the containers: sudo docker ps -a

14. Give the containers a couple of seconds to start al processes before you go to the noVNC page in your browser, otherwise the 
    port might prove idle.

15. Point your browser to https://your external ip:6080/vnc.html (or use http)

16. When you logged in sudo -i before you use iex

#Credits

For the noVNC part I used the following repo and made some small modifications: https://github.com/mccahill/docker-eclipse-novnc.  

#My wishlist

- The applications could be spread over more images to make them more reusable, some maybe with a small FROM image like alpine. My  
  docker knowledge is not enough to do this at the moment. There could be one image for noVNC + x11vncserver, one for pgadmin3, one for erlang/elixir/phoenix and one for postgres. 
- At the moment you have to start with sudo -i to have sufficient rights to develop and start phoenix.server. It would be nice if this   is not needed anymore and your cd is the data-volume.
- I would like to have spacemacs added as editor. Maybe this can help as starting point:
  https://hub.docker.com/r/jare/spacemacs/~/dockerfile/The config should be in a (mutable) volume. Pointers for handy configs for elixir would be great.
- Dynamic resize of the desktop inside the browser would be great. It seems to be built in in Kanaka's sources, see 
  https://github.com/kanaka/noVNC/pull/271 . I tried to use these by simply replacing my include folder with Kanaka's but got a js error in the browse and gave up for the moment. 

