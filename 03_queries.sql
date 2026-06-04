-- ============================================================
-- PROYECTO INMOBILIARIO V2 - CONSULTAS ANALÍTICAS (VIEWS)
-- ============================================================

SET search_path TO inmobiliaria, public;

-- [CONSULTA 1] Catálogo público de anuncios activos (Consumido desde la VIEW)
SELECT 
    inmueble_id AS "Inmueble",
    referencia AS "Referencia",
    titulo AS "Titulo",
    precio AS "Precio",
    operacion AS "Operacion",
    tipo_propiedad AS "Tipo Propiedad",
    municipio AS "Municipio",
    provincia AS "Provincia"
FROM inmobiliaria.vw_catalogo_publico;


-- [CONSULTA 2] Auditoría de Seguridad: Usuarios y Roles Asignados (RBAC)
SELECT 
    u.id_usuario AS "ID Usuario",
    u.nombre AS "Nombre",
    u.email AS "Correo Electronico",
    r.codigo AS "Codigo de Rol"
FROM usuarios u
JOIN usuario_roles ur ON u.id_usuario = ur.fk_usuario
JOIN roles r ON ur.rol_id = r.id
ORDER BY u.id_usuario;


-- [CONSULTA 3] Matriz de Ocupación y Densidad Regional (Consumido desde la VIEW Analítica)
SELECT 
    municipio AS "Municipio",
    tipo_inmueble AS "Tipo de Inmueble",
    cantidad_total AS "Cantidad",
    superficie_acumulada_m2 || ' m2' AS "Superficie Total",
    TO_CHAR(precio_promedio, '999,999,999.00') || ' EUR' AS "Precio Promedio",
    densidad_euro_m2 || ' EUR/m2' AS "Densidad Media"
FROM inmobiliaria.vw_kpi_municipios
ORDER BY densidad_euro_m2 DESC;


-- [CONSULTA 4] Grafico Estadistico: Distribucion de Superficie (Formato Universal)
SELECT 
    referencia AS "Inmueble",
    operacion AS "Operacion",
    LEFT(titulo, 22) || '...' AS "Titulo Corto",
    precio || ' EUR' AS "Precio",
    '|' || REPEAT('=', CAST(superficie_m2 / 5 AS INTEGER)) || '>' AS "Proporcion de Tamano (m2)"
FROM propiedades p
WHERE deleted_at IS NULL
ORDER BY superficie_m2 DESC;