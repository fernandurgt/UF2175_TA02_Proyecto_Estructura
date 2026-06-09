# API REST Inmobiliaria - Backend de Alto Rendimiento

Backend transaccional y analítico desarrollado en **Node.js** y **Express**, acoplado a una base de datos relacional **PostgreSQL**. El sistema implementa un CRUD completo bajo buenas prácticas de desarrollo, controladores blindados contra fallos inyectados (`crash-safe`) y consultas dinámicas parametrizadas con protección nativa contra SQL Injection.

## 🚀 Características Principales

- **CRUD Completo de Propiedades:** Persistencia e interacción transaccional mediante endpoints RESTful (`GET`, `POST`, `PUT`, `DELETE`).
- **Borrado Lógico (Soft Delete):** Implementación de auditoría mediante la columna `deleted_at`, asegurando la integridad referencial y el histórico de métricas.
- **Filtros Analíticos Avanzados:** Búsqueda adaptativa mediante operadores de coincidencia parcial (`ILIKE`), segmentación por tipo de operación y límites de precio.
- **Paginación Dinámica Indexada:** Sistema de paginación robusto basado en cursores dinámicos (`LIMIT` y `OFFSET`) optimizado para grandes volúmenes de datos.
- **Poblado Masivo Automatizado (Stress Testing):** Script de inserción masiva capaz de inyectar miles de registros indexados para pruebas de rendimiento en el catálogo.

---

## 🛠️ Stack Tecnológico

- **Entorno de Ejecución:** Node.js (v24.x)
- **Framework Web:** Express.js
- **Motor de Base de Datos:** PostgreSQL
- **Controlador de Base de Datos:** `pg` (Pool de conexiones nativas)
- **Gestión de Entorno:** Dotenv

---

## 📂 Arquitectura del Proyecto

```text
api-inmob/
├── src/
│   ├── config/
│   │   ├── db.js             # Configuración del Pool de PostgreSQL
│   │   └── seederMasivo.js   # Script automatizado de carga de datos
│   ├── controllers/
│   │   └── propiedad.js      # Controladores lógicos del CRUD (Safe-Crash)
│   ├── routes/
│   │   └── propiedades.js    # Definición de endpoints y enrutamiento REST
│   └── app.js                # Inicialización y Middlewares de Express
├── .env                      # Variables de entorno (Gobernanza de credenciales)
└── package.json              # Gestión de dependencias y scripts de ejecución

```

## 🔧 Configuración y Ejecución
1. **Clonar el Repositorio:**
   ```bash
   git clone
   cd api-inmob
   ```
2. **Instalar Dependencias:**
   ```bash
   npm install
   ```
3. **Configurar Variables de Entorno:**
   - Crear un archivo `.env` en la raíz del proyecto con el siguiente contenido:
   ```env      
   PORT=3000
   DB_USER=postgres
   DB_PASSWORD=ajh_pass
   DB_HOST=localhost
   DB_PORT=5434
   DB_DATABASE=inmobiliaria_db
   ```
4. **Ejecutar el Servidor:**
   ```bash
   npm start
   ```            
5. **Poblar la Base de Datos (Opcional para Pruebas de Rendimiento):**
   ```bash
   node src/config/seederMasivo.js
   ```
## 📈 Pruebas de Rendimiento
- **Carga Masiva:** El script `seederMasivo.js` permite insertar miles de registros de propiedades con datos aleatorios, ideal para evaluar la escalabilidad y el rendimiento del sistema bajo condiciones de alta demanda.
- **Endpoints Analíticos:** Se recomienda realizar pruebas de carga utilizando herramientas como `Apache JMeter` o `Postman` para validar la eficiencia de los filtros analíticos y la paginación dinámica en escenarios de tráfico intenso.
---## 🛡️ Seguridad y Buenas Prácticas
- **Protección contra SQL Injection:** Todas las consultas a la base de datos utilizan parámetros parametrizados, garantizando la seguridad de las operaciones y la integridad de los datos.
- **Controladores Crash-Safe:** Implementación de manejo de errores robusto en los controladores, asegurando que el sistema no se caiga ante entradas maliciosas o fallos inesperados.
- **Borrado Lógico:** La estrategia de soft delete permite mantener un historial completo de las propiedades, facilitando auditorías y análisis históricos sin comprometer la integridad de los datos.
---## 📊 Métricas y Monitoreo
- **Auditoría de Operaciones:** Implementación de logs detallados para cada operación CRUD, permitiendo un seguimiento exhaustivo de las interacciones con el sistema.
- **Monitoreo de Rendimiento:** Se recomienda integrar herramientas de monitoreo como `New Relic` o `Datadog` para obtener insights en tiempo real sobre el rendimiento del backend y la base de datos, especialmente bajo cargas elevadas.
