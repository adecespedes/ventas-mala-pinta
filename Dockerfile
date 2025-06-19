# Etapa 1: Build
FROM node:20.16-alpine AS build

# Aceptamos la variable para VITE_API_URL
ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL

WORKDIR /app

# Copiamos archivos necesarios
COPY package*.json ./
COPY . .

# Instalamos dependencias y compilamos
RUN npm install && npm run build

# Etapa 2: Servidor NGINX para servir el frontend
FROM nginx:alpine

# Copiamos archivos compilados al contenedor NGINX
COPY --from=build /app/dist /usr/share/nginx/html

# Configuración personalizada de NGINX (si tienes una)
COPY nginx.conf /etc/nginx/conf.d/default.conf
