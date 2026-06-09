const express = require('express');
const path = require('path'); 
require('dotenv').config();

const propiedadesRouter = require(path.join(__dirname, 'routes', 'propiedades'));

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware para el parseo de datos en formato JSON
app.use(express.json());

// Montaje de las rutas globales del ecosistema inmobiliario
app.use('/api/propiedades', propiedadesRouter);

// Ruta de diagnóstico del sistema (Health Check)
app.get('/health', (req, res) => {
    res.json({ status: 'online', timestamp: new Date() });
});

// Inicialización del servidor web express
app.listen(PORT, () => {
    console.log(`==================================================`);
    console.log(`🚀 API REST Inmobiliaria corriendo en el puerto ${PORT}`);
    console.log(`🔗 Enlace local: http://localhost:${PORT}/api/propiedades`);
    console.log(`==================================================`);
});