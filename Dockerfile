FROM docker.io/library/python:3-alpine

RUN pip install awscli && \
    pip cache purge && \
    apk add jq curl && \
    curl -Lo /usr/local/bin/kubectl "https://dl.k8s.io/release/v1.24.0/bin/linux/amd64/kubectl" && \
    chmod +x /usr/local/bin/kubectl

COPY run.sh /usr/local/bin/run.sh

ENTRYPOINT ["/usr/local/bin/run.sh"]
