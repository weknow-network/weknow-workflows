FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
ARG PROJECT
ARG ENTRY_PREFIX
WORKDIR /app
EXPOSE 80

# RUN apt update && \
#       apt install -y curl && \
#       curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && \
#       chmod +x ./kubectl && \
#       mv ./kubectl /usr/local/bin/kubectl

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
ARG PROJECT
ARG ENTRY_PREFIX
WORKDIR /src
COPY ["./", "/src"]

RUN dotnet restore "$PROJECT/$PROJECT.csproj" --configfile "./nuget.config"
COPY . .

WORKDIR "/src/$PROJECT"
RUN dotnet build "$PROJECT.csproj" -c Release -o /app/build

FROM build AS publish
ARG PROJECT
ARG ENTRY_PREFIX
RUN dotnet publish "$PROJECT.csproj" -c Release -o /app/publish

FROM base AS final
ARG PROJECT
ARG ENTRY_PREFIX
WORKDIR /app
# RUN groupadd -r microuser && useradd -r -s /bin/false -g microuser microuser
COPY --from=publish /app/publish .
# RUN chown -R microuser:microuser /app
# USER microuser
RUN ECHO $ENTRY_PREFIX, $PROJECT, "$ENTRY_PREFIX$PROJECT.dll"
ENTRYPOINT ["dotnet"]
CMD [$ENTRY_PREFIX$PROJECT.dll]
