const pool = require('./db');
const { fakerES: faker } = require('@faker-js/faker'); // Generador optimizado en Español

/**
 * Función auxiliar para generar un ID tipado con el formato del dominio (P-XXXX)
 */
function generarIdPropiedad(numero) {
    return `P-${String(numero).padStart(4, '0')}`;
}

/**
 * Script Principal para el poblado masivo de la base de datos
 */
const poblarBaseDeDatos = async () => {
    console.log('⏳ Iniciando el proceso de poblado masivo en la base de datos...');
    
    try {
        // 1. Obtener IDs reales de usuarios y códigos postales existentes para mantener la integridad referencial
        const usuariosRes = await pool.query('SELECT id_usuario FROM inmobiliaria.usuarios');
        const cpRes = await pool.query('SELECT codigo FROM inmobiliaria.codigos_postales');
        const tiposRes = await pool.query('SELECT id FROM inmobiliaria.tipos_propiedad');

        const listaUsuarios = usuariosRes.rows.map(r => r.id_usuario);
        const listaCP = cpRes.rows.map(r => r.codigo);
        const listaTipos = tiposRes.rows.map(r => r.id);

        if (listaUsuarios.length === 0 || listaCP.length === 0) {
            throw new Error('Antes de correr este script debes ejecutar el archivo 02_seed.sql base.');
        }

        console.log(`🔗 Datos base detectados: ${listaUsuarios.length} Usuarios, ${listaCP.length} Códigos Postales.`);
        console.log('⚡ Insertando 2000 propiedades de forma aleatoria y consistente...');

        // Comenzamos desde el ID P-0005 ya que los primeros 4 pertenecen al seed original
        let contadorId = 5; 
        const operaciones = ['venta', 'alquiler', 'renta'];
        const estados = ['publicada', 'publicada', 'publicada', 'vendida', 'alquilada', 'inactiva']; // Sesgo hacia publicadas

        // Construcción de la mega-query utilizando transacciones para máxima velocidad
        await pool.query('BEGIN');

        for (let i = 0; i < 2000; i++) {
            const idPropiedad = generarIdPropiedad(contadorId);
            const fkUsuario = faker.helpers.arrayElement(listaUsuarios);
            const tipoPropiedadId = faker.helpers.arrayElement(listaTipos);
            const codigoPostal = faker.helpers.arrayElement(listaCP);
            const referencia = `REF-${String(contadorId).padStart(4, '0')}`;
            
            // Generación de textos realistas en español
            const tipoTexto = tipoPropiedadId === 1 ? 'Piso' : tipoPropiedadId === 2 ? 'Chalet' : 'Local';
            const titulo = `${tipoTexto} ${faker.word.adjective()} en zona residencial`;
            const descripcion = faker.lorem.paragraph(2);
            const direccion = `${faker.location.streetAddress()}, ${faker.location.city()}`;
            
            const operacion = faker.helpers.arrayElement(operaciones);
            
            // Valores numéricos lógicos basados en el tipo de operación
            const precio = operacion === 'venta' 
                ? faker.number.int({ min: 85000, max: 950000 }) 
                : faker.number.int({ min: 600, max: 4500 });
                
            const superficie = faker.number.int({ min: 35, max: 320 });
            const habitaciones = faker.number.int({ min: 0, max: 5 });
            const banos = faker.number.int({ min: 1, max: 3 });
            const estado = faker.helpers.arrayElement(estados);

            const queryText = `
                INSERT INTO inmobiliaria.propiedades (
                    id_propiedad, fk_usuario, tipo_propiedad_id, codigo_postal, 
                    referencia, titulo, descripcion, direccion_publica, 
                    operacion, precio, superficie_m2, habitaciones, banos, estado
                ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
                ON CONFLICT (referencia) DO NOTHING;
            `;

            const values = [
                idPropiedad, fkUsuario, tipoPropiedadId, codigoPostal, 
                referencia, titulo, descripcion, direccion, 
                operacion, precio, superficie, habitaciones, banos, estado
            ];

            await pool.query(queryText, values);
            contadorId++;
        }

        // Confirmar los cambios en el motor físico de la base de datos
        await pool.query('COMMIT');
        console.log('✅ ¡Éxito! Se han inyectado 2,000 registros simulados con integridad referencial.');

    } catch (error) {
        await pool.query('ROLLBACK'); // Cancelar todo en caso de error para evitar datos corruptos
        console.error('❌ Error crítico durante el poblado masivo:', error.message);
    } finally {
        // Cerrar el Pool de conexiones para que el script de Node termine de forma limpia
        await pool.end();
        console.log('🔌 Conexión con PostgreSQL cerrada de forma segura.');
    }
};

// Ejecución automática al llamar al archivo
poblarBaseDeDatos();