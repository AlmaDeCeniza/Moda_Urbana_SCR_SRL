const db = require('../config/db');
//1
module.exports = {
    ventasPorSucursalOCanal: (canal, callback) => {
        let query = 'CALL reporteVentasPorSucursalOCanal(?)'; 
        db.query(query, [canal || null], (err, result) => { 
            if (err) return callback(err);
            callback(null, result[0]); 
        });
    },

    //2 
    reporteEstadoPedidos: (estado, callback) => {
        let query = 'CALL reporteVentasPorEstado(?)';
        db.query(query, [estado || null], (err, result) => {
            if (err) return callback(err);
            callback(null, result[0]); 
        });
    },

    //  3 
    ingresosPorCanal: (canal, fechaInicio, fechaFin, callback) => {
        const query = 'CALL reporteIngresosPorCanal(?, ?, ?)';
        db.query(query, [canal, fechaInicio, fechaFin], (err, results) => {
            if (err) return callback(err);
            callback(null, results[0]);
        });
    },

    obtenerCanales: (callback) => {
        const query = 'SELECT DISTINCT Canal_Venta FROM pedido ORDER BY Canal_Venta';
        db.query(query, (err, results) => {
            if (err) return callback(err);
            callback(null, results.map(item => item.Canal_Venta));
        });
    },





    //4
    ventasPorVendedor: (vendedorId, callback) => {
        const query = 'CALL reporteVentasPorVendedor(?)';
        db.query(query, [vendedorId], (err, result) => {
            if (err) return callback(err);
            callback(null, result[0]);
        });
    },

    obtenerVendedores: (callback) => {
        const query = 'SELECT VendedorID, Nombre FROM vendedor ORDER BY Nombre';
        db.query(query, (err, result) => {
            if (err) return callback(err);
            callback(null, result);
        });
    },





    //5
    stockPorProducto: (sucursalId, callback) => {
        const query = 'CALL reporteStockPorSucursal(?)';
        db.query(query, [sucursalId], (err, result) => {
            if (err) return callback(err);
            callback(null, result[0]);
        });
    },

    obtenerSucursales: (callback) => {
        const query = 'SELECT SucursalID, Nombre FROM sucursal ORDER BY Nombre';
        db.query(query, (err, result) => {
            if (err) return callback(err);
            callback(null, result);
        });
    }

};

