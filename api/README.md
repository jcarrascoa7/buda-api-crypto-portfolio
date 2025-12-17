# Buda API — Valuación de un portafolio cripto

Este repositorio contiene una **REST API** que se integra con la **API pública de Buda.com** para **valorizar un portafolio de criptomonedas** en una moneda fiat local.

La idea es que un cliente pueda enviar un portafolio y consultar cuánto vale según el valor de las criptomonedas en tiempo real en una moneda fiat, utilizando precios obtenidos desde la API pública de Buda.

---

## Objetivo

La API expone un endpoint que:

1. Recibe un portafolio en formato JSON (criptomonedas y cantidades) y una moneda fiat de referencia.
2. Retorna el valor total del portafolio expresado en la moneda solicitada.
3. Utiliza precios de mercado actuales obtenidos en tiempo real desde la API pública de Buda

---

## Stack utilizado

- **Ruby**: 3.3.10
- **Rails**: API-only (Rails 8.x)
- **HTTP Client**: Faraday
- **Tests**: RSpec
- **API Docs**: rswag (Swagger UI / OpenAPI)
- **Lint/Style**: RuboCop (config “omakase” de Rails)

---

## Estructura del repositorio

- `./api`: contiene la aplicación (código, rutas, specs, swagger, etc.)
- Root del repo: documentación general

> Importante: los comandos de Rails/RSpec se ejecutan desde `./api`.

---

## Cómo ejecutar el proyecto

### Opción A — Desde el root con `make`

> Requiere tener `make` disponible.

Crea (o usa) un `Makefile` en el root con targets típicos:

- Instalar dependencias:

  ```bash
  make setup
  ```

- Ejecutar tests:

  ```bash
  make test
  ```

- Generar documentación con Swagger:

  ```bash
  make swagger
  ```

- Iniciar servidor:

  ```bash
  make server
  ```

- Lintear código:

  ```bash
  make lint
  ```

---

### Opción B — Directamente en la carpeta `./api`

- Instalar dependencias:

  ```bash
  bundle install
  ```

- Ejecutar tests:

  ```bash
  bundle exec rspec
  ```

- Generar documentación con Swagger:

  ```bash
  bundle exec rake rswag:specs:swaggerize
  ```

- Iniciar servidor:

  ```bash
  bundle exec rails server
  ```

- Lintear código:

  ```bash
  bundle exec rubocop
  ```

---

## Documentación

Con el servidor levantado, la documentación con Swagger queda disponible en:

- `http://localhost:3000/api-docs`

El archivo OpenAPI se actualiza ejecutando:

```bash
make swagger
```

o directamente en la carpeta `./api`:

```bash
bundle exec rake rswag:specs:swaggerize
```

