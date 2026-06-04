-- ============================================================
-- PROYECTO INMOBILIARIO V2 - CARGA DE DATOS (SEED)
-- PostgreSQL 16+
-- ============================================================

SET search_path TO inmobiliaria, public;

-- 1. INSERCIÓN DE ROLES
INSERT INTO roles (codigo, nombre) VALUES
('ADMIN', 'Administrador del Sistema'),
('AGENTE', 'Agente Inmobiliario'),
('CLIENTE', 'Cliente / Propietario');

-- 2. INSERCIÓN DE GEOGRAFÍA BASE
INSERT INTO paises (nombre_es, iso2) VALUES ('España', 'ES');

INSERT INTO comunidades_autonomas (nombre) VALUES 
('Cataluña'), 
('Comunidad de Madrid'),
('Andalucía');

INSERT INTO provincias (comunidad_id, nombre) VALUES 
(1, 'Barcelona'),
(2, 'Madrid'),
(3, 'Sevilla');

INSERT INTO municipios (provincia_id, nombre) VALUES 
(1, 'Barcelona'),
(1, 'L''Hospitalet de Llobregat'),
(2, 'Madrid'),
(3, 'Sevilla');

INSERT INTO codigos_postales (codigo, municipio_id) VALUES 
('08001', 1), -- El Raval, Barcelona
('08003', 1), -- Barceloneta, Barcelona
('28001', 3), -- Recoletos, Madrid
('41001', 4); -- Centro, Sevilla

-- 3. INSERCIÓN DE USUARIOS
INSERT INTO usuarios (id_usuario, nombre, apellidos, email, telefono, password_hash, email_verificado, created_at) VALUES
('U-0001', 'Carlos', 'Martínez', 'carlos.admin@inmob.es', '+34600111222', '$2b$10$rX.mYh...', true, '2026-01-15'),
('U-0002', 'Laura', 'Gómez', 'laura.agente@inmob.es', '+34600333444', '$2b$10$rX.mYh...', true, '2026-02-10'),
('U-0003', 'Juan', 'Pérez', 'juan.cliente@gmail.com', '+34600555666', '$2b$10$rX.mYh...', true, '2026-03-01'),
('U-0004', 'Ana', 'López', 'ana.lopez@outlook.com', '+34600777888', '$2b$10$rX.mYh...', false, '2026-04-12'),
('U-0005', 'Diego', 'Santos', 'diego.santos@uni.com', '+34600999000', '$2b$10$rX.mYh...', true, '2026-05-20');

-- ASIGNACIÓN DE ROLES (RBAC)
INSERT INTO usuario_roles (fk_usuario, rol_id) VALUES 
('U-0001', 1), 
('U-0002', 2), 
('U-0003', 3), 
('U-0004', 3), 
('U-0005', 2); 

-- 4. INSERCIÓN DE TIPOS DE PROPIEDAD
INSERT INTO tipos_propiedad (codigo, nombre) VALUES
('PISO', 'Piso / Apartamento'),
('CASA', 'Casa / Chalet'),
('LOCAL', 'Local Comercial');

-- 5. INSERCIÓN DE CARACTERÍSTICAS
INSERT INTO caracteristicas (nombre, categoria) VALUES
('Ascensor', 'comunidad'),
('Terraza', 'exterior'),
('Aire Acondicionado', 'interior'),
('Calefacción Central', 'interior'),
('Piscina', 'comunidad');

-- 6. INSERCIÓN DE PROPIEDADES (Resolución nativa de tipos sin sentencias UPDATE intermedias)
INSERT INTO propiedades (id_propiedad, fk_usuario, tipo_propiedad_id, codigo_postal, referencia, titulo, descripcion, direccion_publica, operacion, precio, superficie_m2, habitaciones, banos, estado) VALUES
('P-0001', 'U-0003', (SELECT id FROM tipos_propiedad WHERE codigo = 'PISO'), '08003', 'REF-0001', 'Piso luminoso en la Barceloneta', 'Espectacular piso reformado a pocos metros de la playa.', 'Passeig Marítim, Barcelona', 'alquiler', 1350.00, 65.00, 2, 1, 'publicada'),
('P-0002', 'U-0002', (SELECT id FROM tipos_propiedad WHERE codigo = 'CASA'), '28001', 'REF-0002', 'Chalet exclusivo en Recoletos', 'Propiedad de lujo con calidades premium en el centro de Madrid.', 'Calle Serrano, Madrid', 'venta', 1250000.00, 240.00, 4, 3, 'publicada'),
('P-0003', 'U-0004', (SELECT id FROM tipos_propiedad WHERE codigo = 'PISO'), '08001', 'REF-0003', 'Estudio moderno en El Raval', 'Ideal para estudiantes o parejas. Completamente amueblado.', 'Carrer de la Cera, Barcelona', 'alquiler', 950.00, 45.00, 1, 1, 'publicada'),
('P-0004', 'U-0003', (SELECT id FROM tipos_propiedad WHERE codigo = 'LOCAL'), '41001', 'REF-0004', 'Local comercial en Centro de Sevilla', 'Gran visibilidad peatonal, salida de humos instalada.', 'Calle Sierpes, Sevilla', 'renta', 3200.00, 120.00, 0, 2, 'publicada');

-- 7. INSERCIÓN DE INTERACCIONES (MENSAJES)
INSERT INTO mensajes (id_mensaje, fk_propiedad, fk_remitente, tipo_remitente, nombre, email, telefono, mensaje) VALUES
('M-0001', 'P-0001', 'U-0004', 'cliente', 'Ana López', 'ana.lopez@outlook.com', '+34600777888', 'Estoy muy interesada en visitar el piso de la Barceloneta esta semana.');

INSERT INTO mensajes (id_mensaje, fk_propiedad, fk_remitente, tipo_remitente, nombre, email, telefono, mensaje) VALUES
('M-0002', 'P-0003', NULL, 'anonimo', 'Interesado Anónimo', 'contacto.anonimo@yahoo.com', NULL, '¿El precio del estudio incluye los gastos de comunidad?');