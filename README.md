# tekitla-protos

Contratos gRPC de **Tekitla**, el tracker de proyectos de vrojas1015 (issue 002
en el repo `docs`), escritos en Protobuf con [buf](https://buf.build), y su
código generado para go y typescript. Desde las anotaciones `google.api.http`
salen también los handlers REST y el OpenAPI que usa `tekitla-gateway`.

| Lenguaje | Cómo se consume (detalle en `docs/consumir.md`) |
|---|---|
| Go | `go get github.com/tekitla/tekitla-protos@vX.Y.Z` → `import issuesv1 "github.com/tekitla/tekitla-protos/gen/go/issues/v1"` |
| TypeScript / JS | `npm install @tekitla/tekitla-protos@X.Y.Z` (registry de GitHub Packages) |

## Contratos

| Paquete | Servicio | Lo implementa | Lo consumen |
|---|---|---|---|
| `issues.v1` (`proto/issues/v1/issues.proto`) | `IssueService`: proyectos e issues | `tekitla-issues` | `tekitla-gateway` → `tekitla-web`, `tekitla-cli` (`tk`) |

### `issues.v1.IssueService`

| RPC | REST | Qué hace |
|---|---|---|
| `ListProjects` | `GET /v1/projects` | Proyectos visibles para el usuario (todos sus espacios o uno, con `workspace_id`) |
| `CreateProject` | `POST /v1/projects` | Crea un proyecto; la key es única por espacio |
| `ListIssues` | `GET /v1/projects/{project_id}/issues` | Issues de un proyecto por `rank`, con filtro de estado opcional |
| `GetIssue` | `GET /v1/projects/{project_id}/issues/{number}` | Un issue por su número en el proyecto |
| `CreateIssue` | `POST /v1/projects/{project_id}/issues` | Crea un issue en `TODO`, al final del orden |
| `MoveIssue` | `POST /v1/projects/{project_id}/issues/{number}:move` | Cambia el estado (mover de columna) |

Estar anotada no vuelve pública una ruta: el gateway la expone solo si figura
en su `routes.yaml`.

Conceptos que conviene conocer antes de consumirlo:

- **Espacio de trabajo** (`workspace_id`): todo proyecto vive en uno. En la
  rebanada 1 es el espacio personal de cada usuario; desde la rebanada 3, un
  espacio de equipo es un tenant de la plataforma (issue 005). Lo ajeno o no
  visible responde `NOT_FOUND`.
- **`IssueState` es una categoría** (`TODO`, `IN_PROGRESS`, `DONE`,
  `CANCELED`), no una columna fija. Los estados configurables por proyecto
  van a llegar como un campo nuevo, y cada uno va a pertenecer a una
  categoría.
- **`rank`**: posición opaca en el orden manual del proyecto. Se compara como
  string y el cliente no la calcula.
- **Identidad**: viaja en la metadata gRPC que arma el gateway (`x-user-id`,
  `x-roles`), nunca en los mensajes.

Plan por rebanadas y decisiones de diseño: `contenido/issues/002-*/plan.md`
en el repo `docs`.

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
