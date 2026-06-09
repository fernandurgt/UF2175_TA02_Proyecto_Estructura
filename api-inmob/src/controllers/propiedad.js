const pool = require('../config/db');

/**
 * [GET] Obtener catálogo de propiedades con filtros analíticos y paginación
 */
const getPropiedades = async (req, res) => {
    try {
        // Extraer parámetros de la URL Query String
        let { page = 1, limit = 10, search, operacion, precio_max } = req.query;
        
        // Conversión segura de tipos para la paginación
        page = parseInt(page);
        limit = parseInt(limit);
        const offset = (page - 1) * limit;

        // Construcción de la consulta base blindada contra SQL Injection
        let queryText = `
            SELECT id_propiedad, referencia, titulo, precio, operacion, superficie_m2 
            FROM inmobiliaria.propiedades 
            WHERE deleted_at IS NULL
        `;
        const queryParams = [];
        let placeholderCounter = 1;

        // Filtro por búsqueda de texto adaptativa (ILIKE %search%)
        if (search) {
            queryText += ` AND titulo ILIKE $${placeholderCounter}`;
            queryParams.push(`%${search}%`);
            placeholderCounter++;
        }

        // Filtro por tipo de operación (venta, alquiler, renta)
        if (operacion) {
            queryText += ` AND operacion = $${placeholderCounter}`;
            queryParams.push(operacion);
            placeholderCounter++;
        }

        // Filtro por límite de precio máximo
        if (precio_max) {
            queryText += ` AND precio <= $${placeholderCounter}`;
            queryParams.push(parseFloat(precio_max));
            placeholderCounter++;
        }

        // --- ASIGNACIÓN DE PLACEHOLDERS DINÁMICOS PARA LIMIT Y OFFSET ---
        const limitPlaceholder = placeholderCounter++;
        queryParams.push(limit);

        const offsetPlaceholder = placeholderCounter++;
        queryParams.push(offset);

        // Inyección limpia y matemática de la ordenación y límites en la Query
        queryText += ` ORDER BY created_at DESC LIMIT $${limitPlaceholder} OFFSET $${offsetPlaceholder}`;

        // Ejecución de la consulta parametrizada
        const { rows } = await pool.query(queryText, queryParams);

        // Consulta auxiliar para calcular los metadados totales de paginación
        const totalRowsRes = await pool.query('SELECT COUNT(*) FROM inmobiliaria.propiedades WHERE deleted_at IS NULL');
        const totalRecords = parseInt(totalRowsRes.rows[0].count);

        // Respuesta estructurada con formato de producción corporativo
        return res.json({
            meta: {
                total_registros: totalRecords,
                pagina_actual: page,
                limite_por_pagina: limit,
                total_paginas: Math.ceil(totalRecords / limit)
            },
            data: rows
        });

    } catch (error) {
        console.error('❌ Error en el controlador getPropiedades:', error);
        return res.status(500).json({ error: 'Error interno en el servidor de datos.' });
    }
};

/**
 * [GET :ID] Buscar una propiedad específica por su ID de dominio tipado (P-XXXX)
 */
const getPropiedadById = async (req, res) => {
    try {
        const { id } = req.params;
        const queryText = 'SELECT * FROM inmobiliaria.propiedades WHERE id_propiedad = $1 AND deleted_at IS NULL';
        const { rows } = await pool.query(queryText, [id]);

        if (rows.length === 0) {
            return res.status(404).json({ error: 'Propiedad no encontrada o inactiva.' });
        }

        return res.json({ data: rows[0] });
    } catch (error) {
        console.error('❌ Error en el controlador getPropiedadById:', error);
        return res.status(500).json({ error: 'Error al procesar la solicitud identificada.' });
    }
};

/**
 * [POST] Crear una nueva propiedad (Create)
 */
