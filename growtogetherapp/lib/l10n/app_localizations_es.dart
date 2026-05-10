// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appNombre => 'GrowTogether';

  @override
  String get bienvenido => 'Bienvenido';

  @override
  String get proximamente => 'Próximamente';

  @override
  String get iniciarSesion => 'Iniciar Sesión';

  @override
  String get email => 'Email';

  @override
  String get contrasena => 'Contraseña';

  @override
  String get noTienesCuenta => '¿No tienes cuenta? Regístrate';

  @override
  String get rellenaTodosLosCampos => 'Rellena todos los campos';

  @override
  String get crearCuenta => 'Crear Cuenta';

  @override
  String get nombre => 'Nombre';

  @override
  String get confirmarContrasena => 'Confirmar contraseña';

  @override
  String get yaTienesCuenta => '¿Ya tienes cuenta? Inicia sesión';

  @override
  String get cuentaCreada => 'Cuenta creada. Inicia sesión.';

  @override
  String get inicio => 'Inicio';

  @override
  String get analisis => 'Análisis';

  @override
  String get desafios => 'Desafíos';

  @override
  String get perfil => 'Perfil';

  @override
  String get holaPantallaInicio => 'Hola, estás en la pantalla de Inicio';

  @override
  String get holaPantallaAnalisis => 'Hola, estás en la pantalla de Análisis';

  @override
  String get holaPantallaDesafios => 'Hola, estás en la pantalla de Desafíos';

  @override
  String get informacionCuenta => 'Información de cuenta';

  @override
  String get editarNombre => 'Editar nombre';

  @override
  String get editarEmail => 'Editar email';

  @override
  String get cambiarContrasena => 'Cambiar contraseña';

  @override
  String get contrasenaActual => 'Contraseña actual';

  @override
  String get nuevaContrasena => 'Nueva contraseña';

  @override
  String get guardar => 'Guardar';

  @override
  String get cancelar => 'Cancelar';

  @override
  String get puntos => 'puntos';

  @override
  String get cerrarSesion => 'Cerrar Sesión';

  @override
  String get confirmarCerrarSesion => '¿Seguro que quieres cerrar sesión?';

  @override
  String get contrasenaActualizada => 'Contraseña actualizada';

  @override
  String get perfilActualizado => 'Perfil actualizado';

  @override
  String get errorCargarPerfil => 'Error al cargar el perfil';

  @override
  String get reintentar => 'Reintentar';

  @override
  String get cambiarFoto => 'Cambiar foto de perfil';

  @override
  String get urlFoto => 'URL de la imagen';

  @override
  String get confirmarCambioEmail =>
      'Cambiar el email cerrará tu sesión. ¿Continuar?';

  @override
  String get confirmarCambioContrasena =>
      'Cambiar la contraseña cerrará tu sesión. Tendrás que iniciar sesión de nuevo. ¿Continuar?';

  @override
  String get continuar => 'Continuar';

  @override
  String get sesionCerradaPorCambio =>
      'Sesión cerrada. Inicia sesión con tus nuevos datos.';

  @override
  String get quitarFoto => 'Quitar foto';

  @override
  String get tomarFoto => 'Hacer foto';

  @override
  String get elegirDeGaleria => 'Elegir de galería';

  @override
  String get fotoActualizada => 'Foto de perfil actualizada';

  @override
  String get fotoEliminada => 'Foto de perfil eliminada';

  @override
  String get confirmarNuevaContrasena => 'Confirmar nueva contraseña';

  @override
  String get contrasenasNoCoinciden => 'Las contraseñas no coinciden';

  @override
  String get hola => 'Hola';

  @override
  String get tusHabitosDeHoy => 'Tus hábitos de hoy';

  @override
  String get progresoDelDia => 'Progreso del día';

  @override
  String get sinHabitos => 'Aún no tienes hábitos';

  @override
  String get sinHabitosMotivacion =>
      'Pulsa + para crear tu primer hábito y empezar a crecer';

  @override
  String get habitoCompletado => 'Hábito completado';

  @override
  String get errorCargarHabitos => 'Error al cargar hábitos';

  @override
  String get racha => 'racha';

  @override
  String get nuevoHabito => 'Nuevo hábito';

  @override
  String get nombreHabito => 'Nombre del hábito';

  @override
  String get descripcionHabito => 'Descripción';

  @override
  String get crear => 'Crear';

  @override
  String get habitoCreado => 'Hábito creado';

  @override
  String get nombreObligatorio => 'El nombre es obligatorio';

  @override
  String get descripcionObligatoria => 'La descripción es obligatoria';

  @override
  String get frecuencia => 'Frecuencia';

  @override
  String get diario => 'Diario';

  @override
  String get personalizado => 'Personalizado';

  @override
  String get diasDeLaSemana => 'Días de la semana';

  @override
  String get seleccionaAlMenosUnDia => 'Selecciona al menos un día';

  @override
  String get habitoDesmarcado => 'Hábito desmarcado';

  @override
  String get lun => 'L';

  @override
  String get mar => 'M';

  @override
  String get mie => 'X';

  @override
  String get jue => 'J';

  @override
  String get vie => 'V';

  @override
  String get sab => 'S';

  @override
  String get dom => 'D';

  @override
  String get ajustes => 'Ajustes';

  @override
  String get tema => 'Tema';

  @override
  String get elegirTema => 'Elegir tema';

  @override
  String get idioma => 'Idioma';

  @override
  String get elegirIdioma => 'Elegir idioma';

  @override
  String get castellano => 'Castellano';

  @override
  String get ingles => 'English';

  @override
  String get valenciano => 'Valencià';

  @override
  String get buenosDias => 'Buenos días';

  @override
  String get buenasTardes => 'Buenas tardes';

  @override
  String get buenasNoches => 'Buenas noches';

  @override
  String habitosContador(int completados, int total) {
    return '$completados / $total hábitos';
  }

  @override
  String get validatorEmailObligatorio => 'El email es obligatorio';

  @override
  String get validatorEmailInvalido => 'Formato de email no válido';

  @override
  String get validatorContrasenaObligatoria => 'La contraseña es obligatoria';

  @override
  String get validatorContrasenaRequisitos =>
      'La contraseña debe contener al menos 8 caracteres, una mayúscula, una minúscula, un número y un carácter especial';

  @override
  String validatorCampoObligatorio(String campo) {
    return '$campo es obligatorio';
  }

  @override
  String get validatorConfirmarContrasena => 'Confirma la contraseña';

  @override
  String get validatorContrasenasNoCoinciden => 'Las contraseñas no coinciden';

  @override
  String get diasCortoLun => 'Lun';

  @override
  String get diasCortoMar => 'Mar';

  @override
  String get diasCortoMie => 'Mié';

  @override
  String get diasCortoJue => 'Jue';

  @override
  String get diasCortoVie => 'Vie';

  @override
  String get diasCortoSab => 'Sáb';

  @override
  String get diasCortoDom => 'Dom';

  @override
  String get detalleHabito => 'Detalle del hábito';

  @override
  String get rachaActual => 'Racha actual';

  @override
  String get mejorRacha => 'Mejor racha';

  @override
  String get dias => 'días';

  @override
  String get historial => 'Historial';

  @override
  String get editarHabito => 'Editar hábito';

  @override
  String get eliminarHabito => 'Eliminar hábito';

  @override
  String get confirmarEliminarHabito =>
      '¿Seguro que quieres eliminar este hábito? Esta acción no se puede deshacer.';

  @override
  String get habitoEliminado => 'Hábito eliminado';

  @override
  String get habitoActualizado => 'Hábito actualizado';

  @override
  String get completado => 'Completado';

  @override
  String get noCompletado => 'No completado';

  @override
  String get pendiente => 'Pendiente';

  @override
  String get frecuenciaDiaria => 'Diario';

  @override
  String get frecuenciaPersonalizada => 'Personalizado';

  @override
  String get consejoDia => 'Consejo del día';

  @override
  String get entendido => 'Entendido';

  @override
  String get tipoHabito => 'Tipo de hábito';

  @override
  String get tipoPositivo => 'Positivo';

  @override
  String get tipoNegativo => 'Negativo';

  @override
  String get tipoPositivoDesc => 'Un hábito que quieres construir y mantener';

  @override
  String get tipoNegativoDesc => 'Un hábito que quieres dejar o reducir';

  @override
  String get iconoHabito => 'Icono';

  @override
  String get habitosDelDia => 'Hábitos del día';

  @override
  String diasSinHabito(int dias, String nombre) {
    String _temp0 = intl.Intl.pluralLogic(
      dias,
      locale: localeName,
      other: 'días',
      one: 'día',
    );
    return '$dias $_temp0 sin $nombre';
  }

  @override
  String get diasSinLabel => 'Días sin recaer';

  @override
  String get errorGenerico => 'Ha ocurrido un error. Inténtalo de nuevo.';

  @override
  String get mesEnero => 'Enero';

  @override
  String get mesFebrero => 'Febrero';

  @override
  String get mesMarzo => 'Marzo';

  @override
  String get mesAbril => 'Abril';

  @override
  String get mesMayo => 'Mayo';

  @override
  String get mesJunio => 'Junio';

  @override
  String get mesJulio => 'Julio';

  @override
  String get mesAgosto => 'Agosto';

  @override
  String get mesSeptiembre => 'Septiembre';

  @override
  String get mesOctubre => 'Octubre';

  @override
  String get mesNoviembre => 'Noviembre';

  @override
  String get mesDiciembre => 'Diciembre';

  @override
  String get actividadGeneral => 'Actividad general';

  @override
  String get recordsRachas => 'Records de rachas';

  @override
  String get porHabito => 'Por hábito';

  @override
  String get totalCompletados => 'Total completados';

  @override
  String get mejorRachaGlobal => 'Mejor racha';

  @override
  String get promedioDiario => 'Media diaria';

  @override
  String get habitosActivos => 'Hábitos activos';

  @override
  String get detalleGeneral => 'Detalle general';

  @override
  String get resumenGeneral => 'Resumen general';

  @override
  String ultimosDias(int dias) {
    return 'Últimos $dias días';
  }

  @override
  String get sinRacha => 'Sin racha';

  @override
  String get menos => 'Menos';

  @override
  String get mas => 'Más';

  @override
  String get sinDatosEstadisticas =>
      'Cuando crees hábitos, aquí verás tus estadísticas';

  @override
  String rachaPlural(int dias) {
    String _temp0 = intl.Intl.pluralLogic(
      dias,
      locale: localeName,
      other: '$dias días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get marcarComoCompletado => 'Marcar como completado';

  @override
  String get desmarcar => 'Desmarcar';

  @override
  String get cambiarEstado => 'Cambiar estado';

  @override
  String get estadoCompletado => 'Completado';

  @override
  String get estadoNoCompletado => 'No completado';

  @override
  String get estadoPendiente => 'Pendiente';

  @override
  String get temaClaro => 'Claro';

  @override
  String get temaOscuro => 'Oscuro';

  @override
  String get temaMorado => 'Morado';

  @override
  String get temaNaturaleza => 'Naturaleza';

  @override
  String get buscarAmigos => 'Buscar amigos';

  @override
  String get misAmigos => 'Mis amigos';

  @override
  String get amigos => 'Amigos';

  @override
  String get peticiones => 'Peticiones';

  @override
  String peticionesConContador(int n) {
    return 'Peticiones ($n)';
  }

  @override
  String get buscarPorNombreOId => 'Buscar por nombre o ID';

  @override
  String get enviarSolicitud => 'Enviar solicitud';

  @override
  String get solicitudEnviada => 'Solicitud enviada';

  @override
  String get aceptar => 'Aceptar';

  @override
  String get rechazar => 'Rechazar';

  @override
  String get eliminarAmigo => 'Eliminar amigo';

  @override
  String confirmarEliminarAmigo(String nombre) {
    return '¿Eliminar a $nombre de tus amigos?';
  }

  @override
  String get sinAmigosTodavia =>
      'Aún no tienes amigos. Busca usuarios con el icono +';

  @override
  String get sinPeticionesPendientes => 'No tienes peticiones pendientes';

  @override
  String get peticionesRecibidas => 'Recibidas';

  @override
  String get peticionesEnviadas => 'Enviadas';

  @override
  String get cancelarSolicitud => 'Cancelar solicitud';

  @override
  String confirmarCancelarSolicitud(String nombre) {
    return '¿Cancelar la solicitud enviada a $nombre?';
  }

  @override
  String get sinPeticionesEnviadas => 'No tienes peticiones enviadas';

  @override
  String get sinResultadosBusqueda => 'No se han encontrado usuarios';

  @override
  String get usuarioEscribeParaBuscar =>
      'Escribe un nombre o un ID para buscar';
}
