.PHONY: db app migrate networks

db:
	docker-compose up -d cadena-database

app:
	docker-compose run -p 3000:3000 cadena-application ash

networks:
	@docker network create neeco_cadena-cuenta || true
	@docker network create neeco_cadena-imagen || true
	@docker network create neeco_caja-cadena || true
