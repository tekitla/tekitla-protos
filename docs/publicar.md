# Publicar una versión de tequio-protos

## Modelo

- **El tag `vX.Y.Z` es la versión** de todos los paquetes. Semver: MINOR para
  cambios aditivos, PATCH para comentarios/empaquetado, MAJOR solo al retirar
  un paquete `vN` viejo (los cambios incompatibles van a un paquete `v(N+1)`).
- El código generado está **commiteado** en `gen/`; CI verifica en cada MR/PR
  que corresponda a `proto/` y, en el tag, publica exactamente eso.
- Las versiones dentro de los archivos de empaquetado (`gen/ts/package.json`)
  las escribe `make release` y CI **exige** que coincidan con el tag
  (`scripts/version.sh check`). Se eligió verificar en vez de setearlas desde
  el tag en CI para que lo commiteado en el tag sea idéntico a lo publicado
  (un `pip install git+...@vX.Y.Z` reporta la misma versión que el registry).

## Pasos

```bash
git switch main && git pull
make check                     # opcional: lo mismo que CI
make release VERSION=0.3.0     # regenera, bump, commit "chore(release): v0.3.0", tag anotado
git push origin main && git push origin v0.3.0
```

`make release` falla si hay cambios sin commitear, si `gen/` no corresponde a
`proto/` o si el tag ya existe. No pushea: eso lo decide una persona.

Con `main` protegida (sin push directo): en una rama, `bash scripts/version.sh
set X.Y.Z`, commit y MR/PR; después del merge, sobre ese commit de `main`:
`git tag -a vX.Y.Z -m "Release vX.Y.Z" && git push origin vX.Y.Z`.

## Qué publica CI con el tag

| Lenguaje | Destino |
|---|---|
| Go | Nada: el proxy de Go lee el tag (`go get github.com/vrojas1015/tequio-protos@vX.Y.Z`) |
| TS/JS | GitHub Packages npm (`GITHUB_TOKEN`, `packages: write`) |

Un registry no acepta volver a publicar la misma versión: si algo falló a
mitad de camino, se corrige y se saca `vX.Y.(Z+1)`. **Nunca** mover ni borrar
un tag publicado (el proxy de Go y los caches ya lo guardaron).

## Setup de una sola vez

- Settings > Rules > Rulesets: proteger tags `v*`.
- Settings > Actions > General > Workflow permissions: lectura por default
  (el workflow pide `contents: write` / `packages: write` solo donde publica).
- npm en GitHub Packages: el scope `@vrojas1015` tiene que ser el
  owner del repo (usuario u organización).
- Visibilidad de los paquetes (Packages > Package settings): heredar del repo o
  dar acceso a los repos consumidores.
- Opcional: variable/secret `BUF_TOKEN` (token de la BSR) en CI. Los plugins
  remotos sin autenticar tienen rate limit; con muchos plugins o muchos
  pipelines aparece `resource_exhausted: too many requests`.

## Versiones de plugins y runtimes

Subir un plugin en `buf.gen.yaml` cambia el código generado de todos los
archivos: hacelo en un MR propio, con `make generate` y el bump de runtime.

| Plugin (`buf.gen.yaml`) | Runtime que exige el código generado |
|---|---|
| `protocolbuffers/go:v1.36.12`, `grpc/go:v1.6.2` | `google.golang.org/protobuf v1.36.12`, `google.golang.org/grpc` >= 1.64 (`go.mod`) |
| `grpc-ecosystem/gateway:v2.30.0`, `grpc-ecosystem/openapiv2:v2.30.0` | `github.com/grpc-ecosystem/grpc-gateway/v2 v2.30.0` y `google.golang.org/genproto/googleapis/api` (`go.mod`); googleapis fijado en `buf.lock`; TS: `google/api/*` se genera junto (`include_imports`) |
| `bufbuild/es:v2.16.0` | `@bufbuild/protobuf ^2.16.0` |
