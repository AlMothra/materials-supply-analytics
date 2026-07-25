-- =============================================================================
-- PROYECTO: Control de Materiales, Proyectos y Forecast Presupuestal (BI)
-- AUTOR: Alexandre Motta
-- FECHA: Julio 2026
-- DESCRIPCIÓN: Creación de tablas para modelo relacional en estrella (Star Schema)
-- =============================================================================

CREATE DATABASE db_control_materiales;
GO

USE db_control_materiales;
GO

-- -----------------------------------------------------------------------------
-- 1. TABLAS DIMENSIONALES (DIMENSIONS)
-- -----------------------------------------------------------------------------

-- Dimensión Proveedor / Contratista
CREATE TABLE Dim_Proveedor (
    ProveedorID INT IDENTITY(1,1) PRIMARY KEY,
    CodigoProveedor VARCHAR(20) NOT NULL UNIQUE,
    NombreProveedor VARCHAR(100) NOT NULL,
    TipoServicio VARCHAR(50) NULL,
    Estado BIT DEFAULT 1
);

-- Dimensión Material
CREATE TABLE Dim_Material (
    MaterialID INT IDENTITY(1,1) PRIMARY KEY,
    CodigoMaterial VARCHAR(20) NOT NULL UNIQUE,
    DescripcionMaterial VARCHAR(150) NOT NULL,
    UnidadMedida VARCHAR(10) NOT NULL,
    CostoUnitarioEstandar DECIMAL(12,2) NOT NULL
);

-- Dimensión Proyecto / Sección Commercial
CREATE TABLE Dim_Proyecto (
    ProyectoID INT IDENTITY(1,1) PRIMARY KEY,
    CodigoProyecto VARCHAR(20) NOT NULL UNIQUE,
    NombreProyecto VARCHAR(100) NOT NULL,
    Seccion VARCHAR(50) NOT NULL, -- ej. Conexiones, Obras Civiles, Mantenimiento
    Ubicacion VARCHAR(100) NULL
);

-- -----------------------------------------------------------------------------
-- 2. TABLAS DE HECHOS (FACT TABLES)
-- -----------------------------------------------------------------------------

-- Fact: Despachos / Entregas Realizadas
CREATE TABLE Fact_Despachos (
    DespachoID BIGINT IDENTITY(1,1) PRIMARY KEY,
    FechaDespacho DATE NOT NULL,
    MaterialID INT NOT NULL,
    ProveedorID INT NOT NULL,
    ProyectoID INT NOT NULL,
    CantidadDespachada DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (MaterialID) REFERENCES Dim_Material(MaterialID),
    FOREIGN KEY (ProveedorID) REFERENCES Dim_Proveedor(ProveedorID),
    FOREIGN KEY (ProyectoID) REFERENCES Dim_Proyecto(ProyectoID)
);

-- Fact: Previsión / Forecast Presupuestal (PDI)
CREATE TABLE Fact_Prevision (
    PrevisionID BIGINT IDENTITY(1,1) PRIMARY KEY,
    FechaInicioSemana DATE NOT NULL,
    MaterialID INT NOT NULL,
    ProveedorID INT NOT NULL,
    ProyectoID INT NOT NULL,
    MontoPresupuestadoPDI DECIMAL(14,2) NOT NULL,
    CantidadProyectada DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (MaterialID) REFERENCES Dim_Material(MaterialID),
    FOREIGN KEY (ProveedorID) REFERENCES Dim_Proveedor(ProveedorID),
    FOREIGN KEY (ProyectoID) REFERENCES Dim_Proyecto(ProyectoID)
);

-- Fact: Stock e Inventario Almacén (AGUNSA)
CREATE TABLE Fact_StockAlmacen (
    StockID BIGINT IDENTITY(1,1) PRIMARY KEY,
    FechaCorte DATE NOT NULL,
    MaterialID INT NOT NULL,
    StockDisponible DECIMAL(12,2) NOT NULL,
    StockSeguridad DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (MaterialID) REFERENCES Dim_Material(MaterialID)
);
