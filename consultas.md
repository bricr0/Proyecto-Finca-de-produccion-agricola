# 📊 Gestión Agrícola – SQL

## 🛠️ 20 Procedimientos Almacenados

1. **sp_ProcesarVenta**: Registra una venta y actualiza el inventario automáticamente.
2. **sp_RegistrarProveedor**: Inserta un nuevo proveedor validando que no exista.
3. **sp_RegistrarEmpleado**: Inserta un empleado y asigna su departamento.
4. **sp_ActualizarEstadoMaquinaria**: Cambia el estado de una máquina según informe de mantenimiento.
5. **sp_CalcularNomina**: Calcula la nómina de un empleado en un período dado, incluyendo horas extras.
6. **sp_AsignarActividad**: Asigna una tarea agrícola a un empleado libre.
7. **sp_GenerarReporteMensualProduccion**: Consolida la producción del mes en una tabla de informes.
8. **sp_GenerarReporteMensualVentas**: Consolide las ventas mensuales por producto.
9. **sp_ProgramarMantenimiento**: Agenda mantenimientos según horas de uso acumuladas.
10. **sp_ActualizarInventarioPorProduccion**: Suma la producción al stock disponible.
11. **sp_RegistrarCompraProveedor**: Registra compras y actualiza inventario de insumos.
12. **sp_TransferirStockEntreLotes**: Mueve cantidad de un lote a otro validando capacidad.
13. **sp_ActualizarCostoOperativo**: Reprocesa los costos de actividades en un rango de fechas.
14. **sp_RotarCultivosPorLote**: Programa rotación según calendario agrícola.
15. **sp_CalcularComisionEmpleado**: Calcula la comisión de ventas para un empleado.
16. **sp_GenerarOrdenCompraAutomatica**: Crea órdenes de compra al cruzar un umbral de stock.
17. **sp_ActualizarKPIProduccion**: Recalcula indicadores clave de producción.
18. **sp_EnviarNotificacionStockBajo**: Envía alerta vía correo a responsables.
19. **sp_RegistrarActividadAgricola**: Inserta una actividad y movimiento de inventario asociado.
20. **sp_OptimizarRiegoPorLote**: Calcula y programa riegos basado en datos históricos.

## 🔄 20 Triggers

1. **tr_Venta_UpdateInventario**: Reduce stock al insertar una venta.
2. **tr_AfterInsertProduccion_UpdateInventario**: Suma producción al stock.
3. **tr_BeforeInsertMaquinaria_ValidateEstado**: Impide registrar maquinaria duplicada.
4. **tr_AfterUpdateEmpleado_HistorialSalario**: Guarda cambios de salario en historial.
5. **tr_AfterInsertCompra_UpdateInventario**: Actualiza inventario al registrar compra.
6. **tr_BeforeInsertActividad_ValidateDisponibilidad**: Comprueba disponibilidad de empleado.
7. **tr_AfterInsertMantenimiento_UpdateMaquinaria**: Cambia el estado de la máquina.
8. **tr_AfterInsertProveedor_Log**: Guarda en tabla de auditoría.
9. **tr_BeforeDeleteProducto_PreventDeletionIfStock**: Impide borrar producto con stock > 0.
10. **tr_AfterUpdateProduccion_RecomputeKPI**: Recalcula KPI tras cambiar producción.
11. **tr_BeforeInsertVenta_ValidateCliente**: Verifica que el cliente exista y esté activo.
12. **tr_AfterUpdatePrecio_LogPrecio**: Registra cambios de precios en auditoría.
13. **tr_AfterInsertLote_CalculateTamañoRef**: Calcula y almacena referencia de tamaño.
14. **tr_BeforeUpdateLote_ValidateSuperficie**: Verifica que la superficie sea positiva.
15. **tr_AfterInsertCosecha_UpdateProduccionSummary**: Actualiza tabla resumen de cosechas.
16. **tr_AfterInsertEmpleado_AssignRole**: Asigna un rol por defecto al nuevo empleado.
17. **tr_BeforeInsertFactura_ValidateInventario**: Impide facturar si no hay stock suficiente.
18. **tr_AfterInsertEventoLog_ArchiveOld**: Archive logs anteriores a un año.
19. **tr_AfterInsertNotificacion_ScheduleReminder**: Programa recordatorio tras una notificación.
20. **tr_BeforeInsertTarea_ValidateEmpleadoAvailability**: Evita sobreasignar tareas.

## ⏰ 20 Eventos

