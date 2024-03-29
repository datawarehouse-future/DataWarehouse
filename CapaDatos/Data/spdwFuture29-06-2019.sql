USE [dwFuture]
GO
/****** Object:  StoredProcedure [dbo].[registrar_exportacion_periodicamente]    Script Date: 29/06/2019 11:45:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[registrar_exportacion_periodicamente]
@id_usuario int,
@mes_exportado varchar(30),
@año_exportado varchar(30),
@hora varchar(20)
as
begin
insert Registro_Exportaciones(id_usuario,Mes,Año,Hora,fecha) values (@id_usuario,@mes_exportado,@año_exportado,@hora, GETDATE());
end
GO
/****** Object:  StoredProcedure [dbo].[sp_CargaGeneral]    Script Date: 29/06/2019 11:45:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_CargaGeneral]
@desde date,
@hasta date
as
begin
/*ELIMINACION DE DATOS*/
DELETE FROM D_Tiempo
DELETE FROM H_Venta
/*INSERCION*/
/*TIEMPO*/
INSERT INTO D_Tiempo SELECT x.id_tiempo,x.mes,x.año
from
(
select ((YEAR(nota.NT_Fecha)*100)+(MONTH(nota.NT_Fecha)))  AS id_tiempo ,DATENAME(mm,nota.NT_Fecha) AS mes, DATENAME(YYYY,nota.NT_Fecha) AS año
FROM Future.dbo.INVNota nota
WHERE nota.NT_Fecha between @desde and  @hasta
)as x
GROUP BY x.id_tiempo,x.mes,x.año
/*INSERCCION DE HECHO*/
delete from H_VENTA
insert into H_VENTA
	select venta.VE_EmpresaId,venta.VE_MedicoId,detalle.DN_ArticuloId,detalle.DN_AfectadoId,nota.NT_UsuarioId,nota.NT_UnidadNegocioId,venta.VE_ClienteId,
		((YEAR(nota.NT_Fecha)*100)+(MONTH(nota.NT_Fecha))) as idfecha,
		replace(SUM(detalle.DN_Cantidad),'-','') as Cantidad,
		replace(SUM(detalle.DN_Cantidad * detalle.DN_PrecioBs),'-','') as Monto

 from Future.dbo.VENVenta venta inner join Future.dbo.INVNota nota on venta.VE_NotaId=nota.NT_NotaId
					 inner join Future.dbo.INVDetalleNota detalle on nota.NT_NotaId=detalle.DN_NotaId
					 where nota.NT_Fecha between @desde and @hasta 
 
	group by
	 venta.VE_EmpresaId,
	 venta.VE_MedicoId,
	 detalle.DN_ArticuloId,
	 detalle.DN_AfectadoId,
	 nota.NT_UsuarioId,
	 nota.NT_UnidadNegocioId,
	 venta.VE_ClienteId,
	 nota.NT_Fecha
	
	 order by 
	
	 nota.NT_Fecha
	 
end
GO
/****** Object:  StoredProcedure [dbo].[sp_CargaGeneralDimensiones]    Script Date: 29/06/2019 11:45:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_CargaGeneralDimensiones]
as
begin

/*INSERT UNIDAD NEGOCIO*/
delete from D_UnidadNegocio
insert into D_UnidadNegocio
select UN_UnidadNegocioId, UN_Nombre
from Future.dbo.CTBUnidadNegocio
ORDER BY UN_UnidadNegocioId

/*INSERT CLIENTES*/
delete from D_Cliente
insert into D_Cliente
select  distinct cliente.EMP_EmpresaId, cliente.EMP_NombreLargo
from Future.dbo.VENVenta venta inner join Future.dbo.GENEmpresa cliente ON venta.VE_ClienteId=cliente.EMP_EmpresaId
ORDER BY cliente.EMP_EmpresaId

/*INSERT MEDICO ENVIA*/
delete from D_MedicoEnvia
INSERT INTO D_MedicoEnvia
select  distinct medico.EMP_EmpresaId, medico.EMP_NombreLargo
from Future.dbo.VENVenta venta inner join Future.dbo.GENEmpresa medico ON venta.VE_MedicoId=medico.EMP_EmpresaId
ORDER BY medico.EMP_EmpresaId

/*INSERT MEDICO SERVICIO*/
DELETE FROM D_MedicoServicio
INSERT INTO D_MedicoServicio
select  distinct medico.EMP_EmpresaId, medico.EMP_NombreLargo
from Future.dbo.INVDetalleNota detalle inner join Future.dbo.GENEmpresa medico ON detalle.DN_AfectadoId=medico.EMP_EmpresaId
ORDER BY medico.EMP_EmpresaId

