# Makefile de tequio-protos (necesita bash: en Windows, Git Bash)
.DEFAULT_GOAL := help
SHELL := bash

# Contra qué se compara `make breaking` (cualquier input de buf: rama, tag...).
# Ojo: en un Makefile `#` abre un comentario, por eso va escapado.
AGAINST ?= .git\#branch=main

.PHONY: help lint breaking generate check check-gen check-go check-ts release version

## help: lista los targets
help:
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/^## /  /'

## lint: buf lint (reglas STANDARD) + formato de los .proto
lint:
	buf lint
	buf format --diff --exit-code

## breaking: cambios incompatibles contra main (AGAINST='.git#tag=v1.2.0' para otro punto)
breaking:
	buf breaking --against '$(AGAINST)'

## generate: regenera gen/ desde proto/ (plugins remotos: necesita internet)
generate:
	bash scripts/generate.sh

## check-gen: falla si gen/ no corresponde a proto/ (regenera y compara con git)
check-gen: generate
	@if [ -n "$$(git status --porcelain -- gen)" ]; then \
	  git status --short -- gen; \
	  echo "gen/ desactualizado: corré 'make generate' y commiteá el resultado."; exit 1; \
	fi

## check-go: compila el código Go generado
check-go:
	go build ./...
	go vet ./...

## check-ts: tipos (.d.ts) con tsc --noEmit + importa todos los .js con Node
check-ts:
	cd gen/ts && npm install --no-audit --no-fund && npx tsc --noEmit && node ../../scripts/check_ts.mjs

## check: todo lo que corre CI en un MR/PR (salvo breaking)
check: lint check-gen check-go check-ts

## version: muestra la versión de cada paquete
version:
	bash scripts/version.sh show

## release: VERSION=X.Y.Z -> regenera, bump de versiones, commit y tag vX.Y.Z (sin push)
release:
	bash scripts/release.sh "$(VERSION)"
