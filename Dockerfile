FROM debian:jessie-slim
LABEL maintainer="Andrew Rynhard <andrew.rynhard@logicmonitor.com>"
ENV TERRAFORM_VERSION="0.10.6"
ENV TERRAGRUNT_VERSION="v0.13.3"
ENV TERRAFORM_PROVIDER_HELM_VERSION="v0.3.2"
ENV KUBERNETES_VERSION="v1.7.5"
ENV HELM_VERSION="v2.6.1"
ENV ANSIBLE_VERSION="2.3.1.0"
RUN apt-get -y update
RUN apt-get -y install --no-install-recommends curl ca-certificates git openssh-client unzip
# Ansible
RUN apt-get -y install build-essential libssl-dev libffi-dev python3 python-dev python-pip
RUN pip install --upgrade cffi
RUN pip install ansible==${ANSIBLE_VERSION}
# Terragrunt
RUN curl -L -o /usr/local/bin/terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64
# Helm Terraform Provider
RUN curl -L https://github.com/mcuadros/terraform-provider-helm/releases/download/${TERRAFORM_PROVIDER_HELM_VERSION}/terraform-provider-helm_${TERRAFORM_PROVIDER_HELM_VERSION}_linux_amd64.tar.gz | tar -xz --strip-components=1 -C /usr/local/bin terraform-provider-helm_linux_amd64/terraform-provider-helm
# Terraform
RUN curl -L https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o /tmp/terraform.zip \
    && unzip /tmp/terraform.zip \
    && mv terraform /usr/local/bin/ \
    && rm /tmp/terraform.zip
# Kubernetes
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBERNETES_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBERNETES_VERSION}/bin/linux/amd64/kubeadm -o /usr/local/bin/kubeadm
# Helm
RUN curl -L https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar -xz -C /tmp \
    && mv /tmp/linux-amd64/helm /usr/local/bin/helm \
    && chmod +x /usr/local/bin/* \
    && rm -rf /tmp/linux-amd64
RUN helm init --client-only
RUN helm repo add logicmonitor-s3 https://s3-us-west-1.amazonaws.com/logicmonitor-helm-charts/stable
RUN helm repo add logicmonitor https://logicmonitor.github.com/k8s-helm-charts
# .bashrc
RUN echo 'eval $(ssh-agent -s >/dev/null 2>&1)' >> ~/.bashrc
RUN echo 'ssh-add ~/.kube/assets/ssh/id_rsa >/dev/null 2>&1' >> ~/.bashrc

RUN ln -fs /bin/bash /bin/sh
WORKDIR /src
COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
