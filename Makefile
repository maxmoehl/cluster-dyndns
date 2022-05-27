default: build push update-latest

TAG="dev"

build:
	docker image build -t m4xmoehl/route53-dyndns:${TAG} .

push:
	docker image push m4xmoehl/route53-dyndns:${TAG}

update-latest:
	docker image tag m4xmoehl/route53-dyndns:${TAG} m4xmoehl/route53-dyndns:latest
	docker image push m4xmoehl/route53-dyndns:latest
