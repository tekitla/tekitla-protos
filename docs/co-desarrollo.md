# Co-desarrollar un contrato (sin publicar)

Para probar un cambio de `.proto` en un consumidor antes de sacar una versión:

1. En este repo, rama con el cambio: `make lint generate` (el código nuevo
   queda en `gen/`).
2. Apuntar el consumidor al checkout local con el mecanismo de su lenguaje
   (abajo). Se asume este repo clonado al lado: `../tequio-protos`.
3. Cuando funciona: MR/PR acá → merge → `make release` → el consumidor vuelve
   a la dependencia publicada con la versión nueva. **Nunca** mergear un
   consumidor apuntando a un checkout local.

## Go: `go work`

```bash
cd ../mi-servicio
go work init . ../tequio-protos     # go.work: no se commitea (.gitignore)
go build ./... && go test ./...
rm go.work go.work.sum               # volver al módulo publicado
```

Los servicios de la plantilla `go-grpc-service` con `protos_module` tienen
`make workspace` / `make workspace-off` (usan `PROTOS_DIR`, default `../tequio-protos`).
Con `go.work` activo el import resuelve aunque `go.mod` no tenga el `require`
(sí lo necesita para compilar sin workspace, p. ej. en CI). Alternativa sin
workspace, útil antes del primer tag (no mergear así):

```bash
go mod edit -require=github.com/vrojas1015/tequio-protos@v0.0.0 -replace=github.com/vrojas1015/tequio-protos=../tequio-protos
go mod tidy
# al publicar: go mod edit -dropreplace=github.com/vrojas1015/tequio-protos && go get github.com/vrojas1015/tequio-protos@vX.Y.Z
```

## TypeScript / JavaScript: `npm link` o `file:`

```bash
cd ../tequio-protos/gen/ts && npm install && npm link
cd ../../../mi-app && npm link @vrojas1015/tequio-protos
# volver: npm unlink @vrojas1015/tequio-protos && npm install
```

Alternativa sin symlinks globales: `npm install ../tequio-protos/gen/ts` (queda
`"file:../tequio-protos/gen/ts"` en `package.json`: no commitearlo). No hay
paso de build: `lib/` ya es JS + `.d.ts`. Con link/`file:` las dependencias del
paquete no se instalan en el consumidor: si el consumidor importa
`@bufbuild/protobuf` (para `create`, `toBinary`...), agregalo como dependencia
propia (`npm install @bufbuild/protobuf@^2.16.0`). Para probar exactamente lo
que se publicaría: `cd gen/ts && npm pack` e instalar el `.tgz`. Angular/Vite: si no ve el paquete
linkeado, `preserveSymlinks: true` en la config de build.
