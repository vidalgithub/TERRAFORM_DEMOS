# First stage: Build the application with all dependencies
FROM ubuntu:22.04 as build

# Set environment variables for non-interactive apt installs
ENV DEBIAN_FRONTEND=noninteractive

# Install curl and unzip to download AWS CLI and Helm
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && sudo ./aws/install \
    && rm -rf awscliv2.zip aws

# Install Helm
RUN curl https://baltocdn.com/helm/signing.asc | apt-key add - \
    && apt-get install -y apt-transport-https \
    && echo "deb https://baltocdn.com/helm/debian/ stable main" | tee /etc/apt/sources.list.d/helm.list \
    && apt-get update \
    && apt-get install -y helm \
    && rm -rf /var/lib/apt/lists/*

# Second stage: Create a lightweight image with the necessary binaries
FROM hashicorp/terraform:1.9.3

# Copy AWS CLI and Helm binaries from the build stage
COPY --from=build /usr/local/bin/aws /usr/local/bin/aws
COPY --from=build /usr/local/aws-cli /usr/local/aws-cli
COPY --from=build /usr/bin/helm /usr/bin/helm

# Set entrypoint for Terraform
ENTRYPOINT ["/bin/terraform"]

# Define default command
CMD ["--version"]
