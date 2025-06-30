const express = require('express');
const app = express();
const ventasRoutes = require('./routes/ventasRoutes');

// Configuración básica
app.set('view engine', 'ejs');
app.use(express.static('public'));

// Rutas
app.use('/', ventasRoutes);

// Manejo de errores básico
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).send('Error interno del servidor');
});

// Iniciar servidor
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Servidor corriendo en http://localhost:${PORT}`);
    
});