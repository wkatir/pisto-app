///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'translations.g.dart';

// Path: <root>
class TranslationsEs with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsEs({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.es,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <es>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	late final TranslationsEs _root = this; // ignore: unused_field

	@override 
	TranslationsEs $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsEs(meta: meta ?? this.$meta);

	// Translations
	@override String get appTitle => 'Pisto';
	@override String get financialManagement => 'Gestión Financiera';
	@override String get email => 'Correo electrónico';
	@override String get password => 'Contraseña';
	@override String get login => 'Iniciar Sesión';
	@override String get logout => 'Cerrar Sesión';
	@override String get register => 'Registrarse';
	@override String get signUp => 'Crear Cuenta';
	@override String get dontHaveAccount => '¿No tienes cuenta? Regístrate';
	@override String get alreadyHaveAccount => '¿Ya tienes cuenta? Inicia sesión';
	@override String get dashboard => 'Dashboard';
	@override String welcome({required Object name}) => 'Bienvenido, ${name}';
	@override String get inventory => 'Inventario';
	@override String get sales => 'Ventas';
	@override String get collections => 'Cobranza';
	@override String get purchases => 'Compras';
	@override String get reports => 'Reportes';
	@override String get products => 'Productos';
	@override String get categories => 'Categorías';
	@override String get warehouses => 'Bodegas';
	@override String get units => 'Unidades';
	@override String get movements => 'Movimientos';
	@override String get transfers => 'Transferencias';
	@override String get alerts => 'Alertas';
	@override String get customers => 'Clientes';
	@override String get invoices => 'Facturas';
	@override String get creditNotes => 'Notas de Crédito';
	@override String get accountsReceivable => 'Cuentas por Cobrar';
	@override String get payments => 'Pagos';
	@override String get agingReport => 'Reporte de Antigüedad';
	@override String get suppliers => 'Proveedores';
	@override String get purchaseOrders => 'Órdenes de Compra';
	@override String get receiving => 'Recepción';
	@override String get accountsPayable => 'Cuentas por Pagar';
	@override String get kpis => 'KPIs';
	@override String get salesSummary => 'Resumen de Ventas';
	@override String get topProducts => 'Productos Top';
	@override String get grossMargin => 'Margen Bruto';
	@override String get inventoryValuation => 'Valuación de Inventario';
	@override String get exports => 'Exportación';
	@override String get excel => 'Excel';
	@override String get csv => 'CSV';
	@override String get pdf => 'PDF';
	@override String get monthlySales => 'Ventas del Mes';
	@override String get salesTrend => 'Tendencia de Ventas (30 días)';
	@override String get salesByCategory => 'Ventas por Categoría';
	@override String get topProductsByRevenue => 'Top 5 Productos por Ingresos';
	@override String get byDate => 'por fecha';
	@override String invoicesCount({required Object count}) => '${count} facturas';
	@override String accounts({required Object count}) => '${count} cuentas';
	@override String get lowStock => 'Stock Bajo';
	@override String get products_low => 'productos';
	@override String get averagePerSale => 'Promedio/Venta';
	@override String get thisMonth => 'este mes';
	@override String get pending => 'Pendiente';
	@override String get received => 'Recibido';
	@override String get refresh => 'Actualizar';
	@override String get save => 'Guardar';
	@override String get cancel => 'Cancelar';
	@override String get delete => 'Eliminar';
	@override String get edit => 'Editar';
	@override String get add => 'Agregar';
	@override String get search => 'Buscar';
	@override String get filter => 'Filtrar';
	@override String get actions => 'Acciones';
	@override String get name => 'Nombre';
	@override String get description => 'Descripción';
	@override String get price => 'Precio';
	@override String get quantity => 'Cantidad';
	@override String get total => 'Total';
	@override String get subtotal => 'Subtotal';
	@override String get tax => 'Impuesto';
	@override String get discount => 'Descuento';
	@override String get date => 'Fecha';
	@override String get status => 'Estado';
	@override String get active => 'Activo';
	@override String get inactive => 'Inactivo';
	@override String get required => 'Requerido';
	@override String minChars({required Object count}) => 'Mínimo ${count} caracteres';
	@override String get invalidEmail => 'Correo inválido';
	@override String get emailRequired => 'Correo requerido';
	@override String get passwordRequired => 'Contraseña requerida';
	@override String get theme => 'Tema';
	@override String get systemTheme => 'Sistema';
	@override String get lightTheme => 'Claro';
	@override String get darkTheme => 'Oscuro';
	@override String get expenses => 'Gastos';
	@override String get settings => 'Configuración';
	@override String get language => 'Idioma';
	@override String get getStarted => 'Empezar';
	@override String get createAccount => 'Crear Cuenta';
	@override String get startFree => 'Empieza Gratis';
	@override String get viewDemo => 'Ver Demo';
	@override String get managementForSMEs => 'Gestión financiera para PYMES';
	@override String get controlYourBusiness => 'Controla tu negocio\nen un solo lugar';
	@override String get everythingNeeded => 'Inventario, ventas, compras, cobranza y reportes. Todo lo que necesitas para tomar mejores decisiones y hacer crecer tu empresa.';
	@override String get features => 'Todo lo que necesitas';
	@override String get featuresSubtitle => 'Módulos diseñados para gestionar cada área de tu negocio';
	@override String get howItWorks => 'Empieza en 3 pasos';
	@override String step({required Object number}) => 'Paso ${number}';
	@override String get createYourAccount => 'Crea tu cuenta';
	@override String get signupInMinute => 'Regístrate gratis en menos de un minuto. Sin tarjeta de crédito.';
	@override String get configureYourBusiness => 'Configura tu negocio';
	@override String get addProductsCustomers => 'Agrega tus productos, clientes y proveedores. Importa datos si ya los tienes.';
	@override String get startSelling => 'Empieza a vender';
	@override String get invoiceCollectBuy => 'Factura, cobra, compra y genera reportes. Tu negocio bajo control.';
	@override String get readyToTakeControl => '¿Listo para tomar el control?';
	@override String get joinCompanies => 'Únete a las empresas que ya gestionan su negocio con Pisto.';
	@override String get createFreeAccount => 'Crear Cuenta Gratis';
	@override String get allRightsReserved => '© 2026 Pisto App. Todos los derechos reservados.';
	@override String get financialManagementSystem => 'Gestión Financiera y Ventas';
	@override String get startIn3Steps => 'Empieza en 3 pasos';
	@override String get empresasActivas => 'Empresas activas';
	@override String get facturasProcesadas => 'Facturas procesadas';
	@override String get uptimeGarantedizado => 'Uptime garantizado';
	@override String get soporteTecnico => 'Soporte técnico';
	@override String get inventario => 'Inventario';
	@override String get inventarioDesc => 'Control de productos, categorías, bodegas, transferencias y alertas de stock bajo en tiempo real.';
	@override String get ventas => 'Ventas';
	@override String get ventasDesc => 'Facturación rápida, gestión de clientes, notas de crédito y seguimiento de pagos.';
	@override String get compras => 'Compras';
	@override String get comprasDesc => 'Órdenes de compra, gestión de proveedores, recepción de mercadería y cuentas por pagar.';
	@override String get cobranza => 'Cobranza';
	@override String get cobranzaDesc => 'Cuentas por cobrar, registro de abonos, estado de cuenta por cliente y reporte de antigüedad.';
	@override String get reportesDesc => 'Dashboard con KPIs, tendencias de venta, top productos, margen bruto y valuación de inventario.';
	@override String get exportacion => 'Exportación';
	@override String get exportacionDesc => 'Genera reportes en Excel, CSV y PDF para compartir con tu equipo o contador.';
	@override String get gestionFinancieraPYMES => 'Gestión financiera para PYMES';
	@override String get enUnSoloLugar => 'Controla tu negocio\nen un solo lugar';
	@override String get todoLoNecesario => 'Inventario, ventas, compras, cobranza y reportes. Todo lo que necesitas para tomar mejores decisiones y hacer crecer tu empresa.';
	@override String get empiezaGratis => 'Empieza Gratis';
	@override String get verDemo => 'Ver Demo';
	@override String get todoLoQueNecesitas => 'Todo lo que necesitas';
	@override String get modulosDisenados => 'Módulos diseñados para gestionar cada área de tu negocio';
	@override String get empiezaEn3Pasos => 'Empieza en 3 pasos';
	@override String get creaTuCuenta => 'Crea tu cuenta';
	@override String get registrateGratis => 'Regístrate gratis en menos de un minuto. Sin tarjeta de crédito.';
	@override String get configuraTuNegocio => 'Configura tu negocio';
	@override String get agregaProductosClientes => 'Agrega tus productos, clientes y proveedores. Importa datos si ya los tienes.';
	@override String get empiezaAVender => 'Empieza a vender';
	@override String get facturaCobraCompra => 'Factura, cobra, compra y genera reportes. Tu negocio bajo control.';
	@override String get listoParaTomarControl => '¿Listo para tomar el control?';
	@override String get uneteEmpresas => 'Únete a las empresas que ya gestionan su negocio con Pisto.';
	@override String get crearCuentaGratis => 'Crear Cuenta Gratis';
	@override String get todosDerechosReservados => '© 2026 Pisto App. Todos los derechos reservados.';
	@override String get sistemaGestionFinanciera => 'Gestión Financiera y Ventas';
	@override String get pricing => 'Precios';
	@override String get trustedBySmbs => 'Más de 500 PYMEs confían en Pisto';
}

/// The flat map containing all translations for locale <es>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsEs {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'appTitle' => 'Pisto',
			'financialManagement' => 'Gestión Financiera',
			'email' => 'Correo electrónico',
			'password' => 'Contraseña',
			'login' => 'Iniciar Sesión',
			'logout' => 'Cerrar Sesión',
			'register' => 'Registrarse',
			'signUp' => 'Crear Cuenta',
			'dontHaveAccount' => '¿No tienes cuenta? Regístrate',
			'alreadyHaveAccount' => '¿Ya tienes cuenta? Inicia sesión',
			'dashboard' => 'Dashboard',
			'welcome' => ({required Object name}) => 'Bienvenido, ${name}',
			'inventory' => 'Inventario',
			'sales' => 'Ventas',
			'collections' => 'Cobranza',
			'purchases' => 'Compras',
			'reports' => 'Reportes',
			'products' => 'Productos',
			'categories' => 'Categorías',
			'warehouses' => 'Bodegas',
			'units' => 'Unidades',
			'movements' => 'Movimientos',
			'transfers' => 'Transferencias',
			'alerts' => 'Alertas',
			'customers' => 'Clientes',
			'invoices' => 'Facturas',
			'creditNotes' => 'Notas de Crédito',
			'accountsReceivable' => 'Cuentas por Cobrar',
			'payments' => 'Pagos',
			'agingReport' => 'Reporte de Antigüedad',
			'suppliers' => 'Proveedores',
			'purchaseOrders' => 'Órdenes de Compra',
			'receiving' => 'Recepción',
			'accountsPayable' => 'Cuentas por Pagar',
			'kpis' => 'KPIs',
			'salesSummary' => 'Resumen de Ventas',
			'topProducts' => 'Productos Top',
			'grossMargin' => 'Margen Bruto',
			'inventoryValuation' => 'Valuación de Inventario',
			'exports' => 'Exportación',
			'excel' => 'Excel',
			'csv' => 'CSV',
			'pdf' => 'PDF',
			'monthlySales' => 'Ventas del Mes',
			'salesTrend' => 'Tendencia de Ventas (30 días)',
			'salesByCategory' => 'Ventas por Categoría',
			'topProductsByRevenue' => 'Top 5 Productos por Ingresos',
			'byDate' => 'por fecha',
			'invoicesCount' => ({required Object count}) => '${count} facturas',
			'accounts' => ({required Object count}) => '${count} cuentas',
			'lowStock' => 'Stock Bajo',
			'products_low' => 'productos',
			'averagePerSale' => 'Promedio/Venta',
			'thisMonth' => 'este mes',
			'pending' => 'Pendiente',
			'received' => 'Recibido',
			'refresh' => 'Actualizar',
			'save' => 'Guardar',
			'cancel' => 'Cancelar',
			'delete' => 'Eliminar',
			'edit' => 'Editar',
			'add' => 'Agregar',
			'search' => 'Buscar',
			'filter' => 'Filtrar',
			'actions' => 'Acciones',
			'name' => 'Nombre',
			'description' => 'Descripción',
			'price' => 'Precio',
			'quantity' => 'Cantidad',
			'total' => 'Total',
			'subtotal' => 'Subtotal',
			'tax' => 'Impuesto',
			'discount' => 'Descuento',
			'date' => 'Fecha',
			'status' => 'Estado',
			'active' => 'Activo',
			'inactive' => 'Inactivo',
			'required' => 'Requerido',
			'minChars' => ({required Object count}) => 'Mínimo ${count} caracteres',
			'invalidEmail' => 'Correo inválido',
			'emailRequired' => 'Correo requerido',
			'passwordRequired' => 'Contraseña requerida',
			'theme' => 'Tema',
			'systemTheme' => 'Sistema',
			'lightTheme' => 'Claro',
			'darkTheme' => 'Oscuro',
			'expenses' => 'Gastos',
			'settings' => 'Configuración',
			'language' => 'Idioma',
			'getStarted' => 'Empezar',
			'createAccount' => 'Crear Cuenta',
			'startFree' => 'Empieza Gratis',
			'viewDemo' => 'Ver Demo',
			'managementForSMEs' => 'Gestión financiera para PYMES',
			'controlYourBusiness' => 'Controla tu negocio\nen un solo lugar',
			'everythingNeeded' => 'Inventario, ventas, compras, cobranza y reportes. Todo lo que necesitas para tomar mejores decisiones y hacer crecer tu empresa.',
			'features' => 'Todo lo que necesitas',
			'featuresSubtitle' => 'Módulos diseñados para gestionar cada área de tu negocio',
			'howItWorks' => 'Empieza en 3 pasos',
			'step' => ({required Object number}) => 'Paso ${number}',
			'createYourAccount' => 'Crea tu cuenta',
			'signupInMinute' => 'Regístrate gratis en menos de un minuto. Sin tarjeta de crédito.',
			'configureYourBusiness' => 'Configura tu negocio',
			'addProductsCustomers' => 'Agrega tus productos, clientes y proveedores. Importa datos si ya los tienes.',
			'startSelling' => 'Empieza a vender',
			'invoiceCollectBuy' => 'Factura, cobra, compra y genera reportes. Tu negocio bajo control.',
			'readyToTakeControl' => '¿Listo para tomar el control?',
			'joinCompanies' => 'Únete a las empresas que ya gestionan su negocio con Pisto.',
			'createFreeAccount' => 'Crear Cuenta Gratis',
			'allRightsReserved' => '© 2026 Pisto App. Todos los derechos reservados.',
			'financialManagementSystem' => 'Gestión Financiera y Ventas',
			'startIn3Steps' => 'Empieza en 3 pasos',
			'empresasActivas' => 'Empresas activas',
			'facturasProcesadas' => 'Facturas procesadas',
			'uptimeGarantedizado' => 'Uptime garantizado',
			'soporteTecnico' => 'Soporte técnico',
			'inventario' => 'Inventario',
			'inventarioDesc' => 'Control de productos, categorías, bodegas, transferencias y alertas de stock bajo en tiempo real.',
			'ventas' => 'Ventas',
			'ventasDesc' => 'Facturación rápida, gestión de clientes, notas de crédito y seguimiento de pagos.',
			'compras' => 'Compras',
			'comprasDesc' => 'Órdenes de compra, gestión de proveedores, recepción de mercadería y cuentas por pagar.',
			'cobranza' => 'Cobranza',
			'cobranzaDesc' => 'Cuentas por cobrar, registro de abonos, estado de cuenta por cliente y reporte de antigüedad.',
			'reportesDesc' => 'Dashboard con KPIs, tendencias de venta, top productos, margen bruto y valuación de inventario.',
			'exportacion' => 'Exportación',
			'exportacionDesc' => 'Genera reportes en Excel, CSV y PDF para compartir con tu equipo o contador.',
			'gestionFinancieraPYMES' => 'Gestión financiera para PYMES',
			'enUnSoloLugar' => 'Controla tu negocio\nen un solo lugar',
			'todoLoNecesario' => 'Inventario, ventas, compras, cobranza y reportes. Todo lo que necesitas para tomar mejores decisiones y hacer crecer tu empresa.',
			'empiezaGratis' => 'Empieza Gratis',
			'verDemo' => 'Ver Demo',
			'todoLoQueNecesitas' => 'Todo lo que necesitas',
			'modulosDisenados' => 'Módulos diseñados para gestionar cada área de tu negocio',
			'empiezaEn3Pasos' => 'Empieza en 3 pasos',
			'creaTuCuenta' => 'Crea tu cuenta',
			'registrateGratis' => 'Regístrate gratis en menos de un minuto. Sin tarjeta de crédito.',
			'configuraTuNegocio' => 'Configura tu negocio',
			'agregaProductosClientes' => 'Agrega tus productos, clientes y proveedores. Importa datos si ya los tienes.',
			'empiezaAVender' => 'Empieza a vender',
			'facturaCobraCompra' => 'Factura, cobra, compra y genera reportes. Tu negocio bajo control.',
			'listoParaTomarControl' => '¿Listo para tomar el control?',
			'uneteEmpresas' => 'Únete a las empresas que ya gestionan su negocio con Pisto.',
			'crearCuentaGratis' => 'Crear Cuenta Gratis',
			'todosDerechosReservados' => '© 2026 Pisto App. Todos los derechos reservados.',
			'sistemaGestionFinanciera' => 'Gestión Financiera y Ventas',
			'pricing' => 'Precios',
			'trustedBySmbs' => 'Más de 500 PYMEs confían en Pisto',
			_ => null,
		};
	}
}
