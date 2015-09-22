.PHONY: all push

REPO_NAME = uochan/family

all:
	docker build --rm -t $(REPO_NAME) .

push:
	docker push $(REPO_NAME)
