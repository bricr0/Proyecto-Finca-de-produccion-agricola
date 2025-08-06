# Ejercicios SQL para Gestión Agrícola

## 20 Consultas Avanzadas con JOINs, Subconsultas, Agrupaciones y Filtrados

1. **Producción por tipo de cultivo y lote**: Mostrar la producción total agrupada por tipo de producto y lote, solo para lotes con tamaño mayor a 10 hectáreas.

2. **Ventas por cliente y producto**: Listar el total de ventas por cliente y tipo de producto, filtrando solo clientes con más de 3 compras en el último año.

3. **Eficiencia de maquinaria**: Calcular horas promedio de uso por tipo de maquinaria, comparando con el estándar del fabricante.

4. **Actividades pendientes por empleado**: Mostrar cantidad de tareas pendientes asignadas a cada empleado, con filtro por departamento.

5. **Rendimiento por hectárea**: Calcular el rendimiento (kg/ha) para cada lote y cultivo, mostrando solo los que superan el promedio.

6. **Rotación de inventario**: Determinar la relación entre ventas e inventario promedio para cada producto.

7. **Clientes frecuentes**: Identificar clientes con compras mensuales consistentes (más de 3 meses consecutivos).

8. **Mantenimientos vencidos**: Listar maquinaria con mantenimiento pendiente según horas de uso acumuladas.

9. **Productos estacionales**: Mostrar productos con variación estacional en ventas mayor al 30%.

10. **Empleados multifuncionales**: Identificar empleados que han participado en más de 3 tipos diferentes de actividades.

11. **Lotes subutilizados**: Detectar lotes con producción por debajo del 70% de su potencial según tipo de cultivo.

12. **Proveedores estratégicos**: Listar proveedores que suministran más de 3 tipos de insumos críticos.

13. **Correlación clima-producción**: Analizar relación entre producción y condiciones climáticas históricas.

14. **Costos operativos por lote**: Calcular costos totales (mano de obra + insumos) por lote y tipo de cultivo.

15. **Ventas cruzadas**: Identificar combinaciones de productos frecuentemente vendidos juntos.

16. **Eficiencia de riego**: Comparar consumo de agua con producción obtenida por tipo de cultivo.

17. **Tendencias de precios**: Mostrar evolución de precios de venta por producto en los últimos 12 meses.

18. **Ciclo de vida de productos**: Calcular tiempo promedio desde producción hasta venta por tipo de producto.

19. **Impacto de actividades**: Relacionar tipos de actividades agrícolas con rendimiento en producción.

20. **Optimización de recursos**: Identificar solapamientos en uso de maquinaria y personal.

## 20 Procedimientos Almacenados

1. `sp_RegistrarVenta`: Procesa una nueva venta, actualizando inventarios y registrando transacciones.

2. `sp_ActualizarInventario`: Ajusta niveles de inventario basado en producciones y ventas.

3. `sp_ProgramarMantenimiento`: Agenda mantenimientos preventivos según horas de uso.

4. `sp_AsignarTarea`: Asigna tareas a empleados validando disponibilidad.

5. `sp_CalcularNomina`: Genera nómina con cálculos de horas extras y bonificaciones.

6. `sp_GenerarOrdenCompra`: Crea órdenes de compra automáticas al bajar inventarios.

7. `sp_RotarCultivos`: Programa rotación de cultivos según calendario agrícola.

8. `sp_ActualizarPrecios`: Ajusta precios basado en costos y márgenes definidos.

9. `sp_ProcesarProduccion`: Registra nueva producción y actualiza KPI.

10. `sp_AlertasInventario`: Genera alertas por niveles mínimos/máximos de inventario.

11. `sp_OptimizarRiego`: Calcula programa óptimo de riego por lote.

12. `sp_AsignarMaquinaria`: Asigna equipos a actividades validando disponibilidad.

13. `sp_CalcularComisiones`: Determina comisiones por ventas para empleados.

14. `sp_GenerarReporteProduccion`: Crea reporte consolidado de producción.

15. `sp_ActualizarCostos`: Recalcula costos operativos basado en actividades.

