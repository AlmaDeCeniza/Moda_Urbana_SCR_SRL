const ventasModel = require('../models/ventasModel');

module.exports = {
    //1
    ventasPorSucursalOCanal: (req, res) => {
        const { canal } = req.query; 
        ventasModel.ventasPorSucursalOCanal(canal, (err, resultados) => {
            if (err) return res.status(500).send(err.message);
            res.render('ventas/ventasPorSucursalOCanal', {
                data: resultados,
                canalSeleccionado: canal || 'Todos' 
            });
        });
    },

    //2 
    reporteEstadoPedidos: (req, res) => {
        const { estado } = req.query; 

        ventasModel.reporteEstadoPedidos(estado || null, (err, data) => {
            if (err) {
                console.error('Error en reporteEstadoPedidos:', err);
                return res.status(500).render('error', {
                    error: {
                        message: 'Error al obtener el reporte de pedidos',
                        details: err.message
                    }
                });
            }

            res.render('ventas/reportePedidos', {
                data,
                estadoSeleccionado: estado || 'Todos', 
                formatDate: (dateString) => new Date(dateString).toLocaleDateString('es-ES')
            });
        });
    },

    //3 
    ingresosPorCanal: (req, res) => {
        const canal = req.query.canal || null;
        const fechaInicio = req.query.fechaInicio || null;
        const fechaFin = req.query.fechaFin || null;

        ventasModel.ingresosPorCanal(canal, fechaInicio, fechaFin, (err, resultados) => {
            if (err) {
                console.error('Error en ingresosPorCanal:', err);
                return res.status(500).render('error', { error: err });
            }

            ventasModel.obtenerCanales((err, canales) => {
                if (err) canales = [];

                res.render('ventas/ingresosPorCanal', {
                    data: resultados,
                    canales: canales,
                    filtros: {
                        canalSeleccionado: canal,
                        fechaInicio: fechaInicio,
                        fechaFin: fechaFin
                    }
                });
            });
        });
    },


    //4
    ventasPorVendedor: (req, res) => {
        const vendedorId = req.query.vendedorId || null;
        ventasModel.ventasPorVendedor(vendedorId, (err, resultados) => {
            if (err) return res.status(500).send(err.message);

            
            ventasModel.obtenerVendedores((err, vendedores) => {
                if (err) vendedores = [];
                res.render('ventas/ventasPorVendedor', {
                    data: resultados,
                    vendedores: vendedores,
                    vendedorSeleccionado: vendedorId
                });
            });
        });
    },



    //5
    stockPorProducto: (req, res) => {
        const sucursalId = req.query.sucursalId || null;

        ventasModel.stockPorProducto(sucursalId, (err, resultados) => {
            if (err) return res.status(500).send(err.message);

            ventasModel.obtenerSucursales((err, sucursales) => {
                if (err) sucursales = [];

                res.render('ventas/stockPorProducto', {
                    data: resultados,
                    sucursales: sucursales,
                    sucursalSeleccionada: sucursalId
                });
            });
        });
    },

};