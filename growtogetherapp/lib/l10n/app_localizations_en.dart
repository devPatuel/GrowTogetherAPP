// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appNombre => 'GrowTogether';

  @override
  String get bienvenido => 'Welcome';

  @override
  String get proximamente => 'Coming soon';

  @override
  String get iniciarSesion => 'Log In';

  @override
  String get email => 'Email';

  @override
  String get contrasena => 'Password';

  @override
  String get noTienesCuenta => 'Don\'t have an account? Sign up';

  @override
  String get rellenaTodosLosCampos => 'Fill in all fields';

  @override
  String get crearCuenta => 'Create Account';

  @override
  String get nombre => 'Name';

  @override
  String get confirmarContrasena => 'Confirm password';

  @override
  String get yaTienesCuenta => 'Already have an account? Log in';

  @override
  String get cuentaCreada => 'Account created. Please log in.';

  @override
  String get inicio => 'Home';

  @override
  String get analisis => 'Analytics';

  @override
  String get desafios => 'Challenges';

  @override
  String get perfil => 'Profile';

  @override
  String get holaPantallaInicio => 'Hello, you are on the Home screen';

  @override
  String get holaPantallaAnalisis => 'Hello, you are on the Analytics screen';

  @override
  String get holaPantallaDesafios => 'Hello, you are on the Challenges screen';

  @override
  String get informacionCuenta => 'Account information';

  @override
  String get editarNombre => 'Edit name';

  @override
  String get editarEmail => 'Edit email';

  @override
  String get cambiarContrasena => 'Change password';

  @override
  String get contrasenaActual => 'Current password';

  @override
  String get nuevaContrasena => 'New password';

  @override
  String get guardar => 'Save';

  @override
  String get cancelar => 'Cancel';

  @override
  String get puntos => 'points';

  @override
  String get cerrarSesion => 'Log Out';

  @override
  String get confirmarCerrarSesion => 'Are you sure you want to log out?';

  @override
  String get contrasenaActualizada => 'Password updated';

  @override
  String get perfilActualizado => 'Profile updated';

  @override
  String get errorCargarPerfil => 'Error loading profile';

  @override
  String get reintentar => 'Retry';

  @override
  String get cambiarFoto => 'Change profile photo';

  @override
  String get urlFoto => 'Image URL';

  @override
  String get confirmarCambioEmail =>
      'Changing your email will log you out. Continue?';

  @override
  String get confirmarCambioContrasena =>
      'Changing your password will log you out. You will need to log in again. Continue?';

  @override
  String get continuar => 'Continue';

  @override
  String get sesionCerradaPorCambio =>
      'Session closed. Log in with your new credentials.';

  @override
  String get quitarFoto => 'Remove photo';

  @override
  String get tomarFoto => 'Take photo';

  @override
  String get elegirDeGaleria => 'Choose from gallery';

  @override
  String get fotoActualizada => 'Profile photo updated';

  @override
  String get fotoEliminada => 'Profile photo removed';

  @override
  String get confirmarNuevaContrasena => 'Confirm new password';

  @override
  String get contrasenasNoCoinciden => 'Passwords do not match';

  @override
  String get hola => 'Hello';

  @override
  String get tusHabitosDeHoy => 'Your habits for today';

  @override
  String get progresoDelDia => 'Today\'s progress';

  @override
  String get sinHabitos => 'You don\'t have any habits yet';

  @override
  String get sinHabitosMotivacion =>
      'Tap + to create your first habit and start growing';

  @override
  String get habitoCompletado => 'Habit completed';

  @override
  String get errorCargarHabitos => 'Error loading habits';

  @override
  String get racha => 'streak';

  @override
  String get nuevoHabito => 'New habit';

  @override
  String get nombreHabito => 'Habit name';

  @override
  String get descripcionHabito => 'Description';

  @override
  String get crear => 'Create';

  @override
  String get habitoCreado => 'Habit created';

  @override
  String get nombreObligatorio => 'Name is required';

  @override
  String get descripcionObligatoria => 'Description is required';

  @override
  String get frecuencia => 'Frequency';

  @override
  String get diario => 'Daily';

  @override
  String get personalizado => 'Custom';

  @override
  String get diasDeLaSemana => 'Days of the week';

  @override
  String get seleccionaAlMenosUnDia => 'Select at least one day';

  @override
  String get habitoDesmarcado => 'Habit unchecked';

  @override
  String get lun => 'M';

  @override
  String get mar => 'T';

  @override
  String get mie => 'W';

  @override
  String get jue => 'T';

  @override
  String get vie => 'F';

  @override
  String get sab => 'S';

  @override
  String get dom => 'S';

  @override
  String get ajustes => 'Settings';

  @override
  String get tema => 'Theme';

  @override
  String get elegirTema => 'Choose theme';

  @override
  String get idioma => 'Language';

  @override
  String get elegirIdioma => 'Choose language';

  @override
  String get castellano => 'Castellano';

  @override
  String get ingles => 'English';

  @override
  String get valenciano => 'Valencià';

  @override
  String get buenosDias => 'Good morning';

  @override
  String get buenasTardes => 'Good afternoon';

  @override
  String get buenasNoches => 'Good evening';

  @override
  String habitosContador(int completados, int total) {
    return '$completados / $total habits';
  }

  @override
  String get validatorEmailObligatorio => 'Email is required';

  @override
  String get validatorEmailInvalido => 'Invalid email format';

  @override
  String get validatorContrasenaObligatoria => 'Password is required';

  @override
  String get validatorContrasenaRequisitos =>
      'Password must contain at least 8 characters, an uppercase letter, a lowercase letter, a number and a special character';

  @override
  String validatorCampoObligatorio(String campo) {
    return '$campo is required';
  }

  @override
  String get validatorConfirmarContrasena => 'Confirm the password';

  @override
  String get validatorContrasenasNoCoinciden => 'Passwords do not match';

  @override
  String get diasCortoLun => 'Mon';

  @override
  String get diasCortoMar => 'Tue';

  @override
  String get diasCortoMie => 'Wed';

  @override
  String get diasCortoJue => 'Thu';

  @override
  String get diasCortoVie => 'Fri';

  @override
  String get diasCortoSab => 'Sat';

  @override
  String get diasCortoDom => 'Sun';

  @override
  String get detalleHabito => 'Habit details';

  @override
  String get rachaActual => 'Current streak';

  @override
  String get mejorRacha => 'Best streak';

  @override
  String get dias => 'days';

  @override
  String get historial => 'History';

  @override
  String get editarHabito => 'Edit habit';

  @override
  String get eliminarHabito => 'Delete habit';

  @override
  String get confirmarEliminarHabito =>
      'Are you sure you want to delete this habit? This action cannot be undone.';

  @override
  String get habitoEliminado => 'Habit deleted';

  @override
  String get habitoActualizado => 'Habit updated';

  @override
  String get completado => 'Completed';

  @override
  String get noCompletado => 'Not completed';

  @override
  String get pendiente => 'Pending';

  @override
  String get frecuenciaDiaria => 'Daily';

  @override
  String get frecuenciaPersonalizada => 'Custom';

  @override
  String get consejoDia => 'Tip of the day';

  @override
  String get entendido => 'Got it';

  @override
  String get tipoHabito => 'Habit type';

  @override
  String get tipoPositivo => 'Positive';

  @override
  String get tipoNegativo => 'Negative';

  @override
  String get tipoPositivoDesc => 'A habit you want to build and maintain';

  @override
  String get tipoNegativoDesc => 'A habit you want to quit or reduce';

  @override
  String get iconoHabito => 'Icon';

  @override
  String get habitosDelDia => 'Habits for this day';

  @override
  String diasSinHabito(int dias, String nombre) {
    String _temp0 = intl.Intl.pluralLogic(
      dias,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return '$dias $_temp0 without $nombre';
  }

  @override
  String get diasSinLabel => 'Days without relapse';

  @override
  String get errorGenerico => 'Something went wrong. Please try again.';

  @override
  String get mesEnero => 'January';

  @override
  String get mesFebrero => 'February';

  @override
  String get mesMarzo => 'March';

  @override
  String get mesAbril => 'April';

  @override
  String get mesMayo => 'May';

  @override
  String get mesJunio => 'June';

  @override
  String get mesJulio => 'July';

  @override
  String get mesAgosto => 'August';

  @override
  String get mesSeptiembre => 'September';

  @override
  String get mesOctubre => 'October';

  @override
  String get mesNoviembre => 'November';

  @override
  String get mesDiciembre => 'December';

  @override
  String get actividadGeneral => 'Overall activity';

  @override
  String get recordsRachas => 'Streak records';

  @override
  String get porHabito => 'By habit';

  @override
  String get totalCompletados => 'Total completed';

  @override
  String get mejorRachaGlobal => 'Best streak';

  @override
  String get promedioDiario => 'Daily average';

  @override
  String get habitosActivos => 'Active habits';

  @override
  String get detalleGeneral => 'Overall detail';

  @override
  String get resumenGeneral => 'Overall summary';

  @override
  String ultimosDias(int dias) {
    return 'Last $dias days';
  }

  @override
  String get sinRacha => 'No streak';

  @override
  String get menos => 'Less';

  @override
  String get mas => 'More';

  @override
  String get sinDatosEstadisticas =>
      'When you create habits, you\'ll see your stats here';

  @override
  String rachaPlural(int dias) {
    String _temp0 = intl.Intl.pluralLogic(
      dias,
      locale: localeName,
      other: '$dias days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get marcarComoCompletado => 'Mark as completed';

  @override
  String get desmarcar => 'Unmark';

  @override
  String get cambiarEstado => 'Change state';

  @override
  String get estadoCompletado => 'Completed';

  @override
  String get estadoNoCompletado => 'Not completed';

  @override
  String get estadoPendiente => 'Pending';

  @override
  String get temaClaro => 'Light';

  @override
  String get temaOscuro => 'Dark';

  @override
  String get temaMorado => 'Purple';

  @override
  String get temaNaturaleza => 'Nature';

  @override
  String get buscarAmigos => 'Find friends';

  @override
  String get misAmigos => 'My friends';

  @override
  String get amigos => 'Friends';

  @override
  String get peticiones => 'Requests';

  @override
  String peticionesConContador(int n) {
    return 'Requests ($n)';
  }

  @override
  String get buscarPorNombreOId => 'Search by name or ID';

  @override
  String get enviarSolicitud => 'Send request';

  @override
  String get solicitudEnviada => 'Request sent';

  @override
  String get aceptar => 'Accept';

  @override
  String get rechazar => 'Decline';

  @override
  String get eliminarAmigo => 'Remove friend';

  @override
  String confirmarEliminarAmigo(String nombre) {
    return 'Remove $nombre from your friends?';
  }

  @override
  String get sinAmigosTodavia =>
      'You don\'t have friends yet. Use the + icon to find users';

  @override
  String get sinPeticionesPendientes => 'No pending requests';

  @override
  String get peticionesRecibidas => 'Received';

  @override
  String get peticionesEnviadas => 'Sent';

  @override
  String get cancelarSolicitud => 'Cancel request';

  @override
  String confirmarCancelarSolicitud(String nombre) {
    return 'Cancel the request sent to $nombre?';
  }

  @override
  String get sinPeticionesEnviadas => 'No sent requests';

  @override
  String get sinResultadosBusqueda => 'No users found';

  @override
  String get usuarioEscribeParaBuscar => 'Type a name or ID to search';
}
