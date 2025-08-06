# 📊 Gestión Agrícola – SQL

## Consultas Principales

1. Producción total por tipo de cultivo
2. Ventas por cliente y producto
3. Promedio de horas de uso por tipo de maquinaria
4. Tareas pendientes por empleado
5. Rendimiento por hectárea de cada lote
6. Relación entre ventas e inventario por producto
7. Clientes con compras constantes por varios meses
8. Maquinaria con mantenimiento vencido
9. Productos con variaciones estacionales de ventas
10. Empleados que han hecho diferentes tipos de tareas
11. Lotes con baja producción respecto a su potencial
12. Proveedores con múltiples tipos de insumos
13. Relación entre producción y clima
14. Costos operativos por lote y cultivo
15. Productos que suelen venderse juntos
16. Comparación entre agua usada y producción por cultivo
17. Evolución de precios en los últimos meses
18. Tiempo promedio desde producción hasta venta
19. Impacto de actividades agrícolas en la producción
20. Solapamiento en uso de maquinaria y personal

## ⚙️ Procedimientos Almacenados

1. `sp_RegistrarVenta`: Registra una nueva venta
2. `sp_ActualizarInventario`: Actualiza el inventario tras ventas o producción
3. `sp_ProgramarMantenimiento`: Agenda mantenimiento por horas de uso
4. `sp_AsignarTarea`: Asigna tareas a empleados disponibles
5. `sp_CalcularNomina`: Calcula la nómina con bonificaciones simples
6. `sp_GenerarOrdenCompra`: Crea orden si el inventario está bajo
7. `sp_RotarCultivos`: Agenda rotación de cultivos
8. `sp_ActualizarPrecios`: Ajusta precios según margen deseado
9. `sp_ProcesarProduccion`: Registra producción en un lote
10. `sp_AlertasInventario`: Envía alertas por bajo inventario
11. `sp_OptimizarRiego`: Sugiere riego según cultivo
12. `sp_AsignarMaquinaria`: Asigna maquinaria validando disponibilidad
13. `sp_CalcularComisiones`: Calcula comisiones por ventas
14. `sp_GenerarReporteProduccion`: Genera un resumen de producción
15. `sp_ActualizarCostos`: Actualiza costos de actividades
16. `sp_ProgramarSiembras`: Agenda fechas de siembra por lote
17. `sp_ProcesarCompra`: Registra compras a proveedores
18. `sp_AnalizarRendimiento`: Revisa el rendimiento por lote
19. `sp_GenerarFacturas`: Genera facturas por ventas
20. `sp_ActualizarKPI`: Actualiza indicadores de desempeño

## 📐 Funciones SQL

1. `fn_CalcularRendimiento`: Devuelve kg/ha de un lote
2. `fn_CalcularCostoOperativo`: Costos por lote en un periodo
3. `fn_EdadMaquinaria`: Antigüedad de una máquina
4. `fn_EstimarProduccion`: Predicción básica de producción
5. `fn_CalcularMargen`: Margen por producto
6. `fn_TiempoEntreActividades`: Tiempo promedio entre actividades
7. `fn_ProductividadEmpleado`: Eficiencia del empleado
8. `fn_DisponibilidadMaquinaria`: Porcentaje de uso disponible
9. `fn_CostoActividad`: Costo total por tipo de actividad
10. `fn_RequerimientoManoObra`: Estimación de horas-hombre
11. `fn_ProyeccionVentas`: Proyección simple de ventas
12. `fn_PuntoReorden`: Nivel para reordenar productos
13. `fn_DepreciacionMaquinaria`: Depreciación acumulada
14. `fn_RequerimientoAgua`: Agua necesaria por cultivo
15. `fn_SatisfaccionCliente`: Medición por compras repetidas
16. `fn_EficienciaInsumos`: Relación entre insumo y producción
17. `fn_HuellaCarbono`: Estimación por actividad
18. `fn_ROICultivo`: Retorno sobre inversión
19. `fn_OptimalidadRecursos`: Eficiencia en uso de recursos
20. `fn_RiesgoClimatico`: Nivel de riesgo según el clima

## ⏰ Eventos SQL

1. `ev_ActualizarInventarioNocturno`: Ejecutado cada día a las 2 AM
2. `ev_ReporteMensualProduccion`: Primer día de cada mes
3. `ev_AlertasMantenimiento`: Cada lunes a las 8 AM
4. `ev_ActualizarPrecios`: Revisión mensual de precios
5. `ev_BackupDiario`: Copia de seguridad diaria
6. `ev_OptimizarIndices`: Optimiza índices semanalmente
7. `ev_CalcularComisiones`: Fin de cada mes
8. `ev_ActualizarKPI`: Cada domingo
9. `ev_RevisionSalarios`: Revisión trimestral de salarios
10. `ev_LimpiarLogs`: El primer día de cada trimestre
11. `ev_GenerarOrdenesCompra`: Cada semana
12. `ev_ReporteVentas`: Cada domingo
13. `ev_ActualizarPronosticos`: Cada 15 días
14. `ev_RevisionContratos`: Revisión de vencimientos
15. `ev_CalidadDatos`: Validación mensual
16. `ev_ArchivoHistorico`: Archiva datos antiguos una vez al año
17. `ev_ActualizarEstadisticas`: Cada semana
18. `ev_RevisionSeguridad`: Revisión mensual de accesos
19. `ev_SincronizacionMoviles`: Sincroniza cada noche
20. `ev_NotificacionesRecordatorios`: Notifica tareas todos los días

## 🔁 Triggers SQL

1. `tr_ActualizarInventarioVenta`: Reduce inventario al vender
2. `tr_ValidarDisponibilidadMaquinaria`: Verifica disponibilidad antes de usar
3. `tr_HistorialSalarios`: Guarda historial de cambios
4. `tr_ControlInventarioMinimo`: Genera alerta al bajar inventario
5. `tr_ValidarEstadoMaquinaria`: Evita usar maquinaria en mantenimiento
6. `tr_ActualizarEstadoTarea`: Cambia el estado de tareas al completarlas
7. `tr_RegistroAccesos`: Guarda accesos fallidos
8. `tr_ControlCambiosPrecios`: Audita cambios de precios
9. `tr_ValidarIntegridadProduccion`: Verifica registros de producción
10. `tr_ActualizarKPIProduccion`: Recalcula KPIs al registrar producción
11. `tr_ControlHorasExtras`: Valida y guarda horas extras
12. `tr_HistorialModificaciones`: Guarda cambios importantes
13. `tr_ValidarAsignacionTareas`: Revisa si un empleado ya tiene muchas tareas
14. `tr_ActualizarEdadMaquinaria`: Calcula antigüedad al registrar máquina
15. `tr_ControlCalidadDatos`: Verifica datos importantes
16. `tr_GenerarCodigoProducto`: Crea código automático
17. `tr_ActualizarEstadisticasVentas`: Recalcula estadísticas de ventas
18. `tr_ValidarFechasActividades`: Asegura coherencia en fechas
19. `tr_ControlVersiones`: Guarda versiones de cambios
20. `tr_OptimizarAsignaciones`: Sugiere mejoras en tareas