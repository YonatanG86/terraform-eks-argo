# modules/gitlab/templates/user_data.sh
#!/bin/bash
set -e

# Update system packages
apt-get update
apt-get upgrade -y

# Install required packages
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    docker.io \
    docker-compose

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Format and mount the EBS volume if it's not already mounted
if [ ! -d "/gitlab-data" ]; then
    mkdir -p /gitlab-data
fi

# Check if the device exists and is not mounted
if [ -e /dev/xvdf ] && ! mountpoint -q /gitlab-data; then
    # Check if the device needs to be formatted
    if ! blkid /dev/xvdf; then
        mkfs -t xfs /dev/xvdf
    fi
    
    # Add to fstab for persistent mount
    echo "/dev/xvdf /gitlab-data xfs defaults,nofail 0 2" >> /etc/fstab
    mount /gitlab-data
fi

# Create Docker Compose configuration
cat > /gitlab-data/docker-compose.yml <<EOL
version: '3.7'
services:
  gitlab:
    image: 'gitlab/gitlab-ce:${gitlab_version}'
    restart: always
    hostname: 'gitlab.example.com'
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'http://gitlab.example.com:9090'
        gitlab_rails['gitlab_shell_ssh_port'] = 22
        prometheus['listen_address'] = '0.0.0.0:9090'
    ports:
      - '9090:9090'
      - '22:22'
    volumes:
      - '/gitlab-data/config:/etc/gitlab'
      - '/gitlab-data/logs:/var/log/gitlab'
      - '/gitlab-data/data:/var/opt/gitlab'
    shm_size: '256m'
    deploy:
      resources:
        limits:
          memory: 4G
    healthcheck:
      test: ["CMD", "/opt/gitlab/bin/gitlab-healthcheck", "--fail-fast"]
      interval: 60s
      timeout: 30s
      retries: 5
      start_period: 180s
EOL

# Start GitLab
cd /gitlab-data
docker-compose up -d

# Wait for GitLab to start
echo "Waiting for GitLab to start..."
until curl -s http://localhost:9090/users/sign_in > /dev/null; do
    echo "GitLab is not ready yet..."
    sleep 10
done

echo "GitLab setup complete!"