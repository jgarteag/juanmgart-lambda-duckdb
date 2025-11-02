# Guía de Contribución

¡Gracias por tu interés en contribuir a este proyecto! Este documento proporciona pautas para contribuir de manera efectiva.

## 🚀 Comenzando

### Prerequisitos

- Python 3.11+
- Git
- Terraform (para cambios en infraestructura)
- AWS CLI (para deployment)

### Configuración del Entorno de Desarrollo

1. Fork y clona el repositorio:
   ```bash
   git clone https://github.com/tu-usuario/juanmgart-lambda-duckdb.git
   cd juanmgart-lambda-duckdb
   ```

2. Crea un entorno virtual:
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # En Windows: venv\Scripts\activate
   ```

3. Instala las dependencias de desarrollo:
   ```bash
   make install-dev
   # o manualmente:
   pip install -r requirements.txt -r requirements-dev.txt
   ```

## 📝 Proceso de Contribución

### 1. Crear un Issue

Antes de comenzar a trabajar en una nueva característica o corrección:
- Busca si ya existe un issue relacionado
- Si no existe, crea uno nuevo describiendo tu propuesta
- Espera feedback antes de comenzar el trabajo

### 2. Crear una Branch

```bash
git checkout -b feature/nombre-descriptivo
# o
git checkout -b fix/nombre-del-bug
```

### 3. Desarrollo

#### Estándares de Código

- Sigue PEP 8 para código Python
- Usa type hints cuando sea posible
- Mantén las líneas de código bajo 100 caracteres
- Escribe docstrings para funciones y clases

#### Testing

- Escribe tests para toda nueva funcionalidad
- Asegúrate de que todos los tests pasen:
  ```bash
  make test
  ```

#### Linting y Formato

Antes de hacer commit, ejecuta:

```bash
# Formatear código
make format

# Verificar linting
make lint
```

### 4. Commit

Usa mensajes de commit descriptivos:

```bash
git commit -m "feat: agregar soporte para múltiples regiones AWS"
git commit -m "fix: corregir manejo de errores en consultas DuckDB"
git commit -m "docs: actualizar README con ejemplos de uso"
```

Convenciones de prefijos:
- `feat:` nueva funcionalidad
- `fix:` corrección de bugs
- `docs:` cambios en documentación
- `test:` agregar o modificar tests
- `refactor:` refactorización de código
- `chore:` tareas de mantenimiento

### 5. Push y Pull Request

```bash
git push origin feature/nombre-descriptivo
```

Luego crea un Pull Request en GitHub con:
- Título descriptivo
- Descripción detallada de los cambios
- Referencia al issue relacionado (#número)
- Screenshots si aplica

## 🧪 Testing

### Ejecutar Tests

```bash
# Todos los tests
make test

# Con cobertura
pytest tests/ -v --cov=src --cov-report=html
```

### Tests Manuales

```bash
# Probar Lambda localmente
make local-test
```

## 🏗️ Terraform

### Validar Configuración

```bash
make validate
```

### Formatear Archivos Terraform

```bash
cd terraform
terraform fmt -recursive
```

## 📚 Documentación

- Actualiza el README.md si agregas nuevas funcionalidades
- Documenta nuevas variables de Terraform en variables.tf
- Agrega ejemplos de uso cuando sea relevante

## ✅ Checklist antes de PR

- [ ] Los tests pasan (`make test`)
- [ ] El código pasa linting (`make lint`)
- [ ] El código está formateado (`make format`)
- [ ] Terraform está validado (`make validate`)
- [ ] La documentación está actualizada
- [ ] Los commits tienen mensajes descriptivos
- [ ] Se agregaron tests para nueva funcionalidad

## 🤝 Code Review

- Sé respetuoso y constructivo en los comentarios
- Responde a los comentarios de manera oportuna
- Haz los cambios solicitados o explica por qué no son necesarios

## 📞 Contacto

Si tienes preguntas, puedes:
- Abrir un issue
- Comentar en un PR existente
- Contactar al maintainer del proyecto

## 📄 Licencia

Al contribuir, aceptas que tus contribuciones se licenciarán bajo la misma licencia del proyecto.
