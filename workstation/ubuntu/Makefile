GITCOMMIT := $(shell git rev-parse --short=7 HEAD 2>/dev/null)
NAME=dev

all: build

build:
	docker build -t latb/${NAME}:${GITCOMMIT} .

push:
	@echo "==> Publishing latb/${NAME}:$(GITCOMMIT)"
	@docker tag latb/${NAME}:$(GITCOMMIT) latb/${NAME}:latest
	@docker push latb/${NAME}:$(GITCOMMIT)
	@docker push latb/${NAME}:latest
	@echo "==> Your image is now available at latb/${NAME}:$(GITCOMMIT)"

run: kill
	docker run -it -h dev -d --net=host --rm -v /var/run/docker.sock:/var/run/docker.sock -v /home/fatih/code:/home/fatih/code -v /home/fatih/.ssh:/home/fatih/.ssh -v /home/fatih/.zsh_private:/home/fatih/.zsh_private -v /home/fatih/.zsh_history:/home/fatih/.zsh_history --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --privileged --name dev latb:dev 

ssh:
		mosh --no-init --ssh="ssh -o StrictHostKeyChecking=no -i ~/.ssh/ipad_rsa -p 3222" latb@localhost -- tmux new-session -AD -s main

kill:
	docker kill dev | true


.PHONY: all build run kill
