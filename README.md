# 📊 Torre de Control Presupuestal y Gestión de Materiales

![Power BI](https://img.shields.io/badge/Power_BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![SQL](https://img.shields.io/badge/SQL_Server-CC292B?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)
![Power Automate](https://img.shields.io/badge/Power_Automate-0078D4?style=for-the-badge&logo=powerautomate&logoColor=white)

## 📌 Resumen del Proyecto
Este repositorio contiene la **solución end-to-end** para la automatización, modelado y visualización del control presupuestal de materiales y contratistas. 

El proyecto resuelve la ingesta de datos desestructurados desde la fuente mediante **Power Automate**, el diseño de la base de datos relacional en **SQL**, y la construcción de un tablero ejecutivo en **Power BI** estructurado bajo un modelo en estrella (*Star Schema*).

---

## 📁 Estructura del Repositorio

```text
.
├── data/                             # Datasets en CSV (Dimensiones y Hechos)
│   ├── Dim_Material.csv
│   ├── Dim_Proveedor.csv
│   ├── Dim_Proyecto.csv
│   ├── Fact_Despachos.csv
│   ├── Fact_Prevision.csv
│   ├── Fact_StockAlmacen.csv
│   └── Fact_StockReal_Consolidado.csv
├── database/                         # Scripts de diseño de base de datos SQL
│   ├── Business_Schema.sql           # DDL: Creación de esquemas y tablas
│   └── views-queries.sql             # Vistas y consultas optimizadas
├── pbix/                             # Archivo ejecutable de Power BI
│   └── Control_Materiales_Comercial.pbix
├── power_automate/                   # Diagramas de flujos de automatización
│   ├── 01_solicitar_stock_flow.png   # Orquestación de solicitud programada
│   └── 02_procesamiento_ingesta_flow.png # Pipeline de ingesta y ETL Event-Driven
└── README.md                         # Documentación principal
```

🏗️ Arquitectura del Sistema

1. Ingesta y ETL (Power Automate)Para eliminar la carga manual de archivos Excel, se implementaron dos flujos automatizados:

01_solicitar_stock_flow: Disparo programado semanal que distribuye plantillas por Outlook a proveedores y contratistas desde SharePoint.

02_procesamiento_ingesta_flow: Disparo Event-Driven al recibir archivos. Ejecuta la sanitización de datos, extracción por filas, inserción masiva en las tablas consolidadas y depuración del archivo origen.

2. Capa de Base de Datos (SQL)Business_Schema.sql: Define las tablas de hechos y dimensiones con integridad referencial.views-queries.sql: Vistas precalculadas para aplicar Query Folding y reducir tiempos de procesamiento en la carga hacia Power BI.

3. Modelado Dimensional y DAX (Power BI)El archivo Control_Materiales_Comercial.pbix implementa un modelo en estrella (Star Schema) con relaciones $1:*$ unidireccionales.

Medidas DAX Principales:

```text
-- Presupuesto Anual Estático (Techo global de S/ 17.02 mill.)
Presupuesto_Anual = 
CALCULATE(
    SUM(Fact_Prevision[MontoPresupuestadoPDI]),
    REMOVEFILTERS(Dim_Calendario)
) * 12

-- Presupuesto Mensual Base (Benchmark fijo por mes de S/ 1.42 mill.)
Presupuesto_Mensual = 
CALCULATE(
    SUM(Fact_Prevision[MontoPresupuestadoPDI]),
    REMOVEFILTERS(Dim_Calendario[NombreMes]),
    REMOVEFILTERS(Dim_Calendario[MesNum])
)

-- Variación Presupuestal Real
Variacion_Presupuestal = [Monto_Ejecutado] - [Presupuesto_Anual]

```
🛠️ Tecnologías Utilizadas

Base de Datos: SQL Server / T-SQL.

BI & Visualización: Power BI Desktop (Power Query, DAX, DataViz).Automatización: Power Automate.

Control de Versiones: Git & GitHub.

👨‍💻 Autor

Alexandre Motta

Data Scientist Jr. / Data Analyst

> 🔒 **Aviso de Confidencialidad y Datos:**  
> Por motivos de confidencialidad y acuerdos de no divulgación (NDA), la data utilizada en este proyecto ha sido **simulada y anonimizada**. Los datos no representan cifras reales ni identidades de proveedores específicos, pero conservan la estructura transaccional, la complejidad del modelo relacional y la lógica de negocio del entorno de producción.
