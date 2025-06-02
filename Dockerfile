FROM node:jod-bookworm-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
  cron \
  curl \
  unzip \
  jq

# Install AWS CLI v2
RUN ARCH=$(uname -m) \
  && curl -sS "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip" -o /tmp/awscliv2.zip \
  && unzip -q /tmp/awscliv2.zip -d /tmp \
  && /tmp/aws/install \
  && rm -rf /tmp/aws /tmp/awscliv2.zip

# Install latest version of npm
RUN npm install -g npm@latest

# Install dependencies
RUN npm install -g serve@latest

# Copy the entrypoint script to the container
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

# Copy scripts to the container
COPY scripts/* /usr/local/bin/

# Set the working directory
WORKDIR /app

# Create public directory
RUN mkdir -p public

# Expose port 80
ARG PORT=80
ENV PORT $PORT
EXPOSE $PORT

# Start the application
CMD ["serve", "-s", "public", "-l", "80"]
