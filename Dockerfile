FROM instrumentisto/flutter:3 AS builder

RUN adduser -D github
USER github

WORKDIR /app
COPY . .
RUN flutter pub get
RUN flutter build web

FROM nginx:alpine

# Копируем собранные файлы из предыдущего этапа
COPY --from=builder /app/build/web /usr/share/nginx/html

# COPY nginx.conf /etc/nginx/nginx.conf

# Открываем порт 80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]