/*INSER SEGURO*/
DELETE FROM D_Seguro
INSERT INTO D_Seguro
select distinct seguro.EMP_EmpresaId, seguro.EMP_NombreLargo
from Future.dbo.VENVenta venta inner join Future.dbo.GENEmpresa seguro ON venta.VE_EmpresaId=seguro.EMP_EmpresaId
order by seguro.EMP_EmpresaId

/*INSERT SERVICIO*/
DELETE FROM D_Servicio
INSERT INTO D_Servicio
select  distinct AR_ArticuloId, AR_Nombre
from Future.dbo.INVArticulo
ORDER BY AR_ArticuloId

/*INSERT USUARIOS*/
DELETE FROM D_Usuario
INSERT INTO D_Usuario
select  distinct US_UsuarioId, US_Nombre
from Future.dbo.SEGUsuario
ORDER BY US_UsuarioId

END
GO
/****** Object:  StoredProcedure [dbo].[sp_obtener_registroExp_ULTI]    Script Date: 29/06/2019 11:45:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_obtener_registroExp_ULTI]

as
begin
select top 1 Mes,Año  from Registro_Exportaciones order by id desc 
end
GO
/****** Object:  StoredProcedure [dbo].[sp_ObtenerFechaFinDeVenta]    Script Date: 29/06/2019 11:45:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_ObtenerFechaFinDeVenta]
as begin
select top 1 Year(NT_Fecha) as año, DATENAME(mm,NT_Fecha) AS mes, DAY(NT_Fecha) as dia
 from Future.dbo.INVNota order by  NT_Fecha desc
end
GO
/****** Object:  StoredProcedure [dbo].[sp_ObtenerFechaInicioDeVenta]    Script Date: 29/06/2019 11:45:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_ObtenerFechaInicioDeVenta]
as begin
select top 1 Year(NT_Fecha) as año, DATENAME(mm,NT_Fecha) AS mes, DAY(NT_Fecha) as dia
 from Future.dbo.INVNota order by  NT_Fecha asc
end
GO
/****** Object:  StoredProcedure [dbo].[sp_ObtenerGestion]    Script Date: 29/06/2019 11:45:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[sp_ObtenerGestion]
as begin
SELECT x.año
from
(
select DATENAME(YYYY,nota.NT_Fecha) AS año
FROM Future.dbo.INVNota nota
)as x
GROUP BY x.año
ORDER BY x.año asc
end
GO
/****** Object:  StoredProcedure [dbo].[sp_ObtenerMesesDeGestion]    Script Date: 29/06/2019 11:45:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[sp_ObtenerMesesDeGestion]
@año int,
@combobox int
as begin
declare @añoactual int
set @añoactual=(select Year (GETDATE()))		
if(@combobox=1)
	begin
		if(@año=@añoactual)
			begin
				declare @mesactual int
				set @mesactual=4  /*(select MONTH (GETDATE()))*/
				  SELECT x.id_tiempo,x.mes
				from
				(
				select (MONTH(nota.NT_Fecha))  AS id_tiempo ,DATENAME(mm,nota.NT_Fecha) AS mes
				FROM Future.dbo.INVNota nota where (YEAR(nota.NT_Fecha))=@año
				)as x 
				GROUP BY x.id_tiempo,x.mes
				having x.id_tiempo<@mesactual
				order by x.id_tiempo
			 end
		else begin
			 SELECT x.id_tiempo,x.mes
				from
				(
				select (MONTH(nota.NT_Fecha))  AS id_tiempo ,DATENAME(mm,nota.NT_Fecha) AS mes
				FROM Future.dbo.INVNota nota where (YEAR(nota.NT_Fecha))=@año
				)as x 
				GROUP BY x.id_tiempo,x.mes
				order by x.id_tiempo
			 end
	end

else  if(@combobox=2)
	begin
		if(@año=@añoactual)
			BEGIN
				declare @mesactual2 int
				set @mesactual2=4  /*(select MONTH (GETDATE()))*/
				SELECT x.id_tiempo,x.mes
				from
				(
				select (MONTH(nota.NT_Fecha))  AS id_tiempo ,DATENAME(mm,nota.NT_Fecha) AS mes
				FROM Future.dbo.INVNota nota where (YEAR(nota.NT_Fecha))=@año
				)as x 
				GROUP BY x.id_tiempo,x.mes
				having x.id_tiempo<@mesactual2
				order by x.id_tiempo
			END
			Else begin
					SELECT x.id_tiempo,x.mes
					from
					(
					select (MONTH(nota.NT_Fecha))  AS id_tiempo ,DATENAME(mm,nota.NT_Fecha) AS mes
					FROM Future.dbo.INVNota nota where (YEAR(nota.NT_Fecha))=@año
					)as x 
					GROUP BY x.id_tiempo,x.mes
					order by x.id_tiempo
				end

	end