16. `sp_ProgramarSiembras**: Programa fechas de siembra óptimas por lote.

17. `sp_ProcesarCompra`: Registra compras a proveedores y actualiza inventarios.

18. `sp_AnalizarRendimiento`: Evalúa rendimiento por lote y genera recomendaciones.

19. `sp_GenerarFacturas`: Automatiza generación de facturas por periodo.

20. `sp_ActualizarKPI`: Recalcula indicadores clave de desempeño.

## 20 Funciones SQL

1. `fn_CalcularRendimiento`: Devuelve rendimiento en kg/ha para un lote y periodo.

2. `fn_CalcularCostoOperativo`: Calcula costos por lote en un rango de fechas.

3. `fn_EdadMaquinaria`: Determina antigüedad de equipos en años/meses.

4. `fn_EstimarProduccion`: Predice producción basada en condiciones actuales.

5. `fn_CalcularMargen`: Devuelve margen de beneficio por producto.

6. `fn_TiempoEntreActividades`: Calcula tiempo promedio entre actividades relacionadas.

7. `fn_ProductividadEmpleado`: Evalúa eficiencia de un empleado en tareas.

8. `fn_DisponibilidadMaquinaria`: Calcula porcentaje de disponibilidad de equipos.

9. `fn_CostoActividad`: Determina costo total por tipo de actividad.

10. `fn_RequerimientoManoObra`: Estima horas-hombre necesarias para actividad.

11. `fn_ProyeccionVentas`: Predice ventas basado en tendencias históricas.

12. `fn_PuntoReorden`: Calcula nivel óptimo para reordenar inventario.

13. `fn_DepreciacionMaquinaria`: Determina depreciación acumulada de equipos.

14. `fn_RequerimientoAgua`: Calcula necesidades hídricas por tipo de cultivo.

15. `fn_SatisfaccionCliente`: Evalúa índice de satisfacción por compras recurrentes.

16. `fn_EficienciaInsumos`: Calcula relación insumo/producción por lote.

17. `fn_HuellaCarbono`: Estima emisiones por tipo de actividad.

18. `fn_ROICultivo`: Calcula retorno de inversión por tipo de cultivo.

19. `fn_OptimalidadRecursos`: Evalúa eficiencia en asignación de recursos.

20. `fn_RiesgoClimatico`: Calcula factor de riesgo por condiciones climáticas.

## 20 Eventos SQL

1. `ev_ActualizarInventarioNocturno`: Actualiza inventarios cada noche a las 2 AM.

2. `ev_ReporteMensualProduccion`: Genera reporte de producción el primer día de cada mes.

3. `ev_AlertasMantenimiento`: Verifica mantenimientos pendientes cada lunes a las 8 AM.

4. `ev_ActualizarPrecios`: Ajusta precios mensualmente basado en costos.

5. `ev_BackupDiario`: Realiza backup completo cada día a medianoche.

6. `ev_OptimizarIndices`: Reorganiza índices semanalmente en horario bajo.

7. `ev_CalcularComisiones`: Procesa comisiones de ventas cada fin de mes.

8. `ev_ActualizarKPI`: Actualiza indicadores clave cada domingo.

9. `ev_RevisionSalarios`: Ajusta salarios por inflación trimestralmente.

10. `ev_LimpiarLogs`: Purga logs antiguos el primer día de cada trimestre.

11. `ev_GenerarOrdenesCompra`: Revisa inventarios y genera órdenes cada semana.

12. `ev_ReporteVentas`: Consolida reporte de ventas semanal los domingos.

13. `ev_ActualizarPronosticos`: Recalcula pronósticos de producción cada 15 días.

14. `ev_RevisionContratos`: Verifica vencimiento de contratos con clientes/proveedores.

15. `ev_CalidadDatos`: Ejecuta validación de integridad de datos mensualmente.

16. `ev_ArchivoHistorico`: Mueve registros antiguos a tablas históricas anualmente.

17. `ev_ActualizarEstadisticas`: Refresca estadísticas de rendimiento cada semana.

18. `ev_RevisionSeguridad`: Audita accesos y permisos cada mes.

19. `ev_SincronizacionMoviles`: Actualiza datos para aplicaciones móviles cada noche.

20. `ev_NotificacionesRecordatorios`: Envía recordatorios de tareas pendientes diariamente.

## 20 Triggers SQL

1. `tr_ActualizarInventarioVenta`: Actualiza inventario al registrar una venta.

2. `tr_ValidarDisponibilidadMaquinaria`: Verifica disponibilidad antes de asignar maquinaria.

3. `tr_HistorialSalarios`: Registra cambios salariales en tabla de historial.

4. `tr_ControlInventarioMinimo`: Genera alerta al bajar de nivel mínimo.

5. `tr_ValidarEstadoMaquinaria`: Impide asignar maquinaria en mantenimiento.

6. `tr_ActualizarEstadoTarea`: Cambia estado de tarea al completar actividades.

7. `tr_RegistroAccesos`: Registra intentos de acceso fallidos.

8. `tr_ControlCambiosPrecios`: Audita cambios en precios de productos.

9. `tr_ValidarIntegridadProduccion`: Verifica consistencia en registros de producción.

10. `tr_ActualizarKPIProduccion`: Recalcula KPIs al registrar nueva producción.

11. `tr_ControlHorasExtras`: Valida y registra horas extras de empleados.

12. `tr_HistorialModificaciones`: Registra cambios críticos en tablas maestras.

13. `tr_ValidarAsignacionTareas`: Verifica sobreasignación de tareas a empleados.

14. `tr_ActualizarEdadMaquinaria`: Calcula antigüedad al ingresar nueva maquinaria.

15. `tr_ControlCalidadDatos`: Valida integridad referencial en operaciones.

16. `tr_GenerarCodigoProducto`: Asigna código automático a nuevos productos.

17. `tr_ActualizarEstadisticasVentas`: Recalcula métricas al registrar ventas.

18. `tr_ValidarFechasActividades`: Asegura coherencia en fechas de actividades.

19. `tr_ControlVersiones`: Registra versionado de cambios importantes.

20. `tr_OptimizarAsignaciones`: Sugiere asignaciones óptimas al programar.