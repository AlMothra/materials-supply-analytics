# 📊 Torre de Control Presupuestal y Gestión de Materiales | Power BI & Power Automate

![Power BI](https://img.shields.io/badge/Power_BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![SQL](https://img.shields.io/badge/SQL-CC292B?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)
![Power Automate](https://img.shields.io/badge/Power_Automate-0078D4?style=for-the-badge&logo=powerautomate&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)

## 🎯 Resumen del Proyecto
Este proyecto aborda la **refactorización integral de un sistema de reporte transaccional disperso**, transformándolo en una **Torre de Control Ejecutiva** en Power BI. 

La solución permite auditar la ejecución presupuestal de contratistas, monitorear la tendencia mensual del gasto y prevenir quiebres de stock en tiempo real mediante un pipeline de ingesta automatizado con Power Automate.

---

## 📉 Problema de Negocio vs. 📈 Solución Implementada

| Reporte Original (Legacy) | Dashboard Refactorizado (Torre de Control) |
| :--- | :--- |
| Alta carga cognitiva y gráficos saturados sin jerarquía visual. | Layout ejecutivo con navegación en "Z" enfocado en toma de decisiones en <5 seg. |
| Descalce temporal entre ejecución real y presupuesto estático. | Arquitectura DAX para aislamiento de contextos de filtro temporales. |
| Recopilación de datos manual mediante archivos Excel por correo. | Pipeline *event-driven* de ingesta, sanitización y carga en Power Automate. |

---

## 🏗️ Arquitectura de Datos y Modelado

### 1. Modelo en Estrella (*Star Schema*)
El modelo fue optimizado para maximizar el rendimiento en el motor **VertiPaq**:

* **Tablas de Hechos (`Fact`):**
  * `Fact_StockReal`: Registro transaccional de ejecuciones y saldos.
  * `Fact_Prevision`: Techos presupuestales asignados (PDI).
* **Tablas de Dimensión (`Dim`):**
  * `Dim_Calendario`, `Dim_Proveedor`, `Dim_Material`.
* **Relaciones:** Unidireccionales $1:*$ para evitar dependencias circulares y optimizar la propagación de filtros.

### 2. Lógica DAX Destacada (Manejo de Contextos)
Para resolver el descalce entre la meta estática anual/mensual y el flujo dinámico ejecutado:

```dax
-- Presupuesto Anual Estático (Mantiene la línea base global)
Presupuesto_Anual = 
CALCULATE(
    SUM(Fact_Prevision[MontoPresupuestadoPDI]),
    REMOVEFILTERS(Dim_Calendario)
) * 12

-- Presupuesto Mensual Base (Garantiza benchmark estático por mes)
Presupuesto_Mensual = 
CALCULATE(
    SUM(Fact_Prevision[MontoPresupuestadoPDI]),
    REMOVEFILTERS(Dim_Calendario[NombreMes]),
    REMOVEFILTERS(Dim_Calendario[MesNum])
)

-- Variación Presupuestal
Variacion_Presupuestal = [Monto_Ejecutado] - [Presupuesto_Anual]
