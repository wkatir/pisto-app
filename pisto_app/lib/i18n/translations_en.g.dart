///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'translations.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations

	/// en: 'Pisto'
	String get appTitle => 'Pisto';

	/// en: 'Financial Management'
	String get financialManagement => 'Financial Management';

	/// en: 'Email'
	String get email => 'Email';

	/// en: 'Password'
	String get password => 'Password';

	/// en: 'Login'
	String get login => 'Login';

	/// en: 'Logout'
	String get logout => 'Logout';

	/// en: 'Register'
	String get register => 'Register';

	/// en: 'Sign Up'
	String get signUp => 'Sign Up';

	/// en: 'Don't have an account? Sign up'
	String get dontHaveAccount => 'Don\'t have an account? Sign up';

	/// en: 'Already have an account? Login'
	String get alreadyHaveAccount => 'Already have an account? Login';

	/// en: 'Dashboard'
	String get dashboard => 'Dashboard';

	/// en: 'Welcome, $name'
	String welcome({required Object name}) => 'Welcome, ${name}';

	/// en: 'Inventory'
	String get inventory => 'Inventory';

	/// en: 'Sales'
	String get sales => 'Sales';

	/// en: 'Collections'
	String get collections => 'Collections';

	/// en: 'Purchases'
	String get purchases => 'Purchases';

	/// en: 'Reports'
	String get reports => 'Reports';

	/// en: 'Products'
	String get products => 'Products';

	/// en: 'Categories'
	String get categories => 'Categories';

	/// en: 'Warehouses'
	String get warehouses => 'Warehouses';

	/// en: 'Units'
	String get units => 'Units';

	/// en: 'Movements'
	String get movements => 'Movements';

	/// en: 'Transfers'
	String get transfers => 'Transfers';

	/// en: 'Alerts'
	String get alerts => 'Alerts';

	/// en: 'Customers'
	String get customers => 'Customers';

	/// en: 'Invoices'
	String get invoices => 'Invoices';

	/// en: 'Credit Notes'
	String get creditNotes => 'Credit Notes';

	/// en: 'Accounts Receivable'
	String get accountsReceivable => 'Accounts Receivable';

	/// en: 'Payments'
	String get payments => 'Payments';

	/// en: 'Aging Report'
	String get agingReport => 'Aging Report';

	/// en: 'Suppliers'
	String get suppliers => 'Suppliers';

	/// en: 'Purchase Orders'
	String get purchaseOrders => 'Purchase Orders';

	/// en: 'Receiving'
	String get receiving => 'Receiving';

	/// en: 'Accounts Payable'
	String get accountsPayable => 'Accounts Payable';

	/// en: 'KPIs'
	String get kpis => 'KPIs';

	/// en: 'Sales Summary'
	String get salesSummary => 'Sales Summary';

	/// en: 'Top Products'
	String get topProducts => 'Top Products';

	/// en: 'Gross Margin'
	String get grossMargin => 'Gross Margin';

	/// en: 'Inventory Valuation'
	String get inventoryValuation => 'Inventory Valuation';

	/// en: 'Exports'
	String get exports => 'Exports';

	/// en: 'Excel'
	String get excel => 'Excel';

	/// en: 'CSV'
	String get csv => 'CSV';

	/// en: 'PDF'
	String get pdf => 'PDF';

	/// en: 'Monthly Sales'
	String get monthlySales => 'Monthly Sales';

	/// en: 'Sales Trend (30 days)'
	String get salesTrend => 'Sales Trend (30 days)';

	/// en: 'Sales by Category'
	String get salesByCategory => 'Sales by Category';

	/// en: 'Top 5 Products by Revenue'
	String get topProductsByRevenue => 'Top 5 Products by Revenue';

	/// en: 'by date'
	String get byDate => 'by date';

	/// en: '$count invoices'
	String invoicesCount({required Object count}) => '${count} invoices';

	/// en: '$count accounts'
	String accounts({required Object count}) => '${count} accounts';

	/// en: 'Low Stock'
	String get lowStock => 'Low Stock';

	/// en: 'products'
	String get products_low => 'products';

	/// en: 'Average/Sale'
	String get averagePerSale => 'Average/Sale';

	/// en: 'this month'
	String get thisMonth => 'this month';

	/// en: 'Pending'
	String get pending => 'Pending';

	/// en: 'Received'
	String get received => 'Received';

	/// en: 'Refresh'
	String get refresh => 'Refresh';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'Add'
	String get add => 'Add';

	/// en: 'Search'
	String get search => 'Search';

	/// en: 'Filter'
	String get filter => 'Filter';

	/// en: 'Actions'
	String get actions => 'Actions';

	/// en: 'Name'
	String get name => 'Name';

	/// en: 'Description'
	String get description => 'Description';

	/// en: 'Price'
	String get price => 'Price';

	/// en: 'Quantity'
	String get quantity => 'Quantity';

	/// en: 'Total'
	String get total => 'Total';

	/// en: 'Subtotal'
	String get subtotal => 'Subtotal';

	/// en: 'Tax'
	String get tax => 'Tax';

	/// en: 'Discount'
	String get discount => 'Discount';

	/// en: 'Date'
	String get date => 'Date';

	/// en: 'Status'
	String get status => 'Status';

	/// en: 'Active'
	String get active => 'Active';

	/// en: 'Inactive'
	String get inactive => 'Inactive';

	/// en: 'Required'
	String get required => 'Required';

	/// en: 'Minimum $count characters'
	String minChars({required Object count}) => 'Minimum ${count} characters';

	/// en: 'Invalid email'
	String get invalidEmail => 'Invalid email';

	/// en: 'Email required'
	String get emailRequired => 'Email required';

	/// en: 'Password required'
	String get passwordRequired => 'Password required';

	/// en: 'Theme'
	String get theme => 'Theme';

	/// en: 'System'
	String get systemTheme => 'System';

	/// en: 'Light'
	String get lightTheme => 'Light';

	/// en: 'Dark'
	String get darkTheme => 'Dark';

	/// en: 'Expenses'
	String get expenses => 'Expenses';

	/// en: 'Settings'
	String get settings => 'Settings';

	/// en: 'Language'
	String get language => 'Language';

	/// en: 'Get Started'
	String get getStarted => 'Get Started';

	/// en: 'Create Account'
	String get createAccount => 'Create Account';

	/// en: 'Start Free'
	String get startFree => 'Start Free';

	/// en: 'View Demo'
	String get viewDemo => 'View Demo';

	/// en: 'Financial management for SMEs'
	String get managementForSMEs => 'Financial management for SMEs';

	/// en: 'Control your business in one place'
	String get controlYourBusiness => 'Control your business\nin one place';

	/// en: 'Inventory, sales, purchases, collections and reports. Everything you need to make better decisions and grow your company.'
	String get everythingNeeded => 'Inventory, sales, purchases, collections and reports. Everything you need to make better decisions and grow your company.';

	/// en: 'Everything you need'
	String get features => 'Everything you need';

	/// en: 'Modules designed to manage every area of your business'
	String get featuresSubtitle => 'Modules designed to manage every area of your business';

	/// en: 'Get started in 3 steps'
	String get howItWorks => 'Get started in 3 steps';

	/// en: 'Step $number'
	String step({required Object number}) => 'Step ${number}';

	/// en: 'Create your account'
	String get createYourAccount => 'Create your account';

	/// en: 'Sign up for free in under a minute. No credit card.'
	String get signupInMinute => 'Sign up for free in under a minute. No credit card.';

	/// en: 'Configure your business'
	String get configureYourBusiness => 'Configure your business';

	/// en: 'Add your products, customers and suppliers. Import data if you already have it.'
	String get addProductsCustomers => 'Add your products, customers and suppliers. Import data if you already have it.';

	/// en: 'Start selling'
	String get startSelling => 'Start selling';

	/// en: 'Invoice, collect, buy and generate reports. Your business under control.'
	String get invoiceCollectBuy => 'Invoice, collect, buy and generate reports. Your business under control.';

	/// en: 'Ready to take control?'
	String get readyToTakeControl => 'Ready to take control?';

	/// en: 'Join the companies already managing their business with Pisto.'
	String get joinCompanies => 'Join the companies already managing their business with Pisto.';

	/// en: 'Create Free Account'
	String get createFreeAccount => 'Create Free Account';

	/// en: '© 2026 Pisto App. All rights reserved.'
	String get allRightsReserved => '© 2026 Pisto App. All rights reserved.';

	/// en: 'Financial and Sales Management'
	String get financialManagementSystem => 'Financial and Sales Management';

	/// en: 'Get started in 3 steps'
	String get startIn3Steps => 'Get started in 3 steps';

	/// en: 'Active companies'
	String get empresasActivas => 'Active companies';

	/// en: 'Invoices processed'
	String get facturasProcesadas => 'Invoices processed';

	/// en: 'Uptime guaranteed'
	String get uptimeGarantedizado => 'Uptime guaranteed';

	/// en: 'Technical support'
	String get soporteTecnico => 'Technical support';

	/// en: 'Inventory'
	String get inventario => 'Inventory';

	/// en: 'Product control, categories, warehouses, transfers and real-time low stock alerts.'
	String get inventarioDesc => 'Product control, categories, warehouses, transfers and real-time low stock alerts.';

	/// en: 'Sales'
	String get ventas => 'Sales';

	/// en: 'Fast invoicing, customer management, credit notes and payment tracking.'
	String get ventasDesc => 'Fast invoicing, customer management, credit notes and payment tracking.';

	/// en: 'Purchases'
	String get compras => 'Purchases';

	/// en: 'Purchase orders, supplier management, merchandise receiving and accounts payable.'
	String get comprasDesc => 'Purchase orders, supplier management, merchandise receiving and accounts payable.';

	/// en: 'Collections'
	String get cobranza => 'Collections';

	/// en: 'Accounts receivable, payment registration, account statement by customer and aging report.'
	String get cobranzaDesc => 'Accounts receivable, payment registration, account statement by customer and aging report.';

	/// en: 'Dashboard with KPIs, sales trends, top products, gross margin and inventory valuation.'
	String get reportesDesc => 'Dashboard with KPIs, sales trends, top products, gross margin and inventory valuation.';

	/// en: 'Export'
	String get exportacion => 'Export';

	/// en: 'Generate reports in Excel, CSV and PDF to share with your team or accountant.'
	String get exportacionDesc => 'Generate reports in Excel, CSV and PDF to share with your team or accountant.';

	/// en: 'Financial management for PYMES'
	String get gestionFinancieraPYMES => 'Financial management for PYMES';

	/// en: 'Control your business in one place'
	String get enUnSoloLugar => 'Control your business\nin one place';

	/// en: 'Inventory, sales, purchases, collections and reports. Everything you need to make better decisions and grow your company.'
	String get todoLoNecesario => 'Inventory, sales, purchases, collections and reports. Everything you need to make better decisions and grow your company.';

	/// en: 'Get Started Free'
	String get empiezaGratis => 'Get Started Free';

	/// en: 'View Demo'
	String get verDemo => 'View Demo';

	/// en: 'Everything you need'
	String get todoLoQueNecesitas => 'Everything you need';

	/// en: 'Modules designed to manage every area of your business'
	String get modulosDisenados => 'Modules designed to manage every area of your business';

	/// en: 'Get started in 3 steps'
	String get empiezaEn3Pasos => 'Get started in 3 steps';

	/// en: 'Create your account'
	String get creaTuCuenta => 'Create your account';

	/// en: 'Sign up for free in under a minute. No credit card.'
	String get registrateGratis => 'Sign up for free in under a minute. No credit card.';

	/// en: 'Configure your business'
	String get configuraTuNegocio => 'Configure your business';

	/// en: 'Add your products, customers and suppliers. Import data if you already have it.'
	String get agregaProductosClientes => 'Add your products, customers and suppliers. Import data if you already have it.';

	/// en: 'Start selling'
	String get empiezaAVender => 'Start selling';

	/// en: 'Invoice, collect, buy and generate reports. Your business under control.'
	String get facturaCobraCompra => 'Invoice, collect, buy and generate reports. Your business under control.';

	/// en: 'Ready to take control?'
	String get listoParaTomarControl => 'Ready to take control?';

	/// en: 'Join the companies already managing their business with Pisto.'
	String get uneteEmpresas => 'Join the companies already managing their business with Pisto.';

	/// en: 'Create Free Account'
	String get crearCuentaGratis => 'Create Free Account';

	/// en: '© 2026 Pisto App. All rights reserved.'
	String get todosDerechosReservados => '© 2026 Pisto App. All rights reserved.';

	/// en: 'Financial and Sales Management'
	String get sistemaGestionFinanciera => 'Financial and Sales Management';

	/// en: 'Pricing'
	String get pricing => 'Pricing';

	/// en: 'Trusted by 500+ SMBs across Central America'
	String get trustedBySmbs => 'Trusted by 500+ SMBs across Central America';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'appTitle' => 'Pisto',
			'financialManagement' => 'Financial Management',
			'email' => 'Email',
			'password' => 'Password',
			'login' => 'Login',
			'logout' => 'Logout',
			'register' => 'Register',
			'signUp' => 'Sign Up',
			'dontHaveAccount' => 'Don\'t have an account? Sign up',
			'alreadyHaveAccount' => 'Already have an account? Login',
			'dashboard' => 'Dashboard',
			'welcome' => ({required Object name}) => 'Welcome, ${name}',
			'inventory' => 'Inventory',
			'sales' => 'Sales',
			'collections' => 'Collections',
			'purchases' => 'Purchases',
			'reports' => 'Reports',
			'products' => 'Products',
			'categories' => 'Categories',
			'warehouses' => 'Warehouses',
			'units' => 'Units',
			'movements' => 'Movements',
			'transfers' => 'Transfers',
			'alerts' => 'Alerts',
			'customers' => 'Customers',
			'invoices' => 'Invoices',
			'creditNotes' => 'Credit Notes',
			'accountsReceivable' => 'Accounts Receivable',
			'payments' => 'Payments',
			'agingReport' => 'Aging Report',
			'suppliers' => 'Suppliers',
			'purchaseOrders' => 'Purchase Orders',
			'receiving' => 'Receiving',
			'accountsPayable' => 'Accounts Payable',
			'kpis' => 'KPIs',
			'salesSummary' => 'Sales Summary',
			'topProducts' => 'Top Products',
			'grossMargin' => 'Gross Margin',
			'inventoryValuation' => 'Inventory Valuation',
			'exports' => 'Exports',
			'excel' => 'Excel',
			'csv' => 'CSV',
			'pdf' => 'PDF',
			'monthlySales' => 'Monthly Sales',
			'salesTrend' => 'Sales Trend (30 days)',
			'salesByCategory' => 'Sales by Category',
			'topProductsByRevenue' => 'Top 5 Products by Revenue',
			'byDate' => 'by date',
			'invoicesCount' => ({required Object count}) => '${count} invoices',
			'accounts' => ({required Object count}) => '${count} accounts',
			'lowStock' => 'Low Stock',
			'products_low' => 'products',
			'averagePerSale' => 'Average/Sale',
			'thisMonth' => 'this month',
			'pending' => 'Pending',
			'received' => 'Received',
			'refresh' => 'Refresh',
			'save' => 'Save',
			'cancel' => 'Cancel',
			'delete' => 'Delete',
			'edit' => 'Edit',
			'add' => 'Add',
			'search' => 'Search',
			'filter' => 'Filter',
			'actions' => 'Actions',
			'name' => 'Name',
			'description' => 'Description',
			'price' => 'Price',
			'quantity' => 'Quantity',
			'total' => 'Total',
			'subtotal' => 'Subtotal',
			'tax' => 'Tax',
			'discount' => 'Discount',
			'date' => 'Date',
			'status' => 'Status',
			'active' => 'Active',
			'inactive' => 'Inactive',
			'required' => 'Required',
			'minChars' => ({required Object count}) => 'Minimum ${count} characters',
			'invalidEmail' => 'Invalid email',
			'emailRequired' => 'Email required',
			'passwordRequired' => 'Password required',
			'theme' => 'Theme',
			'systemTheme' => 'System',
			'lightTheme' => 'Light',
			'darkTheme' => 'Dark',
			'expenses' => 'Expenses',
			'settings' => 'Settings',
			'language' => 'Language',
			'getStarted' => 'Get Started',
			'createAccount' => 'Create Account',
			'startFree' => 'Start Free',
			'viewDemo' => 'View Demo',
			'managementForSMEs' => 'Financial management for SMEs',
			'controlYourBusiness' => 'Control your business\nin one place',
			'everythingNeeded' => 'Inventory, sales, purchases, collections and reports. Everything you need to make better decisions and grow your company.',
			'features' => 'Everything you need',
			'featuresSubtitle' => 'Modules designed to manage every area of your business',
			'howItWorks' => 'Get started in 3 steps',
			'step' => ({required Object number}) => 'Step ${number}',
			'createYourAccount' => 'Create your account',
			'signupInMinute' => 'Sign up for free in under a minute. No credit card.',
			'configureYourBusiness' => 'Configure your business',
			'addProductsCustomers' => 'Add your products, customers and suppliers. Import data if you already have it.',
			'startSelling' => 'Start selling',
			'invoiceCollectBuy' => 'Invoice, collect, buy and generate reports. Your business under control.',
			'readyToTakeControl' => 'Ready to take control?',
			'joinCompanies' => 'Join the companies already managing their business with Pisto.',
			'createFreeAccount' => 'Create Free Account',
			'allRightsReserved' => '© 2026 Pisto App. All rights reserved.',
			'financialManagementSystem' => 'Financial and Sales Management',
			'startIn3Steps' => 'Get started in 3 steps',
			'empresasActivas' => 'Active companies',
			'facturasProcesadas' => 'Invoices processed',
			'uptimeGarantedizado' => 'Uptime guaranteed',
			'soporteTecnico' => 'Technical support',
			'inventario' => 'Inventory',
			'inventarioDesc' => 'Product control, categories, warehouses, transfers and real-time low stock alerts.',
			'ventas' => 'Sales',
			'ventasDesc' => 'Fast invoicing, customer management, credit notes and payment tracking.',
			'compras' => 'Purchases',
			'comprasDesc' => 'Purchase orders, supplier management, merchandise receiving and accounts payable.',
			'cobranza' => 'Collections',
			'cobranzaDesc' => 'Accounts receivable, payment registration, account statement by customer and aging report.',
			'reportesDesc' => 'Dashboard with KPIs, sales trends, top products, gross margin and inventory valuation.',
			'exportacion' => 'Export',
			'exportacionDesc' => 'Generate reports in Excel, CSV and PDF to share with your team or accountant.',
			'gestionFinancieraPYMES' => 'Financial management for PYMES',
			'enUnSoloLugar' => 'Control your business\nin one place',
			'todoLoNecesario' => 'Inventory, sales, purchases, collections and reports. Everything you need to make better decisions and grow your company.',
			'empiezaGratis' => 'Get Started Free',
			'verDemo' => 'View Demo',
			'todoLoQueNecesitas' => 'Everything you need',
			'modulosDisenados' => 'Modules designed to manage every area of your business',
			'empiezaEn3Pasos' => 'Get started in 3 steps',
			'creaTuCuenta' => 'Create your account',
			'registrateGratis' => 'Sign up for free in under a minute. No credit card.',
			'configuraTuNegocio' => 'Configure your business',
			'agregaProductosClientes' => 'Add your products, customers and suppliers. Import data if you already have it.',
			'empiezaAVender' => 'Start selling',
			'facturaCobraCompra' => 'Invoice, collect, buy and generate reports. Your business under control.',
			'listoParaTomarControl' => 'Ready to take control?',
			'uneteEmpresas' => 'Join the companies already managing their business with Pisto.',
			'crearCuentaGratis' => 'Create Free Account',
			'todosDerechosReservados' => '© 2026 Pisto App. All rights reserved.',
			'sistemaGestionFinanciera' => 'Financial and Sales Management',
			'pricing' => 'Pricing',
			'trustedBySmbs' => 'Trusted by 500+ SMBs across Central America',
			_ => null,
		};
	}
}
