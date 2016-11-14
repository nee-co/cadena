REVISION=`git rev-parse HEAD`

.PHONY: image db app migrate volumes networks

image:
	docker build --tag cadena-application --build-arg REVISION=$(REVISION) .

db:
	docker-compose up -d cadena-database

app:
	docker-compose up -d cadena-application

volumes:
	@docker volume create --name neeco_cadena || true

networks:
	@docker network create neeco_cadena || true
	@docker network create neeco_cadena-cuenta || true
	@docker network create neeco_cadena-caja || true
