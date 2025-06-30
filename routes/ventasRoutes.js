const express = require('express');
const router = express.Router();
const ventasController = require('../controllers/ventasController');



// 1
router.get('/ventas/ventasss', ventasController.ventasPorSucursalOCanal);
//2
router.get('/ventas/estado', ventasController.reporteEstadoPedidos);
//3 
router.get('/ventas/ingresos-canal', ventasController.ingresosPorCanal);
//4
router.get('/ventas/vendedor', ventasController.ventasPorVendedor);
//5
router.get('/ventas/stock-producto', ventasController.stockPorProducto);






module.exports = router;