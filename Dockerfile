FROM openjdk:7 as build
RUN apt-get update
RUN apt install wget -y
RUN wget http://www.scala-lang.org/files/archive/scala-2.11.6.deb
RUN dpkg -i scala-2.11.6.deb
RUN apt-get update
RUN apt-get install scala
WORKDIR /opt
RUN wget http://downloads.typesafe.com/typesafe-activator/1.3.2/typesafe-activator-1.3.2-minimal.zip
RUN unzip typesafe-activator-1.3.2-minimal.zip
RUN mv activator-1.3.2-minimal activator

RUN chmod a+x /opt/activator/activator
WORKDIR /src
ADD ./ ./
RUN /opt/activator/activator assembly

FROM java:alpine
CMD ["java", "-Dconfig.file=config.conf", "-jar", "kind_sir.jar"]
COPY --from=build /src/kind_sir.jar ./kind_sir.jar