end
GO
/****** Object:  StoredProcedure [dbo].[sp_Seleccionar_Hecho]    Script Date: 29/06/2019 11:45:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[sp_Seleccionar_Hecho]
@MES int,
@AÑO int
as
begin
	select venta.VE_EmpresaId,venta.VE_MedicoId,detalle.DN_ArticuloId,detalle.DN_AfectadoId,nota.NT_UsuarioId,nota.NT_UnidadNegocioId,venta.VE_ClienteId,
		((YEAR(nota.NT_Fecha)*100)+(MONTH(nota.NT_Fecha))) as idfecha,
		replace(SUM(detalle.DN_Cantidad),'-','') as Cantidad,
		replace(SUM(detalle.DN_Cantidad * detalle.DN_PrecioBs),'-','') as Monto

 from Future.dbo.VENVenta venta inner join Future.dbo.INVNota nota on venta.VE_NotaId=nota.NT_NotaId
					 inner join Future.dbo.INVDetalleNota detalle on nota.NT_NotaId=detalle.DN_NotaId
					 where (YEAR(nota.NT_Fecha))=@AÑO and (MONTH(nota.NT_Fecha))=@MES
	group by
	 venta.VE_EmpresaId,
	 venta.VE_MedicoId,
	 detalle.DN_ArticuloId,
	 detalle.DN_AfectadoId,
	 nota.NT_UsuarioId,
	 nota.NT_UnidadNegocioId,
	 venta.VE_ClienteId,
	 nota.NT_Fecha
	
	 order by 
	  venta.VE_EmpresaId,
	 venta.VE_MedicoId,
	 detalle.DN_ArticuloId,
	 detalle.DN_AfectadoId,
	 nota.NT_UsuarioId,
	 nota.NT_UnidadNegocioId,
	 venta.VE_ClienteId,
	 nota.NT_Fecha,
	 Cantidad,
	 Monto
end
GO
/****** Object:  StoredProcedure [dbo].[sp_Seleccionar_unidadNegocio]    Script Date: 29/06/2019 11:45:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[sp_Seleccionar_unidadNegocio]
as
begin
select UN_UnidadNegocioId, UN_Nombre
from Future.dbo.CTBUnidadNegocio
ORDER BY UN_UnidadNegocioId
end


GO
/****** Object:  StoredProcedure [dbo].[sp_SeleccionarClientes]    Script Date: 29/06/2019 11:45:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[sp_SeleccionarClientes]
as
begin
select  distinct cliente.EMP_EmpresaId, cliente.EMP_NombreLargo
from Future.dbo.VENVenta venta inner join Future.dbo.GENEmpresa cliente ON venta.VE_ClienteId=cliente.EMP_EmpresaId
ORDER BY cliente.EMP_EmpresaId
end
GO
/****** Object:  StoredProcedure [dbo].[sp_SeleccionarMedicoEnvia]    Script Date: 29/06/2019 11:45:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[sp_SeleccionarMedicoEnvia]
as
begin
select  distinct medico.EMP_EmpresaId, medico.EMP_NombreLargo
from Future.dbo.VENVenta venta inner join Future.dbo.GENEmpresa medico ON venta.VE_MedicoId=medico.EMP_EmpresaId
ORDER BY medico.EMP_EmpresaId
end

GO
/****** Object:  StoredProcedure [dbo].[sp_SeleccionarMedicoServicio]    Script Date: 29/06/2019 11:45:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[sp_SeleccionarMedicoServicio]
as
begin
select  distinct medico.EMP_EmpresaId, medico.EMP_NombreLargo
from Future.dbo.INVDetalleNota detalle inner join Future.dbo.GENEmpresa medico ON detalle.DN_AfectadoId=medico.EMP_EmpresaId
ORDER BY medico.EMP_EmpresaId
end

GO
/****** Object:  StoredProcedure [dbo].[sp_SeleccionarSeguro]    Script Date: 29/06/2019 11:45:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[sp_SeleccionarSeguro]
as
begin
select distinct seguro.EMP_EmpresaId, seguro.EMP_NombreLargo
from Future.dbo.VENVenta venta inner join Future.dbo.GENEmpresa seguro ON venta.VE_EmpresaId=seguro.EMP_EmpresaId
order by seguro.EMP_EmpresaId
end

GO
/****** Object:  StoredProcedure [dbo].[sp_SeleccionarServicio]    Script Date: 29/06/2019 11:45:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[sp_SeleccionarServicio]
as
begin
select  distinct AR_ArticuloId, AR_Nombre
from Future.dbo.INVArticulo
ORDER BY AR_ArticuloId
end


GO
/****** Object:  StoredProcedure [dbo].[sp_SeleccionarUsuarios]    Script Date: 29/06/2019 11:45:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[sp_SeleccionarUsuarios]
as
begin
select  distinct US_UsuarioId, US_Nombre
from Future.dbo.SEGUsuario
ORDER BY US_UsuarioId
end
GO
/****** Object:  StoredProcedure [dbo].[sp_SubirCliente]    Script Date: 29/06/2019 11:45:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_SubirCliente]
AS 
BEGIN
delete from D_Cliente
BULK INSERT D_Cliente
FROM 'C:\ARCHIVOS\cliente.txt'
WITH
(
FIELDTERMINATOR = '|',
ROWTERMINATOR = '\n'
)
END
GO
/****** Object:  StoredProcedure [dbo].[sp_SubirMedicoEnvia]    Script Date: 29/06/2019 11:45:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_SubirMedicoEnvia]
AS 
BEGIN
delete from D_MedicoEnvia
BULK INSERT D_MedicoEnvia
FROM 'C:\ARCHIVOS\medico_envia.txt'
WITH
(
FIELDTERMINATOR = '|',
ROWTERMINATOR = '\n'
)
END
GO
/****** Object:  StoredProcedure [dbo].[sp_SubirMedicoServicio]    Script Date: 29/06/2019 11:45:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_SubirMedicoServicio]
AS 
BEGIN
delete from D_MedicoServicio
BULK INSERT D_MedicoServicio
FROM 'C:\ARCHIVOS\medico_servicio.txt'
WITH
(
FIELDTERMINATOR = '|',
ROWTERMINATOR = '\n'
)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_SubirSeguro]    Script Date: 29/06/2019 11:45:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_SubirSeguro]
AS 
BEGIN
delete from D_Seguro
BULK INSERT D_Seguro
FROM 'C:\ARCHIVOS\seguros.txt'
WITH
(
FIELDTERMINATOR = '|',
ROWTERMINATOR = '\n'
)
END
GO
/****** Object:  StoredProcedure [dbo].[sp_SubirServicio]    Script Date: 29/06/2019 11:45:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_SubirServicio]
AS 
BEGIN
delete from D_Servicio
BULK INSERT D_Servicio
FROM 'C:\ARCHIVOS\servicio.txt'
WITH
(
FIELDTERMINATOR = '|',
ROWTERMINATOR = '\n'
)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_SubirTiempo]    Script Date: 29/06/2019 11:45:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_SubirTiempo]
AS 
BEGIN
BULK INSERT D_Tiempo
FROM 'C:\ARCHIVOS\tiempo.txt'
WITH
(
FIELDTERMINATOR = '|',
ROWTERMINATOR = '\n'
)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_SubirUsuario]    Script Date: 29/06/2019 11:45:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_SubirUsuario]
AS 
BEGIN
delete from D_Usuario
BULK INSERT D_Usuario
FROM 'C:\ARCHIVOS\usuarios.txt'
WITH
(
FIELDTERMINATOR = '|',
ROWTERMINATOR = '\n'
)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_SubirVenta]    Script Date: 29/06/2019 11:45:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_SubirVenta]
AS 
BEGIN

BULK INSERT H_Venta
FROM 'C:\ARCHIVOS\venta.txt'
WITH
(
FIELDTERMINATOR = '|',
ROWTERMINATOR = '\n'
)
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Unidad_Negocio]    Script Date: 29/06/2019 11:45:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_Unidad_Negocio]
AS 
BEGIN
delete from D_UnidadNegocio
BULK INSERT D_UnidadNegocio
FROM 'C:\ARCHIVOS\unidad_negocio.txt'
WITH
(
FIELDTERMINATOR = '|',
ROWTERMINATOR = '\n'
)
END

GO
/****** Object:  StoredProcedure [dbo].[spGetUserId]    Script Date: 29/06/2019 11:45:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spGetUserId]
as
SELECT IDENT_CURRENT('D_usuarios')+1 AS Us_Id
GO
/****** Object:  StoredProcedure [dbo].[spInsertar_Usuario]    Script Date: 29/06/2019 11:45:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spInsertar_Usuario]
@nombre varchar(50),
@usuario nvarchar(50),
@salt  varbinary(max),
@pass  varbinary(max),
@estado int,
@acceso varchar(20) 
as

insert into D_usuarios (US_Nombre, US_NombreUsuario, US_Salt, US_Pass, US_Estado, US_Acceso)
values (@nombre,@usuario,@salt,@pass,@estado,@acceso)
GO
/****** Object:  StoredProcedure [dbo].[US_ObtenerCredenciales]    Script Date: 29/06/2019 11:45:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[US_ObtenerCredenciales]
@Nombre_Usuario varchar(50)
as
select US_NombreUsuario,US_Salt,US_Pass from D_usuarios where D_usuarios.US_NombreUsuario = @Nombre_Usuario

GO
