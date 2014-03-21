project=my_project
initialize_dockerfiles:
	@./prepare_assets dockerfile $$(pwd)/base   $(project)
	@./prepare_assets dockerfile $$(pwd)/server $(project)
	@./prepare_assets dockerfile $$(pwd)/data   $(project)
	@./prepare_assets dockerfile $$(pwd) "$(project)"

prepare:
	@./prepare_assets ensure_pubkey_exists server/conf/
	@./prepare_assets introduce_hosts assets.server.ca git.server.ca
	@./prepare_assets dl remote.assets.server.ca /path/to/some/database/dump.sql.gz data/assets/
	@./prepare_assets git_repo git@git.server.ca:repo.git project 3.x

tag=latest
build_base:
	docker build -t $(project)/base:$(tag)  $$(pwd)/base
build_server:
	docker build -t $(project)/server:$(tag) $$(pwd)/server
build_data:
	docker build -t $(project)/data:$(tag) $$(pwd)/data
build_drupal:
	docker build -t $(project)/drupal:$(tag) .

p_http=8001
p_ssh=9001
ct_name=$(project)
start_mounted:
	docker run -d -p $(p_ssh):22 -p $(p_http):80 \
		-v $$(pwd)/project:/var/shared/sites/$(project) \
		-name $(ct_name) $(project)/drupal:$(tag)
start:
	docker run -d -p $(p_ssh):22 -p $(p_http):80 \
		-name $(ct_name) $(project)/drupal:$(tag)
ssh:
	rsync --copy-unsafe-links -a -e 'ssh -p $(p_ssh)' ~/.vim* --exclude  ~/.viminfo root@localhost:~
	rsync --copy-unsafe-links -a -e 'ssh -p $(p_ssh)' ~/.bash* --exclude ~/.bash_history root@localhost:~
	rsync --copy-unsafe-links -a -e 'ssh -p $(p_ssh)' ~/.git* root@localhost:~
	ssh localhost -p $(p_ssh) -l root

clean:
	docker ps -a -q | xargs docker rm
	docker images -a | grep '^<none' | awk '{ print $$3 }' | xargs docker rmi
