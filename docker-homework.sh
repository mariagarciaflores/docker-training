# CREATE Sonatype/NEXSUS CONTAINER
docker stop nexus
docker rm nexus
docker run -d -p 8081:8081 --name nexus sonatype/nexus3

# CREATE JENKINS CONTAINER
docker stop jenkins
docker rm jenkins
docker run --name jenkins -d -p 7071:8080 -p 7072:50000 --restart=on-failure -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts-jdk11

# CREATE PORTAINER CONTAINER
docker stop portainer
docker rm portainer

docker volume create portainer_data
docker run -d -p 8000:8000 -p 7073:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ee:latest

# CREATE homework NETWORKS
docker network rm homework
docker network create homework

# CONNECT NEXUS/JENKINS AND PORTAINER TO homework NETWORK
docker network connect homework nexus
docker network connect homework jenkins
docker network connect homework portainer


# CREATE POSTGRES CONTAINER AND ADD IT TO THE homework NETWORK
docker stop postgres
docker rm postgres
docker run --name postgres -e POSTGRES_USER=root -e POSTGRES_PASSWORD=postgres --network homework -d postgres

# CREATE SONARQUBE CONTAINER AND ADD IT TO homework NETWORK
docker stop sonarqube
docker rm sonarqube

docker volume create --name sonarqube_data
docker volume create --name sonarqube_logs
docker volume create --name sonarqube_extensions

docker run -d --name sonarqube -p 7074:9000 -e sonar.jdbc.url=jdbc:postgresql://postgres/postgres -e sonar.jdbc.username=root -e sonar.jdbc.password=postgres -v sonarqube_data:/opt/sonarqube/data -v sonarqube_extensions:/opt/sonarqube/extensions -v sonarqube_logs:/opt/sonarqube/logs --network homework sonarqube

# INSPECT ALL CONTAINERS IN THE homework NETWORK
docker network inspect homework
