FROM ubuntu AS build
# FROM mcr.microsoft.com/dotnet/core/sdk AS build


#CMD [ "wget https://packages.microsoft.com/config/ubuntu/20.10/packages-microsoft-prod.deb -O /packages-microsoft-prod.deb" , "dpkg -i packages-microsoft-prod.deb"]
RUN  apt-get update \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/*
RUN wget https://packages.microsoft.com/config/ubuntu/20.10/packages-microsoft-prod.deb > /etc/apt/packages-microsoft-prod.deb
RUN  dpkg -i packages-microsoft-prod.deb
RUN apt-get install -y apt-transport-https && \
   apt-get update && \
   apt-get install -y dotnet-sdk-5.0

 WORKDIR /app
# # copy csproj and restore as distinct layers
 COPY *.sln .
 COPY *.csproj ./
 RUN dotnet restore

# # # copy everything else and build app
COPY . ./
WORKDIR /app
RUN dotnet publish -c Release -o out

FROM ubuntu  AS runtime

ARG BUILD_CONFIGURATION=Debug
ENV ASPNETCORE_ENVIRONMENT=Product
ENV DOTNET_USE_POLLING_FILE_WATCHER=true  
ENV ASPNETCORE_URLS=http://+:8080  
RUN  apt-get update \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/*
RUN wget https://packages.microsoft.com/config/ubuntu/20.10/packages-microsoft-prod.deb > /etc/apt/packages-microsoft-prod.deb
RUN  dpkg -i packages-microsoft-prod.deb
RUN  apt-get update; \
   apt-get install -y apt-transport-https && \
   apt-get update && \
   apt-get install -y aspnetcore-runtime-5.0
WORKDIR /app
COPY --from=build /app/out ./
EXPOSE 8080
ENTRYPOINT ["dotnet", "automatizador.api.dll"]
