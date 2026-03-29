# Consigna – Telegram Bot con LangChain y PostgreSQL

## Objetivo

Completar el proyecto de integración del Telegram Bot con LangChain y PostgreSQL, implementando funcionalidades y automatización en CI/CD.

## Trabajo en grupo

[Grupos de trabajo](https://docs.google.com/spreadsheets/d/1IlEFrw_zb-spPEUUTyUpMWOIcKqxP53kT0HsE4j-Dd8/edit?gid=0#gid=0)

## Instrucciones

1. **Fork y Entrega**  
   - Realizar un *fork* del proyecto disponible en GitLab: [telegram-bot-ia-talk-database-practica-01](https://gitlab.com/public-unrn/telegram-bot-ia-talk-database-practica-01).
   - Compartir el repositorio final con los cambios implementados.

2. **Tareas a Implementar**

   a. **Dockerfile**  
      - Completar la definición del contenedor para la aplicación.
      - Seleccionar una imagen que cumpla con los requisitos del proyecto y configurar las dependencias.
      - Asegurarse de que el comando CMD ejecute correctamente.

   b. **docker-compose.yaml**  
      - Definir y configurar los servicios necesarios:
         - Servicio de la aplicación (Telegram bot).
         - Servicio de la base de datos PostgreSQL.
      - Configurar correctamente las variables de entorno y las dependencias entre contenedores.

   c. **GitLab CI/CD (.gitlab-ci.yml)**  
      - Completar la configuración del pipeline de CI/CD:
         - Ejecutar tests utilizando `pytest`, generando reportes de cobertura (`coverage.xml`) y resultados en formato JUnit (`report.xml`).
         - Construir la imagen de Docker.
         - Realizar análisis de calidad y seguridad, integrando herramientas como SonarCloud y Trivy.
   
3. **Pruebas y Validación**  
   - Verificar que al levantar los contenedores con Docker Compose la aplicación se ejecute correctamente y se conecte a la base de datos.
   - Asegurarse de que el pipeline de CI/CD se complete sin errores y se generen los reportes correspondientes.

4. **Entrega Final**  
   - El repositorio _forkeado_ debe contener todos los cambios y configuraciones completos en cada uno de los puntos anteriores.
   - La entrega se considerará finalizada cuando se comparta el repositorio que permita revisar el proyecto implementado.

## Consideraciones

- Integrar correctamente los conocimientos Docker, Orquestación y CI/CD.
- Mantener una documentación clara y ordenada tanto en el código como en los archivos de configuración.
- Se evaluará tanto la integración técnica como la documentación.

¡Éxitos en la implementación!