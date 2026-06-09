const { Pool } = require('pg');
require('dotenv').config();

// Configuración del Pool de conexiones a PostgreSQL
const pool = new Pool({
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    database: process.env.DB_DATABASE
});

// Verificación inicial de la conexión
pool.query('SELECT NOW()', (err, res) => {
    if (err) {
        console.error('❌ Error al conectar a PostgreSQL:', err.message);
    } else {
        console.log('🚀 Conexión con PostgreSQL establecida correctamente vía Pool.');
    }
});

module.exports = pool;