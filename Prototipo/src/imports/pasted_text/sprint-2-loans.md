Implementar Sprint 2

Continúa desarrollando el prototipo del Sistema de Gestión de Biblioteca dentro de este archivo de Figma.

Utiliza y respeta el design system ya existente en el proyecto.
No rediseñes colores, tipografías ni componentes base.

Reutiliza los componentes existentes:
	•	sistema de colores
	•	tipografía
	•	grid y layout
	•	botones
	•	inputs
	•	tablas
	•	sidebar de navegación
	•	modales
	•	badges de estado
	•	componentes de tarjetas

El objetivo es extender el prototipo agregando las funcionalidades del Sprint 2.

⸻

Contexto del sistema

Este sistema es una aplicación web para la gestión de una biblioteca universitaria.

El sistema permite administrar:
	•	usuarios
	•	catálogo de libros
	•	copias físicas de los libros
	•	préstamos
	•	devoluciones
	•	multas
	•	listas de espera

Los actores principales que usarán estas funcionalidades son:
	•	Bibliotecario
	•	Administrador

Las interfaces deben estar optimizadas para operaciones rápidas, ya que los bibliotecarios atienden a muchos estudiantes.

⸻

Sprint 2 – Gestión de Préstamos

Agregar un nuevo módulo en la navegación lateral:

Préstamos

Subsecciones:
	•	Préstamos Activos
	•	Nuevo Préstamo
	•	Devoluciones
	•	Lista de Espera
	•	Multas

⸻

Pantalla 1 – Préstamos Activos

Crear una pantalla con tabla que muestre todos los préstamos actuales.

Columnas:

ID de préstamo
ID de usuario
Nombre del usuario
Título del libro
ID de copia
Fecha de préstamo
Fecha de vencimiento
Estado

Estados con badges:

Activo
Atrasado
Devuelto

Funcionalidades:
	•	barra de búsqueda
	•	filtro por estado
	•	orden por fecha de vencimiento

Acciones por fila:

Ver préstamo
Renovar préstamo
Registrar devolución

⸻

Pantalla 2 – Registrar Nuevo Préstamo

Diseñar el flujo principal que utilizará el bibliotecario para prestar libros.

Diseño en dos columnas.

Columna izquierda – Información del usuario

Campo de búsqueda por:
	•	ID de usuario
	•	Nombre

Mostrar resumen del usuario:

Nombre
Tipo de usuario (Alumno / Profesor)
Libros prestados actualmente
Multas pendientes
Estado de elegibilidad

Indicador visual:

Verde → autorizado
Rojo → no autorizado

Un usuario no puede pedir préstamo si:
	•	tiene multas pendientes
	•	tiene más de 2 libros prestados
	•	tiene préstamos vencidos

⸻

Columna derecha – Selección del libro

Campo de búsqueda por:
	•	título
	•	autor
	•	ISBN

Mostrar copias disponibles.

Tabla con:

ID de copia
Ubicación
Estado

El bibliotecario selecciona una copia.

⸻

Modal de confirmación de préstamo

Mostrar:

Usuario
Libro
ID de copia
Fecha de préstamo
Fecha de vencimiento

Botones:

Confirmar préstamo
Cancelar

⸻

Pantalla 3 – Recibo de préstamo

Después de confirmar el préstamo, mostrar una pantalla o modal con el recibo.

Información mostrada:

ID del préstamo
Nombre del usuario
Título del libro
ID de copia
Fecha de préstamo
Fecha de vencimiento

Acciones:

Imprimir recibo
Enviar por correo
Enviar por WhatsApp

⸻

Pantalla 4 – Devolver Libro

Diseñar flujo para registrar devolución.

Campo de búsqueda por:
	•	ID de préstamo
	•	ID de usuario
	•	ID de copia

Mostrar información del préstamo:

Usuario
Libro
Fecha de préstamo
Fecha de vencimiento

El sistema debe calcular automáticamente si existe retraso.

Si hay retraso:

Mostrar multa generada.

Fórmula:

Multa = días de retraso × costo diario

Ejemplo:

10 pesos por día.

Botones:

Confirmar devolución
Cancelar

⸻

Pantalla 5 – Renovar Préstamo

Permitir renovación del préstamo desde el detalle del préstamo.

Mostrar:

Fecha actual de vencimiento
Número de renovaciones realizadas

Reglas:

El préstamo puede renovarse si:
	•	no está vencido
	•	no supera 2 renovaciones

Botón:

Renovar préstamo

Actualizar fecha de vencimiento.

⸻

Pantalla 6 – Lista de Espera

Si no hay copias disponibles de un libro, permitir agregar usuarios a una lista de espera.

Tabla con:

Libro
Usuario
Fecha de solicitud
Posición en la fila

Acciones:

Notificar siguiente usuario
Eliminar solicitud

⸻

Pantalla 7 – Gestión de Multas

Crear pantalla para administrar multas.

Tabla con columnas:

Usuario
Libro
Días de retraso
Monto de multa
Estado

Estados:

Pendiente
Pagado

Acciones:

Marcar como pagado
Ver préstamo relacionado

⸻

Reglas de UX

Seguir los mismos patrones del proyecto actual.

Utilizar:
	•	tablas para administración
	•	búsqueda rápida
	•	modales para formularios
	•	badges para estados

Las acciones principales deben poder completarse en máximo 3 clics.

⸻

Prototipo interactivo

Crear interacciones navegables entre pantallas:

Registrar préstamo
Confirmar préstamo
Generar recibo
Registrar devolución
Calcular multa
Renovar préstamo
Agregar a lista de espera

⸻

Estilo visual

Mantener el mismo estilo visual del sistema:

Dashboard administrativo
Diseño limpio
Interfaz clara
Jerarquía visual fuerte
Enfoque en tablas y gestión de datos
