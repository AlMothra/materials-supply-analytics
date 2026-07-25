-- =============================================================================
-- PROYECTO: Control de Materiales, Proyectos y Forecast Presupuestal (BI)
-- AUTOR: Alexandre Motta
-- FECHA: Julio 2026
-- DESCRIPCIÓN: Vistas optimizadas e intermedias para consumo en Power BI
-- =============================================================================

USE db_control_materiales;
GO

-- -----------------------------------------------------------------------------
-- VISTA 1: Consolidado de Despachos por Proveedor y Material
-- Optimiza la lectura de volumenes despachados para Power BI
-- -----------------------------------------------------------------------------
CREATE OR ALTER VIEW vw_ConsolidadoDespachos AS
SELECT 
    d.FechaDespacho,
    p.CodigoProveedor,
    p.NombreProveedor,
    m.CodigoMaterial,
    m.DescripcionMaterial,
    pr.NombreProyecto,
    pr.Seccion,
    d.CantidadDespachada,
    (d.CantidadDespachada * m.CostoUnitarioEstandar) AS MontoEstimadoDespacho
FROM Fact_Despachos d
INNER JOIN Dim_Proveedor p ON d.ProveedorID = p.ProveedorID
INNER JOIN Dim_Material m ON d.MaterialID = m.MaterialID
INNER JOIN Dim_Proyecto pr ON d.ProyectoID = pr.ProyectoID;
GO

-- -----------------------------------------------------------------------------
-- VISTA 2: Comparativo de Forecast (PDI) vs Ejecución para ETL
-- Facilita el cálculo de desviaciones presupuestales
-- -----------------------------------------------------------------------------
CREATE OR ALTER VIEW vw_ForecastPresupuestal AS
SELECT 
    f.FechaInicioSemana,
    p.NombreProveedor,
    m.CodigoMaterial,
    m.DescripcionMaterial,
    pr.Seccion,
    SUM(f.MontoPresupuestadoPDI) AS MontoTotalPDI,
    SUM(f.CantidadProyectada) AS CantidadProyectadaTotal
FROM Fact_Prevision f
INNER JOIN Dim_Proveedor p ON f.ProveedorID = p.ProveedorID
INNER JOIN Dim_Material m ON f.MaterialID = m.MaterialID
INNER JOIN Dim_Proyecto pr ON f.ProyectoID = pr.ProyectoID
GROUP BY 
    f.FechaInicioSemana, 
    p.NombreProveedor, 
    m.CodigoMaterial, 
    m.DescripcionMaterial, 
    pr.Seccion;
GO

-- -----------------------------------------------------------------------------
-- VISTA 3: Detección de Riesgo de Quiebre de Stock (Métrica Backend)
-- Muestra la reserva de stock actual comparada con el promedio de despacho diario
-- -----------------------------------------------------------------------------
CREATE OR ALTER VIEW vw_MonitoreoQuiebreStock AS
WITH ConsumoUltimos30Dias AS (
    SELECT 
        MaterialID,
        SUM(CantidadDespachada) / 30.0 AS ConsumoDiarioPromedio
    FROM Fact_Despachos
    WHERE FechaDespacho >= DATEADD(DAY, -30, GETDATE())
    GROUP BY MaterialID
)
SELECT 
    m.CodigoMaterial,
    m.DescripcionMaterial,
    s.StockDisponible,
    ISNULL(c.ConsumoDiarioPromedio, 0) AS ConsumoDiarioProm,
    CASE 
        WHEN ISNULL(c.ConsumoDiarioPromedio, 0) = 0 THEN 999
        ELSE ROUND(s.StockDisponible / c.ConsumoDiarioPromedio, 0)
    END AS DiasCoberturaRestantes
FROM Fact_StockAlmacen s
INNER JOIN Dim_Material m ON s.MaterialID = m.MaterialID
LEFT JOIN ConsumoUltimos30Dias c ON s.MaterialID = c.MaterialID
WHERE s.FechaCorte = (SELECT MAX(FechaCorte) FROM Fact_StockAlmacen);
GO
