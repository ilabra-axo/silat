# silat ar rahim — Flutter web
# Stage 1: build
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY app/ .

# Get dependencies then build
RUN flutter pub get
RUN flutter build web \
      --no-tree-shake-icons \
      --release

# Stage 2: serve with nginx
FROM nginx:1.27-alpine

COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080
CMD ["/entrypoint.sh"]
