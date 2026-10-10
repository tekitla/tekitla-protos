# tequio-protos

Contratos gRPC de vrojas1015 (Protobuf + [buf](https://buf.build)) y su
código generado para go, typescript.

| Lenguaje | Cómo se consume (detalle en `docs/consumir.md`) |
|---|---|
| Go | `go get github.com/vrojas1015/tequio-protos@vX.Y.Z` → `import examplev1 "github.com/vrojas1015/tequio-protos/gen/go/issues/v1"` |
| TypeScript / JS | `npm install @vrojas1015/tequio-protos@X.Y.Z` (registry de GitHub Packages) |

## Trabajo diario

```bash
make lint breaking     # reglas de estilo y compatibilidad
make generate          # regenera gen/ (commitearlo junto al .proto)
make check             # lo mismo que corre CI
```

Requisitos: `buf` 1.71+ y bash; Go 1.25+; Node 24+.

## Documentación

- `CLAUDE.md`: reglas de contratos, versionado y orden de trabajo.
- `docs/consumir.md`: cómo usar los paquetes desde cada lenguaje.
- `docs/publicar.md`: cómo sacar una versión y qué publica CI.
- `docs/co-desarrollo.md`: probar un cambio de contrato sin publicar.
