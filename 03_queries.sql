-- ============================================================
-- PROYECTO INMOBILIARIO V2 - CONSULTAS ANALITICAS
-- ============================================================

SET search_path TO inmobiliaria, public;

-- [CONSULTA 1] Relacion de anuncios activos
SELECT 
    p.id_propiedad AS "Inmueble",
    p.referencia AS "Referencia",
    p.titulo AS "Titulo",
    p.precio AS "Precio",
    p.operacion AS "Operacion",
    tp.nombre AS "Tipo de Propiedad",
    m.nombre AS "Municipio",
    prov.nombre AS "Provincia"
FROM propiedades p
JOIN tipos_propiedad tp ON p.tipo_propiedad_id = tp.id
JOIN codigos_postales cp ON p.codigo_postal = cp.codigo
JOIN municipios m ON cp.municipio_id = m.id
JOIN provincias prov ON m.provincia_id = prov.id
WHERE p.estado = 'publicada' AND p.activo = TRUE;

-- [CONSULTA 2] Usuarios y Roles (RBAC)
SELECT 
    u.id_usuario AS "ID Usuario",
    u.nombre AS "Nombre",
    u.email AS "Correo Electronico",
    r.codigo AS "Codigo de Rol"
FROM usuarios u
JOIN usuario_roles ur ON u.id_usuario = ur.fk_usuario
JOIN roles r ON ur.rol_id = r.id
ORDER BY u.id_usuario;

-- [CONSULTA 3] Matriz de Ocupacion por Municipio
SELECT 
    m.nombre AS "Municipio",
    tp.nombre AS "Tipo de Inmueble",
    COUNT(p.id_propiedad) AS "Cantidad",
    SUM(p.superficie_m2) || ' m2' AS "Superficie Total",
    TO_CHAR(AVG(p.precio), '999,999,999.00') || ' EUR' AS "Precio Promedio",
    ROUND(AVG(p.precio / p.superficie_m2), 2) || ' EUR/m2' AS "Densidad Media"
FROM propiedades p
JOIN tipos_propiedad tp ON p.tipo_propiedad_id = tp.id
JOIN codigos_postales cp ON p.codigo_postal = cp.codigo
JOIN municipios m ON cp.municipio_id = m.id
WHERE p.deleted_at IS NULL
GROUP BY m.nombre, tp.nombre
ORDER BY "Densidad Media" DESC;

-- [CONSULTA 4] Grafico de Barras ASCII
SELECT 
    referencia AS "Inmueble",
    operacion AS "Operacion",
    LEFT(titulo, 25) || '...' AS "Titulo Corto",
    precio || ' EUR' AS "Precio",
    RPAD('■', CAST(superficie_m2 / 5 AS INTEGER), '■') AS "Proporcion de Tamano (m2)"
FROM propiedades p
WHERE deleted_at IS NULL
ORDER BY superficie_m2 DESC;