const createPropiedad = async (req, res) => {
    try {
        const { 
            id_propiedad, fk_usuario, tipo_propiedad_id, codigo_postal, 
            referencia, titulo, descripcion, direccion_publica, 
            operacion, precio, superficie_m2, habitaciones, banos 
        } = req.body;

        // Validación básica de campos obligatorios
        if (!id_propiedad || !referencia || !titulo || !precio || !operacion) {
            return res.status(400).json({ error: 'Faltan campos obligatorios para registrar el inmueble.' });
        }

        const queryText = `
            INSERT INTO inmobiliaria.propiedades (
                id_propiedad, fk_usuario, tipo_propiedad_id, codigo_postal, 
                referencia, titulo, descripcion, direccion_publica, 
                operacion, precio, superficie_m2, habitaciones, banos, estado
            ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, 'publicada')
            RETURNING id_propiedad, referencia, titulo, created_at;
        `;

        const values = [
            id_propiedad, fk_usuario, tipo_propiedad_id, codigo_postal, 
            referencia, titulo, descripcion, direccion_publica, 
            operacion, parseFloat(precio), parseInt(superficie_m2), parseInt(habitaciones), parseInt(banos)
        ];

        const { rows } = await pool.query(queryText, values);
        return res.status(201).json({ mensaje: 'Propiedad registrada con éxito.', data: rows[0] });

    } catch (error) {
        console.error('❌ Error en el controlador createPropiedad:', error);
        if (error.code === '23505') { // Código de error de clave duplicada en PostgreSQL
            return res.status(400).json({ error: 'El ID de propiedad o la referencia ya existen en el sistema.' });
        }
        return res.status(500).json({ error: 'Error interno al insertar el inmueble.' });
    }
};

/**
 * [PUT] Actualizar los datos de una propiedad existente (Update)
 */
const updatePropiedad = async (req, res) => {
    try {
        const { id } = req.params;

        // --- BLINDAJE ANTICRASH ---
        // Si req.body no existe (undefined), lo asignamos como un objeto vacío para evitar que falle la deconstrucción
        const body = req.body || {};
        
        const { titulo, descripcion, precio, operacion, estado, superficie_m2 } = body;

        // Normalización: Evaluamos de forma segura cada propiedad extraída
        const queryParams = [
            titulo !== undefined ? titulo : null,
            descripcion !== undefined ? descripcion : null,
            precio !== undefined && precio !== null ? parseFloat(precio) : null,
            operacion !== undefined ? operacion : null,
            estado !== undefined ? estado : null,
            superficie_m2 !== undefined && superficie_m2 !== null ? parseInt(superficie_m2) : null,
            id // El ID mapea con el último placeholder ($7)
        ];

        const queryText = `
            UPDATE inmobiliaria.propiedades 
            SET titulo = COALESCE($1, titulo),
                descripcion = COALESCE($2, descripcion),
                precio = COALESCE($3, precio),
                operacion = COALESCE($4, operacion),
                estado = COALESCE($5, estado),
                superficie_m2 = COALESCE($6, superficie_m2),
                updated_at = NOW()
            WHERE id_propiedad = $7 AND deleted_at IS NULL
            RETURNING id_propiedad, titulo, precio, estado;
        `;

        const { rows } = await pool.query(queryText, queryParams);

        if (rows.length === 0) {
            return res.status(404).json({ error: 'Propiedad no encontrada o inactiva para actualizar.' });
        }

        return res.json({ mensaje: 'Propiedad actualizada correctamente.', data: rows[0] });

    } catch (error) {
        // Registro analítico del fallo en la consola del servidor
        console.error('❌ Error crítico en updatePropiedad:', error.message);
        return res.status(500).json({ error: 'Error al actualizar los datos del inmueble.' });
    }
};

/**
 * [DELETE] Borrado lógico de una propiedad (Delete)
 */
const deletePropiedad = async (req, res) => {
    try {
        const { id } = req.params;

        // Marcamos el registro con la fecha actual en deleted_at en lugar de destruirlo físicamente
        const queryText = `
            UPDATE inmobiliaria.propiedades 
            SET deleted_at = NOW(), estado = 'inactiva' 
            WHERE id_propiedad = $1 AND deleted_at IS NULL
            RETURNING id_propiedad, referencia, titulo;
        `;

        const { rows } = await pool.query(queryText, [id]);

        if (rows.length === 0) {
            return res.status(404).json({ error: 'La propiedad ya ha sido eliminada o no existe.' });
        }

        return res.json({ mensaje: 'Propiedad dada de baja del catálogo correctamente (Borrado Lógico).', data: rows[0] });

    } catch (error) {
        console.error('❌ Error en el controlador deletePropiedad:', error);
        return res.status(500).json({ error: 'Error al ejecutar la baja lógica del inmueble.' });
    }
};

// Exportar todas las capacidades del módulo CRUD unificado
module.exports = {
    getPropiedades,
    getPropiedadById,
    createPropiedad,
    updatePropiedad,
    deletePropiedad
};