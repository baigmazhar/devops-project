# Stage 1: Build the React app
FROM node:14.17.0-alpine AS builder

WORKDIR /app

# ARG lets Jenkins pass the real backend URL at build time:
# docker build --build-arg REACT_APP_SERVER_URL=http://<K3S_IP>:30800/employees
ARG REACT_APP_SERVER_URL=http://localhost:8080/employees

# Make it available to React build (React reads REACT_APP_* env vars at build time)
ENV REACT_APP_SERVER_URL=$REACT_APP_SERVER_URL

# Copy package files first (for layer caching)
COPY package.json package-lock.json ./
RUN npm install

# Copy rest of source code
COPY . .

# Build production bundle (REACT_APP_SERVER_URL gets baked in here)
RUN npm run build

# Stage 2: Serve with Nginx (lightweight, production-ready)
FROM nginx:alpine

# Copy built static files to nginx serve directory
COPY --from=builder /app/build /usr/share/nginx/html

# Copy custom nginx config for React Router support
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
