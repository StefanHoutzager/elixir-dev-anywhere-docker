# elixir-dev-anywhere-docker

#What it is and why I made it

With this repository you can build a docker image that makes it possible to develop and test elixir / phoenix applications in your browser (it must be HTML5 capable) from anywhere, using docker, intellij IDEA, the intellij-elixir plugin and noVNC. With noVNC you can connect to docker containers on a server. No install of a vnc viewer on the client needed. This connection will be via https or http, password protected. You're not bound to a windows client as with RDP. And with x11 in your container you can run GUI apps in the browser. See elixir-intellij-noVNC.jpg in the repo with the erlang observer, pgadmin3, intellij and firefox running.
  Docker is mostly used to containerize applications for deployment into production. But development is a production environment also, from a certain viewpoint, and it can be handy to ship developmentcontainers. I don't like installing on my host with files being placed everywhere, not knowing if an eventual deinstall will completely remove everything. I want to be able to delete an application and know for sure it is removed completely. Docker gives that. Moreover you can control how much CPU and memory the application uses. 
  Of course this repo can be improved. At the end of this readme I will name my own wishlist, suggestions welcome.
  
#Building the image, composing and run   
  On the server you will have two images and volumes with mutable data. You will build the image with the application (erlang/elixir/phoenix/node/pgadmin3/intellij/intellij-elixir plugin), an x11vncserver and clientsoftware (javascript) for noVNC. The other image contains the postgresql database. You will get that one from dockerhub. The containers will be started and connected with docker-compose. I assume docker and docker-compose known and installed on your host, documentation can be found online. 
  Instructions:
  
0.  Make sure you have port 6080 for noVNC and 4000 for phoenix open in your router ("port forward" for the ip-address check eth0 with ifconfig and make this address fixed), see that you have no blocking firewalls   

1.  Get the postgres image with docker pull postgres (from https://hub.docker.com/_/postgres/).

2.  Create a folder for your repo.

3.  Make sure that you have the latest version of docker-compose (my machine gives with docker-compose version 
    1.7.0rc2, build ea2d526), and also a docker version that supports this new docker-compose (mine is 1.10.3)

4.  CD to you repo folder and git clone https://github.com/StefanHoutzager/elixir-dev-anywhere-docker.git

5.  You have an elixir-dev-anywhere-docker folder in your repofolder now. Copy Dockerfile and docker-compose.yml from 
    elixir-dev-anywhere-docker to your repo folder. There are a couple of ADD statements in the Dockerfile that put files from the elixir-dev-anywhere-docker folder on the host into your image, this way you   
    make sure you have the original files in the repo. Look for the newest version of the intellij-elixir plugin at https://github.com/KronicDeth/intellij-elixir/releases, intellij-elixir.zip , I placed version 7.4.0 in the elixir-dev-anywhere-docker folder. Replace it if you want.

6.  Look for the string badpassword in the Dockerfile and replace it with the ones you prefer use.

7.  To enable encrypted connections, you need to (at a minimum) create a noVNC self.pem certificate file:
    https://github.com/kanaka/websockify/wiki/Encrypted-Connections, put it in elixir-dev-anywhere-docker/noVNC

8.  Edit docker-compose.yml, replace each folder_name_in_container, volume_name_onhost with names of your choice. Edit further environment
    variables as you wish. If you comment ENABLE_HTTP: "Y" you cannot use http besides https in your URL.
    You can override VNC and UBUNTU passwords from the Dockerfile here if you wish, the vars are not mandatory. VIRTUAL_HEIGHT and VIRTUAL_WIDTH are mandatory env vars. They are filled in for my own screen resolution now, which is 1920X1080.  Note that screen resolution !== browseviewport resolution (except width).

9.  Enter your repo folder and build the image with sudo docker build -t stefan/phoenix . | tee build.log

11. If the build has been succesfull start the app with sudo docker-compose up -d   

12. Note the containernames that show up in your terminal. You can use compose_postgres_1 as hostname when you start pgadmin3 later

13. If you want to check the status of the containers: sudo docker ps -a

14. Point your browser to https://your external ip:6080/vnc.html (or use http), or use the inet address of the router (ifconfig)

15. Start intellij in the browser (right mouse should show a menu with an intellij item). This menu is configurable, if you want uncomment the following line
    /var/lib/docker/volumes/openbox/_data:/home/ubuntu/.config/openbox 
    in docker-compose.yml, create the folder on your host and copy the contents of elixir-dev-anywhere-docker/openbox-config/.config/openbox into it

16. Follow instruction here: https://github.com/KronicDeth/intellij-elixir to configure

17. Configure your IDE settings (the theme shown in the jpg contained in this github project f.e. is darcula) https://www.jetbrains.com/help/idea/2016.3/project-and-ide-settings.html
save the settings.jar in the default folder (file -> export settings)

18. Close intellij and copy the IDE setting from the running docker-container to the volume on your host (sudo -i to get rights): 
docker cp your_containername:/home/ubuntu/.IdeaIC2017.3/config /var/lib/docker/volumes/intellij/_data/.IdeaIC2017.3

19. Shutdown the running containers, remove the comment sign (#) in docker-compose.yml from the line - /var/lib/docker/volumes/intellij/_data/.IdeaIC2017.3/config:/home/ubuntu/.IdeaIC2017.3/config
and restart with sudo docker-compose up -d 


#Credits

For the noVNC part I used the following repo and made some small modifications: https://github.com/mccahill/docker-eclipse-novnc. 
Interesting notes from Mark McCahill: https://gitlab.oit.duke.edu/mccahill/docker-novnc-template 
The noVNC folder was taken frome https://github.com/kanaka/noVNC on sept 6 2016

All the people that built elixir, phoenix and the intellij-elixir plugin of course.

#My wishlist

- The applications could be spread over more images to make them more reusable, some maybe with a small FROM image like alpine. My  
  docker knowledge is not enough to do this at the moment. There could be one image for noVNC + x11vncserver, one for intellij, one for pgadmin3, one for erlang/elixir/phoenix and one for postgres maybe. 
- It would be nice to make the openbox theme configurable. Here you can find themes: https://www.box-look.org (look for openbox themes only). I shortly tried to make this work, but miss openbox knowledge 
- Make this fit for use with multiple users.

