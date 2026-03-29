# Consigna 2.1 – Despliegue en Kubernetes y CICD para el Telegram Bot

En esta consigna se debe implementar lo siguiente:

- Crear el namespace del grupo.
- Completar el Deployment, ConfigMap y Secret para el Telegram Bot y/o servicios relacionados.
- Utilizar Helm para instalar y configurar la base de datos PostgreSQL.
- Mediante port-forward se debe poder acceder a la base de datos y cargar los scripts de inicialización.
- Completar la tarea en CICD para que actualice la imagen en el Deployment desplegado en EKS.
---

Para disponer de una instancia de EKS de AWS usaremos el Labs de Academy

[aws-academy](https://gitlab.com/public-unrn/aws-academy/)

## 1. Crear el Namespace del Grupo

Primero, crea un namespace para aislar los recursos del proyecto. Puedes definir un archivo YAML como el siguiente (por ejemplo, `namespace.yaml`):

```yaml
# filepath: k8s/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: grupo00
```

Luego, aplica el namespace:
```bash
kubectl apply -f k8s/namespace.yaml
```

---

## 2. Instalar PostgreSQL con Helm

Utiliza un Helm Chart para desplegar PostgreSQL. Puedes usar el chart oficial de Bitnami o similar.


---

## 3. Configurar el Deployment, ConfigMap y Secret para el Telegram Bot

### a) Deployment YAML

Crea un archivo de Deployment para el Telegram Bot que apunte a la imagen construida. Ejemplo (`telegram-bot-deployment.yaml`):


### b) ConfigMap

Define un ConfigMap con variables de configuración no sensibles (ej. URL de la base de datos, parámetros de la aplicación):


### c) Secret

Crea un Secret que contenga información sensible como tokens o contraseñas. En el caso del helm chart de postgres el mismo crea un secret, en este caso solo es utilizar ese secret.


---

## 4. Acceder a la Base de Datos mediante Port Forward y Cargar Scripts

Para verificar la base y cargar manualmente scripts (si es necesario), puedes usar `kubectl port-forward`. Por ejemplo, para acceder al servicio de PostgreSQL:

```bash
kubectl port-forward svc/postgres-db-postgresql 5432:5432 -n grupo00
```

Con esto, desde tu máquina local podrás conectarte a PostgreSQL mediante la IP localhost y el puerto 5432. Luego, utiliza la herramienta de tu preferencia (plugin vscode) para cargar los scripts de inicialización.

- [schema](sql-init/01-sakila-schema.sql)
- [data](sql-init/02-sakila-data.sql)

---

## 5. Actualizar la Imagen mediante CICD en EKS

En el pipeline de GitLab CI (archivo `.gitlab-ci.yml`), agrega o completa un job de deploy que ejecute el siguiente comando para actualizar el deployment con la nueva imagen:

```bash
kubectl set image deployment/telegram-bot telegram-bot=$IMAGE -n grupo00 --record
```

Donde `$IMAGE` es la variable de entorno definida en tu pipeline (por ejemplo, obtenida tras el build). Este comando actualiza el contenedor del Deployment sin necesidad de especificar manualmente el nombre del pod.



*Asegúrate de haber configurado las credenciales de AWS y el kubeconfig apropiadamente (esto puede hacerse vía variables de entorno o mediante AWS CLI en el job).*

---

## Resumen de la Consigna 2.1

- **Kubernetes:**
  - Crear el namespace `grupo00`.
  - Desplegar PostgreSQL mediante Helm.
  - Configurar y aplicar Deployment, ConfigMap y Secret para el Telegram Bot.
  - Utilizar port-forward para acceder y, en caso de necesitarlo, cargar manualmente los scripts en la base.

- **CICD:**
  - Completar la tarea de deploy en el pipeline para actualizar la imagen del Deployment en EKS con `kubectl set image`.

¡Éxitos en la implementación y el despliegue!
````markdown

Esta guía te ayudará a integrar los conceptos de Kubernetes y CICD vistos en clase para desplegar la solución completa en EKS y asegurar la actualización continua de la imagen del Telegram Bot.

