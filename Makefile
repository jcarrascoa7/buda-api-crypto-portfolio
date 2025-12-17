API_DIR := api

.PHONY: setup test swagger server lint

setup:
	cd $(API_DIR) && bundle install

test:
	cd $(API_DIR) && bundle exec rspec

swagger:
	cd $(API_DIR) && bundle exec rake rswag:specs:swaggerize

server:
	cd $(API_DIR) && bin/rails s

lint:
	cd $(API_DIR) && bundle exec rubocop
