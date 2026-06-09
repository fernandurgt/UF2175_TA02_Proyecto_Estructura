const express = require('express');
const router = express.Router();
const { 
    getPropiedades, 
    getPropiedadById, 
    createPropiedad, 
    updatePropiedad, 
    deletePropiedad 
} = require('../controllers/propiedad');

// Definición de Endpoints del CRUD Completo
router.get('/', getPropiedades);          // Leer Catálogo (Filtros + Paginación)
router.get('/:id', getPropiedadById);     // Leer un Inmueble Específico
router.post('/', createPropiedad);        // Crear Inmueble
router.put('/:id', updatePropiedad);      // Modificar Inmueble
router.delete('/:id', deletePropiedad);   // Eliminar Inmueble (Lógico)

module.exports = router;