-- ============================================================
-- PROYECTO INMOBILIARIO V2 - SCHEMA COMPLETO (REFACTORIZADO)
-- PostgreSQL 16+
-- ============================================================

DROP SCHEMA IF EXISTS inmobiliaria CASCADE;
CREATE SCHEMA inmobiliaria;
SET search_path TO inmobiliaria, public;

CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- ============================================================
-- DOMINIOS PARA IDs TIPADOS (Requisito Avanzado del Profesor)
-- ============================================================
CREATE DOMAIN inmobiliaria.ID_USUARIO AS CHAR(6) NOT NULL 
    CHECK (VALUE ~ '^U-\d{4}$');

CREATE DOMAIN inmobiliaria.ID_PROPIEDAD AS CHAR(6) NOT NULL 
    CHECK (VALUE ~ '^P-\d{4}$');

CREATE DOMAIN inmobiliaria.ID_MENSAJE AS CHAR(6) NOT NULL 
    CHECK (VALUE ~ '^M-\d{4}$');

-- ============================================================
-- 1. TIPOS ENUM
-- ============================================================
CREATE TYPE tipo_operacion_propiedad AS ENUM ('venta', 'alquiler', 'renta');
CREATE TYPE tipo_estado_propiedad AS ENUM ('borrador', 'pendiente', 'publicada', 'rechazada', 'inactiva', 'vendida', 'alquilada');
CREATE TYPE tipo_usuario_mensaje AS ENUM ('anonimo', 'cliente', 'agente');

-- ============================================================
-- 2. GEOGRAFÍA
-- ============================================================
CREATE TABLE paises (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_es VARCHAR(120) NOT NULL,
    iso2 CHAR(2) UNIQUE NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE comunidades_autonomas (
    id SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE provincias (
    id SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    comunidad_id SMALLINT NOT NULL REFERENCES comunidades_autonomas(id) ON DELETE RESTRICT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE municipios (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    provincia_id SMALLINT NOT NULL REFERENCES provincias(id) ON DELETE RESTRICT,
    nombre VARCHAR(150) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE codigos_postales (
    codigo CHAR(5) PRIMARY KEY,
    municipio_id INTEGER NOT NULL REFERENCES municipios(id) ON DELETE RESTRICT
);

-- ============================================================
-- 3. USUARIOS Y SEGURIDAD
-- ============================================================
CREATE TABLE usuarios (
    id_usuario inmobiliaria.ID_USUARIO PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellidos VARCHAR(150) NOT NULL,
    email TEXT NOT NULL,
    telefono VARCHAR(30),
    password_hash VARCHAR(255) NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    email_verificado BOOLEAN DEFAULT FALSE,
    created_at DATE NOT NULL DEFAULT CURRENT_DATE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX uq_usuario_email_ci ON usuarios (LOWER(email));

CREATE TABLE roles (
    id SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE usuario_roles (
    fk_usuario inmobiliaria.ID_USUARIO REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    rol_id SMALLINT REFERENCES roles(id) ON DELETE RESTRICT,
    fecha_asignacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (fk_usuario, rol_id)
);

-- ============================================================
-- 4. PROPIEDADES
-- ============================================================
CREATE TABLE tipos_propiedad (
    id SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE propiedades (
    id_propiedad inmobiliaria.ID_PROPIEDAD PRIMARY KEY,
    fk_usuario inmobiliaria.ID_USUARIO NOT NULL REFERENCES usuarios(id_usuario) ON DELETE RESTRICT,
    tipo_propiedad_id SMALLINT NOT NULL REFERENCES tipos_propiedad(id) ON DELETE RESTRICT,
    codigo_postal CHAR(5) REFERENCES codigos_postales(codigo) ON DELETE RESTRICT,
    referencia VARCHAR(80) UNIQUE NOT NULL,
    titulo VARCHAR(180) NOT NULL,
    descripcion TEXT,
    direccion_oculta VARCHAR(255),
    direccion_publica VARCHAR(255),
    operacion tipo_operacion_propiedad NOT NULL,
    precio NUMERIC(12, 2) NOT NULL CHECK (precio > 0),
    superficie_m2 NUMERIC(10, 2) NOT NULL CHECK (superficie_m2 > 0),
    habitaciones SMALLINT DEFAULT 0 CHECK (habitaciones >= 0),
    banos NUMERIC(4, 1) DEFAULT 1 CHECK (banos >= 0),
    estado tipo_estado_propiedad DEFAULT 'borrador',
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

-- ============================================================
-- 5. CARACTERÍSTICAS Y MULTIMEDIA
-- ============================================================
CREATE TABLE caracteristicas (
    id SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    categoria VARCHAR(50)
);

CREATE TABLE propiedad_caracteristicas (
    fk_propiedad inmobiliaria.ID_PROPIEDAD REFERENCES propiedades(id_propiedad) ON DELETE CASCADE,
    caracteristica_id SMALLINT REFERENCES caracteristicas(id) ON DELETE CASCADE,
    valor VARCHAR(100),
    PRIMARY KEY (fk_propiedad, caracteristica_id)
);

CREATE TABLE imagenes_propiedad (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fk_propiedad inmobiliaria.ID_PROPIEDAD NOT NULL REFERENCES propiedades(id_propiedad) ON DELETE CASCADE,
    url_imagen VARCHAR(255) NOT NULL,
    orden SMALLINT DEFAULT 0,
    es_principal BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 6. INTERACCIONES Y AUDITORÍA
-- ============================================================
CREATE TABLE favoritos (
    fk_usuario inmobiliaria.ID_USUARIO REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    fk_propiedad inmobiliaria.ID_PROPIEDAD REFERENCES propiedades(id_propiedad) ON DELETE CASCADE,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (fk_usuario, fk_propiedad)
);

-- Solución: Se usa CHAR(6) en lugar del dominio estricto NOT NULL para permitir NULL en anónimos
CREATE TABLE mensajes (
    id_mensaje inmobiliaria.ID_MENSAJE PRIMARY KEY,
    fk_propiedad inmobiliaria.ID_PROPIEDAD NOT NULL REFERENCES propiedades(id_propiedad) ON DELETE CASCADE,
    fk_remitente CHAR(6) REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
    tipo_remitente tipo_usuario_mensaje DEFAULT 'anonimo',
    nombre VARCHAR(150) NOT NULL,
    email VARCHAR(190) NOT NULL,
    telefono VARCHAR(50),
    mensaje TEXT NOT NULL,
    leido BOOLEAN DEFAULT FALSE,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_remitente_formato CHECK (fk_remitente IS NULL OR fk_remitente ~ '^U-\d{4}$')
);

CREATE TABLE propiedad_estado_historial (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fk_propiedad inmobiliaria.ID_PROPIEDAD NOT NULL REFERENCES propiedades(id_propiedad) ON DELETE CASCADE,
    estado_anterior tipo_estado_propiedad,
    estado_nuevo tipo_estado_propiedad NOT NULL,
    fk_usuario inmobiliaria.ID_USUARIO REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
    motivo TEXT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 7. RESTRICCIONES ADICIONALES E ÍNDICES
-- ============================================================
CREATE UNIQUE INDEX uq_usuario_propiedad_favorita ON favoritos (fk_usuario, fk_propiedad);
CREATE INDEX idx_propiedades_filtros ON propiedades (estado, operacion, precio) WHERE deleted_at IS NULL;
CREATE INDEX idx_propiedades_geo ON propiedades (codigo_postal);
CREATE INDEX idx_propiedades_trgm ON propiedades USING gin (titulo gin_trgm_ops);