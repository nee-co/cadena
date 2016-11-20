REVISION=`git rev-parse HEAD`

.PHONY: image db app migrate networks

image:
	docker build --tag cadena-application --build-arg REVISION=$(REVISION) .

db:
	docker-compose up -d cadena-database

app:
	docker-compose run -p 3000:3000 cadena-application ash

networks:
	@docker network create neeco_cadena-cuenta || true
	@docker network create neeco_cadena-caja || true