1. **ev_BackupDiario**: Hace copia de seguridad cada noche a medianoche.
2. **ev_ReporteProduccionMensual**: Genera informe el primer día de cada mes.
3. **ev_ReporteVentasMensual**: Consolida ventas mensuales.
4. **ev_ActualizarPreciosMensual**: Revisa y ajusta precios el primer día de mes.
5. **ev_LimpiarLogsTrimestral**: Purga logs antiguos cada trimestre.
6. **ev_RecalcularKPI**: Actualiza indicadores cada domingo.
7. **ev_EnviarRecordatoriosTareasDiarias**: Notifica tareas pendientes cada mañana.
8. **ev_ActualizarInventarioNocturno**: Sincroniza inventario cada noche.
9. **ev_ProgramarMantenimientoSemanal**: Planifica mantenimientos cada lunes.
10. **ev_ActualizarPronosticosQuincenal**: Recalcula pronósticos de producción cada 15 días.
11. **ev_GenerarOrdenesCompraSemanal**: Genera compras semanales.
12. **ev_OptimizarIndicesSemanal**: Reorganiza índices de bases de datos.
13. **ev_EnviarAlertasStockBajoDiario**: Notifica stock bajo cada día.
14. **ev_GenerarReporteCostosMensual**: Consolida costos operativos.
15. **ev_ActualizarSalariosTrimestral**: Ajusta salarios por inflación.
16. **ev_RealizarCheckIntegridadMensual**: Verifica integridad referencial.
17. **ev_ArchivarDatosAnuales**: Mueve datos antiguos a tablas históricas.
18. **ev_ActualizarRegionClimaticaAnual**: Recalcula zonas climáticas por lote.
19. **ev_SincronizacionMovilDiario**: Envía datos a la app móvil.
20. **ev_ArchivadoLogOperacional**: Archive logs de operación cada noche.

## 📐 20 Funciones

1. **fn_CalcularRendimientoPorHectarea(lote_id)**: Devuelve kg/ha promedio.
2. **fn_CalcularCostoOperativo(periodo_inicio, periodo_fin)**: Devuelve costo total.
3. **fn_EdadMaquinaria(maquina_id)**: Devuelve la antigüedad en años.
4. **fn_EstimarProduccionFutura(cultivo_id, meses)**: Devuelve un pronóstico simple.
5. **fn_CalcularMargenBeneficio(producto_id)**: Devuelve el margen por venta.
6. **fn_TiempoEntreActividades(act1_id, act2_id)**: Calcula días de separación.
7. **fn_EficienciaEmpleado(empleado_id, periodo)**: Devuelve tareas completadas/hora.
8. **fn_DisponibilidadMaquinaria(maquina_id, periodo)**: Devuelve porcentaje de uso libre.
9. **fn_CostoActividad(tipo_actividad_id)**: Calcula costo promedio por tipo.
10. **fn_CantidadStockProducto(producto_id)**: Devuelve el stock actual disponible.
11. **fn_NivelReordenProducto(producto_id)**: Calcula el punto de reorden óptimo.
12. **fn_DepreciacionMaquinaria(maquina_id, fecha)**: Calcula depreciación acumulada.
13. **fn_RequerimientoAguaPorCultivo(cultivo_id, area)**: Devuelve litros necesarios.
14. **fn_ProyeccionVentasMensual(producto_id, meses)**: Devuelve ventas previstas.
15. **fn_IndiceSatisfaccionCliente(cliente_id)**: Calcula índice básico de satisfacción.
16. **fn_HuellaCarbonoActividad(actividad_id)**: Estima emisiones CO₂.
17. **fn_ROICultivo(cultivo_id, periodo)**: Calcula retorno de inversión.
18. **fn_RiesgoClimaticoPorMes(mes)**: Devuelve factor de riesgo (tabla auxiliar).
19. **fn_OptimalidadAsignacionRecursos(lote_id)**: Sugiere % uso óptimo.
20. **fn_PuntoEquilibrioProducto(producto_id)**: Calcula unidades para cubrir costos fijos.

## 📊 20 Consultas Avanzadas (joins, subconsultas, agregaciones y filtrados)

1. Producción total por producto en el mes actual usando una subconsulta para el mes.
2. Productos que no se han producido en los últimos 6 meses con una subconsulta NOT IN.
3. 5 lotes con mayor rendimiento anual calculado con SUM y GROUP BY.
4. Lote con mayor producción total utilizando una subconsulta correlacionada.
5. Ventas mensuales por producto y filtra aquellos con ventas superiores al promedio.
6. Clientes que han realizado más de 3 compras en el último año con HAVING.
7. Promedio de producción por tipo de cultivo usando JOIN con la tabla Cultivo.
8. Empleados cuya cantidad de tareas pendientes supere el promedio general con subconsulta.
9. Stock actual comparado con el stock promedio histórico usando JOIN y agregaciones.
10. Lotes cuyo costo operativo supera el promedio de todos los lotes con HAVING.
11. Promedio de horas de uso de cada tipo de maquinaria filtrando por tipo con JOIN.
12. Ranking de lotes por rendimiento usando funciones de ventana o subconsulta.
13. Combinaciones de productos frecuentemente vendidos juntos utilizando self-join.
14. Lotes con producción inferior al 70% de su potencial calculado con subconsulta.
15. Variación porcentual de la producción mes a mes con subconsulta de meses anteriores.
16. Proveedores cuyo volumen de compra supera su promedio histórico usando HAVING.
17. Maquinaria sobreutilizada comparando horas actuales vs. estándar del fabricante.
18. Producción y precio medio de cada producto filtrando por ingresos superiores a X.
19. Actividades agrícolas agrupadas por tipo y región con JOIN y GROUP BY.
20. 5 productos con mayor ingreso generado en el último año usando subconsulta y ORDER BY.