# Universidad Ducky - Sistema de Gestion de Biblioteca

Aplicacion desarrollada en **Flutter** para la gestion integral de una biblioteca universitaria. Permite administrar libros, copias fisicas, prestamos, solicitudes de compra y usuarios con distintos roles de acceso.

## Funcionalidades principales

- **Dashboard**: Panel con metricas clave (total de libros, copias, prestamos activos, libros vencidos), grafico de barras con tendencias de prestamos y grafico circular por categoria.
- **Catalogo de libros**: Alta, edicion, listado y detalle de libros (ISBN, autor, editorial, tema, seccion, precio, etc.).
- **Copias fisicas**: Seguimiento individual de cada ejemplar con estado (disponible, prestado, reservado, uso interno, danado, extraviado), ubicacion y condicion.
- **Prestamos**: Registro de prestamos con fechas de entrega/devolucion, estado, multas y renovaciones.
- **Solicitudes de compra**: Flujo de solicitudes con estados (pendiente, aprobado, rechazado, comprado), cantidad, precio unitario y justificacion.
- **Gestion de usuarios**: Creacion y administracion de cuentas con roles diferenciados.
- **Busqueda de alumnos**: Interfaz adaptada para escritorio y movil.
- **Permisos**: Configuracion de permisos por rol.

## Roles de usuario

| Rol | Acceso |
|---|---|
| Administrador | Acceso completo a todos los modulos |
| Bibliotecario | Panel administrativo |
| Profesor | Acceso completo |
| Alumno | Busqueda de libros |

## Stack tecnologico

- **Flutter** con Material Design
- **Provider** para manejo de estado
- **GoRouter** para navegacion con redireccion basada en roles
- **fl_chart** para graficos
- **intl** para formateo de fechas en espanol
- Interfaz responsive (web y movil)
