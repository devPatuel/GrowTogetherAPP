import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ca'),
    Locale('en'),
    Locale('es'),
  ];

  /// Nombre de la aplicacion
  ///
  /// In es, this message translates to:
  /// **'GrowTogether'**
  String get appNombre;

  /// Saludo generico
  ///
  /// In es, this message translates to:
  /// **'Bienvenido'**
  String get bienvenido;

  /// Texto de proximamente
  ///
  /// In es, this message translates to:
  /// **'Próximamente'**
  String get proximamente;

  /// Boton de login
  ///
  /// In es, this message translates to:
  /// **'Iniciar Sesión'**
  String get iniciarSesion;

  /// Label del campo email
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get email;

  /// Label del campo contrasena
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get contrasena;

  /// Enlace a registro desde login
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta? Regístrate'**
  String get noTienesCuenta;

  /// Error de campos vacios
  ///
  /// In es, this message translates to:
  /// **'Rellena todos los campos'**
  String get rellenaTodosLosCampos;

  /// Titulo y boton de registro
  ///
  /// In es, this message translates to:
  /// **'Crear Cuenta'**
  String get crearCuenta;

  /// Label del campo nombre
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get nombre;

  /// Label del campo confirmar contrasena
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get confirmarContrasena;

  /// Enlace a login desde registro
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta? Inicia sesión'**
  String get yaTienesCuenta;

  /// Mensaje tras registro exitoso
  ///
  /// In es, this message translates to:
  /// **'Cuenta creada. Inicia sesión.'**
  String get cuentaCreada;

  /// Tab de inicio
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get inicio;

  /// Tab de analisis
  ///
  /// In es, this message translates to:
  /// **'Análisis'**
  String get analisis;

  /// Tab de desafios
  ///
  /// In es, this message translates to:
  /// **'Desafíos'**
  String get desafios;

  /// Tab de perfil
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get perfil;

  /// Placeholder pantalla inicio
  ///
  /// In es, this message translates to:
  /// **'Hola, estás en la pantalla de Inicio'**
  String get holaPantallaInicio;

  /// Placeholder pantalla analisis
  ///
  /// In es, this message translates to:
  /// **'Hola, estás en la pantalla de Análisis'**
  String get holaPantallaAnalisis;

  /// Placeholder pantalla desafios
  ///
  /// In es, this message translates to:
  /// **'Hola, estás en la pantalla de Desafíos'**
  String get holaPantallaDesafios;

  /// Seccion de info de cuenta en perfil
  ///
  /// In es, this message translates to:
  /// **'Información de cuenta'**
  String get informacionCuenta;

  /// Titulo dialogo editar nombre
  ///
  /// In es, this message translates to:
  /// **'Editar nombre'**
  String get editarNombre;

  /// Titulo dialogo editar email
  ///
  /// In es, this message translates to:
  /// **'Editar email'**
  String get editarEmail;

  /// Titulo dialogo cambiar contrasena
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get cambiarContrasena;

  /// Label campo contrasena actual
  ///
  /// In es, this message translates to:
  /// **'Contraseña actual'**
  String get contrasenaActual;

  /// Label campo nueva contrasena
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña'**
  String get nuevaContrasena;

  /// Boton guardar
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get guardar;

  /// Boton cancelar
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancelar;

  /// Etiqueta de puntos del usuario
  ///
  /// In es, this message translates to:
  /// **'puntos'**
  String get puntos;

  /// Boton cerrar sesion
  ///
  /// In es, this message translates to:
  /// **'Cerrar Sesión'**
  String get cerrarSesion;

  /// Confirmacion de cierre de sesion
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres cerrar sesión?'**
  String get confirmarCerrarSesion;

  /// Snackbar tras cambiar contrasena
  ///
  /// In es, this message translates to:
  /// **'Contraseña actualizada'**
  String get contrasenaActualizada;

  /// Snackbar tras actualizar perfil
  ///
  /// In es, this message translates to:
  /// **'Perfil actualizado'**
  String get perfilActualizado;

  /// Error cargando perfil
  ///
  /// In es, this message translates to:
  /// **'Error al cargar el perfil'**
  String get errorCargarPerfil;

  /// Boton reintentar
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get reintentar;

  /// Titulo bottom sheet foto
  ///
  /// In es, this message translates to:
  /// **'Cambiar foto de perfil'**
  String get cambiarFoto;

  /// Label campo URL foto
  ///
  /// In es, this message translates to:
  /// **'URL de la imagen'**
  String get urlFoto;

  /// Aviso al cambiar email
  ///
  /// In es, this message translates to:
  /// **'Cambiar el email cerrará tu sesión. ¿Continuar?'**
  String get confirmarCambioEmail;

  /// Aviso al cambiar contrasena
  ///
  /// In es, this message translates to:
  /// **'Cambiar la contraseña cerrará tu sesión. Tendrás que iniciar sesión de nuevo. ¿Continuar?'**
  String get confirmarCambioContrasena;

  /// Boton continuar
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get continuar;

  /// Mensaje tras cierre de sesion por cambio de credenciales
  ///
  /// In es, this message translates to:
  /// **'Sesión cerrada. Inicia sesión con tus nuevos datos.'**
  String get sesionCerradaPorCambio;

  /// Opcion quitar foto de perfil
  ///
  /// In es, this message translates to:
  /// **'Quitar foto'**
  String get quitarFoto;

  /// Opcion hacer foto con camara
  ///
  /// In es, this message translates to:
  /// **'Hacer foto'**
  String get tomarFoto;

  /// Opcion elegir de galeria
  ///
  /// In es, this message translates to:
  /// **'Elegir de galería'**
  String get elegirDeGaleria;

  /// Snackbar tras actualizar foto
  ///
  /// In es, this message translates to:
  /// **'Foto de perfil actualizada'**
  String get fotoActualizada;

  /// Snackbar tras eliminar foto
  ///
  /// In es, this message translates to:
  /// **'Foto de perfil eliminada'**
  String get fotoEliminada;

  /// Label campo confirmar nueva contrasena
  ///
  /// In es, this message translates to:
  /// **'Confirmar nueva contraseña'**
  String get confirmarNuevaContrasena;

  /// Error contrasenas no coinciden
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get contrasenasNoCoinciden;

  /// Saludo simple
  ///
  /// In es, this message translates to:
  /// **'Hola'**
  String get hola;

  /// Titulo seccion habitos del dia
  ///
  /// In es, this message translates to:
  /// **'Tus hábitos de hoy'**
  String get tusHabitosDeHoy;

  /// Titulo anillo de progreso
  ///
  /// In es, this message translates to:
  /// **'Progreso del día'**
  String get progresoDelDia;

  /// Mensaje cuando no hay habitos
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes hábitos'**
  String get sinHabitos;

  /// Texto motivacional sin habitos
  ///
  /// In es, this message translates to:
  /// **'Pulsa + para crear tu primer hábito y empezar a crecer'**
  String get sinHabitosMotivacion;

  /// Snackbar al completar habito
  ///
  /// In es, this message translates to:
  /// **'Hábito completado'**
  String get habitoCompletado;

  /// Error cargando habitos
  ///
  /// In es, this message translates to:
  /// **'Error al cargar hábitos'**
  String get errorCargarHabitos;

  /// Etiqueta de racha
  ///
  /// In es, this message translates to:
  /// **'racha'**
  String get racha;

  /// Titulo pantalla crear habito
  ///
  /// In es, this message translates to:
  /// **'Nuevo hábito'**
  String get nuevoHabito;

  /// Label campo nombre habito
  ///
  /// In es, this message translates to:
  /// **'Nombre del hábito'**
  String get nombreHabito;

  /// Label campo descripcion habito
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get descripcionHabito;

  /// Boton crear
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get crear;

  /// Snackbar tras crear habito
  ///
  /// In es, this message translates to:
  /// **'Hábito creado'**
  String get habitoCreado;

  /// Error nombre vacio
  ///
  /// In es, this message translates to:
  /// **'El nombre es obligatorio'**
  String get nombreObligatorio;

  /// Error descripcion vacia
  ///
  /// In es, this message translates to:
  /// **'La descripción es obligatoria'**
  String get descripcionObligatoria;

  /// Titulo seccion frecuencia
  ///
  /// In es, this message translates to:
  /// **'Frecuencia'**
  String get frecuencia;

  /// Opcion frecuencia diaria
  ///
  /// In es, this message translates to:
  /// **'Diario'**
  String get diario;

  /// Opcion frecuencia personalizada
  ///
  /// In es, this message translates to:
  /// **'Personalizado'**
  String get personalizado;

  /// Titulo selector dias
  ///
  /// In es, this message translates to:
  /// **'Días de la semana'**
  String get diasDeLaSemana;

  /// Error sin dias seleccionados
  ///
  /// In es, this message translates to:
  /// **'Selecciona al menos un día'**
  String get seleccionaAlMenosUnDia;

  /// Snackbar al desmarcar habito
  ///
  /// In es, this message translates to:
  /// **'Hábito desmarcado'**
  String get habitoDesmarcado;

  /// Lunes abreviado
  ///
  /// In es, this message translates to:
  /// **'L'**
  String get lun;

  /// Martes abreviado
  ///
  /// In es, this message translates to:
  /// **'M'**
  String get mar;

  /// Miercoles abreviado
  ///
  /// In es, this message translates to:
  /// **'X'**
  String get mie;

  /// Jueves abreviado
  ///
  /// In es, this message translates to:
  /// **'J'**
  String get jue;

  /// Viernes abreviado
  ///
  /// In es, this message translates to:
  /// **'V'**
  String get vie;

  /// Sabado abreviado
  ///
  /// In es, this message translates to:
  /// **'S'**
  String get sab;

  /// Domingo abreviado
  ///
  /// In es, this message translates to:
  /// **'D'**
  String get dom;

  /// Titulo seccion ajustes
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get ajustes;

  /// Label selector de tema
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get tema;

  /// Titulo bottom sheet temas
  ///
  /// In es, this message translates to:
  /// **'Elegir tema'**
  String get elegirTema;

  /// Label selector de idioma
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get idioma;

  /// Titulo bottom sheet idioma
  ///
  /// In es, this message translates to:
  /// **'Elegir idioma'**
  String get elegirIdioma;

  /// Nombre del idioma castellano
  ///
  /// In es, this message translates to:
  /// **'Castellano'**
  String get castellano;

  /// Nombre del idioma ingles
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get ingles;

  /// Nombre del idioma valenciano
  ///
  /// In es, this message translates to:
  /// **'Valencià'**
  String get valenciano;

  /// Saludo por la manana
  ///
  /// In es, this message translates to:
  /// **'Buenos días'**
  String get buenosDias;

  /// Saludo por la tarde
  ///
  /// In es, this message translates to:
  /// **'Buenas tardes'**
  String get buenasTardes;

  /// Saludo por la noche
  ///
  /// In es, this message translates to:
  /// **'Buenas noches'**
  String get buenasNoches;

  /// Contador de habitos completados
  ///
  /// In es, this message translates to:
  /// **'{completados} / {total} hábitos'**
  String habitosContador(int completados, int total);

  /// Error de validacion: email vacio
  ///
  /// In es, this message translates to:
  /// **'El email es obligatorio'**
  String get validatorEmailObligatorio;

  /// Error de validacion: email mal formado
  ///
  /// In es, this message translates to:
  /// **'Formato de email no válido'**
  String get validatorEmailInvalido;

  /// Error de validacion: contrasena vacia
  ///
  /// In es, this message translates to:
  /// **'La contraseña es obligatoria'**
  String get validatorContrasenaObligatoria;

  /// Error de validacion: contrasena corta
  ///
  /// In es, this message translates to:
  /// **'Mínimo 8 caracteres'**
  String get validatorContrasenaMinimo;

  /// Error de validacion: falta mayuscula
  ///
  /// In es, this message translates to:
  /// **'Debe contener una mayúscula'**
  String get validatorContrasenaMayuscula;

  /// Error de validacion: falta minuscula
  ///
  /// In es, this message translates to:
  /// **'Debe contener una minúscula'**
  String get validatorContrasenaMinuscula;

  /// Error de validacion: falta numero
  ///
  /// In es, this message translates to:
  /// **'Debe contener un número'**
  String get validatorContrasenaNumero;

  /// Error de validacion: campo obligatorio generico
  ///
  /// In es, this message translates to:
  /// **'{campo} es obligatorio'**
  String validatorCampoObligatorio(String campo);

  /// Error de validacion: confirmar contrasena vacia
  ///
  /// In es, this message translates to:
  /// **'Confirma la contraseña'**
  String get validatorConfirmarContrasena;

  /// Error de validacion: contrasenas diferentes
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get validatorContrasenasNoCoinciden;

  /// Lunes corto para subtitle habito
  ///
  /// In es, this message translates to:
  /// **'Lun'**
  String get diasCortoLun;

  /// Martes corto para subtitle habito
  ///
  /// In es, this message translates to:
  /// **'Mar'**
  String get diasCortoMar;

  /// Miercoles corto para subtitle habito
  ///
  /// In es, this message translates to:
  /// **'Mié'**
  String get diasCortoMie;

  /// Jueves corto para subtitle habito
  ///
  /// In es, this message translates to:
  /// **'Jue'**
  String get diasCortoJue;

  /// Viernes corto para subtitle habito
  ///
  /// In es, this message translates to:
  /// **'Vie'**
  String get diasCortoVie;

  /// Sabado corto para subtitle habito
  ///
  /// In es, this message translates to:
  /// **'Sáb'**
  String get diasCortoSab;

  /// Domingo corto para subtitle habito
  ///
  /// In es, this message translates to:
  /// **'Dom'**
  String get diasCortoDom;

  /// Titulo pantalla detalle habito
  ///
  /// In es, this message translates to:
  /// **'Detalle del hábito'**
  String get detalleHabito;

  /// Etiqueta racha actual
  ///
  /// In es, this message translates to:
  /// **'Racha actual'**
  String get rachaActual;

  /// Etiqueta mejor racha
  ///
  /// In es, this message translates to:
  /// **'Mejor racha'**
  String get mejorRacha;

  /// Palabra dias
  ///
  /// In es, this message translates to:
  /// **'días'**
  String get dias;

  /// Titulo seccion historial
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get historial;

  /// Boton editar habito
  ///
  /// In es, this message translates to:
  /// **'Editar hábito'**
  String get editarHabito;

  /// Boton eliminar habito
  ///
  /// In es, this message translates to:
  /// **'Eliminar hábito'**
  String get eliminarHabito;

  /// Confirmacion eliminar habito
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres eliminar este hábito? Esta acción no se puede deshacer.'**
  String get confirmarEliminarHabito;

  /// Snackbar tras eliminar habito
  ///
  /// In es, this message translates to:
  /// **'Hábito eliminado'**
  String get habitoEliminado;

  /// Snackbar tras actualizar habito
  ///
  /// In es, this message translates to:
  /// **'Hábito actualizado'**
  String get habitoActualizado;

  /// Estado completado en leyenda
  ///
  /// In es, this message translates to:
  /// **'Completado'**
  String get completado;

  /// Estado no completado en leyenda
  ///
  /// In es, this message translates to:
  /// **'No completado'**
  String get noCompletado;

  /// Estado pendiente en leyenda
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get pendiente;

  /// Chip frecuencia diaria
  ///
  /// In es, this message translates to:
  /// **'Diario'**
  String get frecuenciaDiaria;

  /// Chip frecuencia personalizada
  ///
  /// In es, this message translates to:
  /// **'Personalizado'**
  String get frecuenciaPersonalizada;

  /// Titulo del dialog de consejo diario
  ///
  /// In es, this message translates to:
  /// **'Consejo del día'**
  String get consejoDia;

  /// Boton para cerrar el dialog de consejo diario
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get entendido;

  /// Titulo selector tipo habito
  ///
  /// In es, this message translates to:
  /// **'Tipo de hábito'**
  String get tipoHabito;

  /// Opcion tipo positivo
  ///
  /// In es, this message translates to:
  /// **'Positivo'**
  String get tipoPositivo;

  /// Opcion tipo negativo
  ///
  /// In es, this message translates to:
  /// **'Negativo'**
  String get tipoNegativo;

  /// Descripcion tipo positivo
  ///
  /// In es, this message translates to:
  /// **'Un hábito que quieres construir y mantener'**
  String get tipoPositivoDesc;

  /// Descripcion tipo negativo
  ///
  /// In es, this message translates to:
  /// **'Un hábito que quieres dejar o reducir'**
  String get tipoNegativoDesc;

  /// Titulo selector icono habito
  ///
  /// In es, this message translates to:
  /// **'Icono'**
  String get iconoHabito;

  /// Titulo habitos cuando no es hoy
  ///
  /// In es, this message translates to:
  /// **'Hábitos del día'**
  String get habitosDelDia;

  /// Dias sin un habito negativo
  ///
  /// In es, this message translates to:
  /// **'{dias} {dias, plural, =1{día} other{días}} sin {nombre}'**
  String diasSinHabito(int dias, String nombre);

  /// Etiqueta dias sin recaer para habito negativo
  ///
  /// In es, this message translates to:
  /// **'Días sin recaer'**
  String get diasSinLabel;

  /// Mensaje de error generico
  ///
  /// In es, this message translates to:
  /// **'Ha ocurrido un error. Inténtalo de nuevo.'**
  String get errorGenerico;

  /// No description provided for @mesEnero.
  ///
  /// In es, this message translates to:
  /// **'Enero'**
  String get mesEnero;

  /// No description provided for @mesFebrero.
  ///
  /// In es, this message translates to:
  /// **'Febrero'**
  String get mesFebrero;

  /// No description provided for @mesMarzo.
  ///
  /// In es, this message translates to:
  /// **'Marzo'**
  String get mesMarzo;

  /// No description provided for @mesAbril.
  ///
  /// In es, this message translates to:
  /// **'Abril'**
  String get mesAbril;

  /// No description provided for @mesMayo.
  ///
  /// In es, this message translates to:
  /// **'Mayo'**
  String get mesMayo;

  /// No description provided for @mesJunio.
  ///
  /// In es, this message translates to:
  /// **'Junio'**
  String get mesJunio;

  /// No description provided for @mesJulio.
  ///
  /// In es, this message translates to:
  /// **'Julio'**
  String get mesJulio;

  /// No description provided for @mesAgosto.
  ///
  /// In es, this message translates to:
  /// **'Agosto'**
  String get mesAgosto;

  /// No description provided for @mesSeptiembre.
  ///
  /// In es, this message translates to:
  /// **'Septiembre'**
  String get mesSeptiembre;

  /// No description provided for @mesOctubre.
  ///
  /// In es, this message translates to:
  /// **'Octubre'**
  String get mesOctubre;

  /// No description provided for @mesNoviembre.
  ///
  /// In es, this message translates to:
  /// **'Noviembre'**
  String get mesNoviembre;

  /// No description provided for @mesDiciembre.
  ///
  /// In es, this message translates to:
  /// **'Diciembre'**
  String get mesDiciembre;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ca', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppLocalizationsCa();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
