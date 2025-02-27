FROM ubuntu:latest

# Update and install dependencies
RUN apt update && apt install -y \
    openssh-server passwd sudo mysql-client curl unzip vim python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Install AWS CLI v2 correctly
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

# Create SSH user
RUN useradd -m -s /bin/bash remote_user && \
    echo "remote_user:1234" | chpasswd && \
    mkdir -p /home/remote_user/.ssh && \
    chmod 700 /home/remote_user/.ssh

# Copy SSH key for login
COPY remote-key.pub /home/remote_user/.ssh/authorized_keys
RUN chmod 600 /home/remote_user/.ssh/authorized_keys && \
    chown -R remote_user:remote_user /home/remote_user/.ssh

# Enable SSH and generate host keys
RUN mkdir /run/sshd && ssh-keygen -A

# Start SSH service
CMD ["/usr/sbin/sshd", "-D"]

