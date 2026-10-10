## Qué cambia

<!-- Una o dos líneas. El título va con el issue: feat(issue-<n>): … (chore(deps) sin issue). -->

Issue: issue-N  <!-- carpeta contenido/issues/N-…/ del repo de docs; obligatorio salvo chore(deps) -->

## Cómo se probó

- [ ] `make lint` y `make breaking` en verde
- [ ] `make generate` corrido y `gen/` commiteado en este mismo PR

## Checklist de contratos

- [ ] Solo cambios aditivos en el paquete vN (o paquete v(N+1) nuevo si es incompatible)
- [ ] Ningún campo borrado de un vN publicado (`[deprecated = true]`); ningún número reusado ni renumerado
- [ ] Enums nuevos con `<ENUM>_UNSPECIFIED = 0`; `optional` donde importa la presencia

## Consumidores

<!-- Servicios / gateway / front que adoptan este cambio y en qué orden
     (protos → servicio → gateway → front). Links a sus MRs. -->

## Checklist

- [ ] Sin secretos ni datos personales en el diff (gitleaks corre en el CI igual)
- [ ] Migraciones: tienen `down` / no aplica
- [ ] Docs del repo actualizadas (README, `docs/`, CLAUDE.md) / no aplica
- [ ] Ficha o ADR en el repo de docs actualizados / no aplica

## Notas para el review

<!-- Decisiones, deuda que queda, PR relacionados en otros repos. -->
