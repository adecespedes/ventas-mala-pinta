# Etapa de build
FROM node:20.16-alpine AS build

WORKDIR /app

# Copiamos todo el proyecto antes de instalar
COPY . .

# Instalamos dependencias (aquí ya está quasar.config.js y src/)
RUN npm install

# Ejecutamos el build de Quasar
RUN npm run build

# Etapa de producción con Nginx
FROM nginx:alpine

# Copiamos la build al contenedor Nginx
COPY --from=build /app/dist/spa /usr/share/nginx/html

# Si tienes una config personalizada para nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf
