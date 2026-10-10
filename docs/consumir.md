# Consumir tekitla-protos

Una versión = un tag `vX.Y.Z` de este repo (ver `publicar.md`). Los ejemplos
usan `issues.v1.IssueService`.

## Go

```bash
go get github.com/tekitla/tekitla-protos@vX.Y.Z
```

```go
import issuesv1 "github.com/tekitla/tekitla-protos/gen/go/issues/v1"

// Servidor: embeber Unimplemented…Server (forward-compat con RPCs nuevos).
type IssueHandler struct {
	issuesv1.UnimplementedIssueServiceServer
}

// Cliente:
client := issuesv1.NewIssueServiceClient(conn)
res, err := client.GetIssue(ctx, &issuesv1.GetIssueRequest{ProjectId: "p1", Number: 42})
```

Repo privado: `GOPRIVATE=github.com/tekitla/tekitla-protos` y credenciales de git para
`github.com` (`~/.netrc`, o
`git config --global url."https://oauth2:<token>@github.com/".insteadOf "https://github.com/"`).
En CI: un secret con un
token de solo lectura a este repo.

Servicio generado con la plantilla `go-grpc-service`: responder
`protos_module=github.com/tekitla/tekitla-protos` y seguir la sección "Protos" de su
`CLAUDE.md`: importar `github.com/tekitla/tekitla-protos/gen/go/issues/v1` y
borrar `proto/`, `gen/`, `buf.yaml` y `buf.gen.yaml` del servicio (el ejemplo
`ItemService` de la plantilla). No pueden convivir los dos: protobuf-go entra en
pánico si dos paquetes registran el mismo paquete `issues.v1`.

## REST (api-gateway)

Las anotaciones `google.api.http` generan, en el mismo paquete Go,
`RegisterXxxServiceHandler` (grpc-gateway) y un OpenAPI v2 de todas las
rutas en `gen/openapi/api.swagger.json` (paquete Go
`github.com/tekitla/tekitla-protos/gen/openapi`, variable `openapi.Spec`).

Gateway generado con la plantilla `api-gateway`: responder
`protos_module=github.com/tekitla/tekitla-protos` y seguir "Pasar al repo de protos" de su
`CLAUDE.md` (cambiar los imports de `gen/go/example/v1` y `gen/openapi`). Cada
RPC nuevo se expone recién al agregarlo a su `routes.yaml`.

Clientes web/móviles tipados: generarlos desde el OpenAPI (p. ej.
`openapi-generator` o `openapi-typescript` sobre `api.swagger.json`) o usar
directamente los tipos de los protos.

## TypeScript y JavaScript

El paquete trae JS ESM + `.d.ts` (protobuf-es v2), sin `.ts` crudos: funciona
en TypeScript, en JavaScript puro con Node y en bundlers (Angular, Vite...).
Se importa por subpath, archivo por archivo:
`@tekitla/tekitla-protos/<paquete>/vN/<archivo>_pb`.

`.npmrc` del consumidor (GitHub Packages siempre pide token, `read:packages`):

```ini
@tekitla:registry=https://npm.pkg.github.com
//npm.pkg.github.com/:_authToken=${NPM_TOKEN}
```

```bash
npm install @tekitla/tekitla-protos@X.Y.Z
```

```js
// consumer.mjs (JS puro) o consumer.ts (mismo código, con tipos)
import { create, toBinary, fromBinary, toJson } from "@bufbuild/protobuf";
import { IssueSchema, IssueService } from "@tekitla/tekitla-protos/issues/v1/issues_pb";

const issue = create(IssueSchema, { id: "1", number: 42, title: "hola" });
const bytes = toBinary(IssueSchema, issue);
console.log(toJson(IssueSchema, fromBinary(IssueSchema, bytes)));
console.log(Object.keys(IssueService.method)); // listProjects, createProject, listIssues, …
```

- `@bufbuild/protobuf` es dependencia del paquete; importala directo en el
  consumidor (npm la deduplica).
- Llamar al servicio: Connect-ES v2 (`@connectrpc/connect` +
  `@connectrpc/connect-web` o `@connectrpc/connect-node`) usa `IssueService` tal
  cual: `createClient(IssueService, transport)`. Desde un navegador el servidor
  tiene que hablar Connect o gRPC-Web (gRPC puro no corre en browsers).
- TypeScript: `moduleResolution` `bundler`, `node16` o `nodenext` (el paquete
  usa `exports`).
