.PHONY: db app migrate network

db:
	docker-compose up -d cadena-database

app:
	docker-compose run -p 3000:3000 cadena-application ash

network:
	@docker network create neeco_develop || true
