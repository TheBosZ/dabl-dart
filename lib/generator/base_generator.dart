part of dabl_generator;

abstract class BaseGenerator {
	Map<String, Object> _options = {
		// enforce an upper case first letter of get and set methods
		'cap_method_names': true,

		// prepend this to class name
		'model_prefix': '',

		// append this to class name
		'model_suffix': '',

		// target directory for generated table classes
		'model_path': null,

		// target directory for generated base table classes
		'base_model_path': null,

		'model_query_path': null,

		'base_model_query_path': null,

		// set to true to generate views
		'view_path': null,

		// directory to save controller files in
		'controller_path': null
	};

	set options(Map<String, Object> opts) {
		_options.addAll(opts);
	}

	Map<String, Object> get options => _options;

	Map<String, String> _viewTemplates = {
    		'edit.php': '/templates/edit.php',
    		'index.php': '/templates/index.php',
    		'grid.php': '/templates/grid.php',
    		'show.php': '/templates/show.php'
	};

	Map<String, String> get viewTemplates => _viewTemplates;

	String _connectionName;

	set connectionName(String name) => _connectionName = name;

	String get connectionName => _connectionName;

	//@var DOMDocument
	XmlElement _dbSchema;

	set schema(XmlElement sch) => _dbSchema = sch;

	XmlElement get schema => _dbSchema;

	//@var Database
	Database _database;

	String _baseModelTemplate = '/templates/base-model.dart';

	String get baseModelTemplate => _baseModelTemplate;

	String _baseModelQueryTemplate = '/templates/base-model-query.dart';

	String _modelTemplate = '/templates/model.dart';

	String get modelTemplate => _modelTemplate;

	String _controllerTemplate = '/templates/controller.dart';

	String get controllerTemplate => _controllerTemplate;

	BaseGenerator(String this._connectionName);

	Future<bool> initialize() {
		Completer c = new Completer();
		if(_database == null) {
			DABLDDO conn = DBManager.getConnection(_connectionName);
			conn.getDatabaseSchema().then((Database db){
				_database = db;
				XmlElement root = new XmlElement('root');
				db.appendXml(root);
				_dbSchema = root.children.first;
				c.complete(true);
			});
		} else {
			c.complete(true);
		}
		return c.future;
	}

	List<String> getTableNames() => _database.getTables().map((Table t) => t.getName()).toList();

	List<Column> getColumns(String tableName) => _database.getTable(tableName).getColumns();

	List<Column> getPrimaryKeys(String tableName) => _database.getTable(tableName).getPrimaryKey();

	List<ForeignKey> getForeignKeysFromTable(String tableName) => _database.getTable(tableName).getForeignKeys();

	List<ForeignKey> getForeignKeysToTable(String tableName) => _database.getTable(tableName).getReferrers();

	String getDBName() => DBManager.getConnection(_connectionName).getDBName();

	Map<String, Object> getTemplateParams(String tableName) {
		String className = getModelName(tableName);
		List<String> columnNames = new List<String>();
		List<String> PKs = new List<String>();
		bool autoIncrement = false;
		List<Column> columns = getColumns(tableName);
		List<Column> pks = getPrimaryKeys(tableName);
		String pk;

		for(Column c in columns) {
			columnNames.add(c.getName());
			if(c.isPrimaryKey()) {
				PKs.add(c.getName());
				if(c.isAutoIncrement()) {
					autoIncrement = true;
				}
			}
		}

		if(PKs.length == 1) {
			pk = PKs.first;
		} else {
			autoIncrement = false;
		}

		return {
			'auto_increment': autoIncrement,
			'table_name': tableName,
			'controller_name': getControllerName(tableName),
			'model_name': className,
			'column_names': columnNames,
			'plural': StringFormat.pluralVariable(tableName),
			'plural_url': StringFormat.pluralUrl(tableName),
			'single': StringFormat.variable(tableName),
			'single_url': StringFormat.url(tableName),
			'pk': pk,
			'primary_keys': pks,
			'pk_method': pk != null ? StringFormat.classMethod('get${StringFormat.titleCase(pk)}') : null,
			'pk_var': pk != null ? StringFormat.variable(pk) : null,
			'actions': getActions(tableName),
			'columns': columns,
		};
	}

	Map<String, String> getActions(String tableName);

	String renderTemplate(String tableName, String template, [Map<String, String> extraParams = null]) {
		Map<String, String> params = getTemplateParams(tableName);
		params.addAll(extraParams);

		throw UnimplementedError;
	}

	String getModelName(String tableName) {
		String className = StringFormat.className(tableName);

		if(_options.containsKey('model_prefix')){
			className = "${_options['model_prefix'].toString()}${className}";
		}

		if(_options.containsKey('model_suffix')) {
			className = "${className}${_options['model_suffix']}";
		}

		return className;
	}

	String getViewDirName(String tableName) => StringFormat.pluralUrl(tableName);

	String getControllerName(String tableName) {
		String conName = StringFormat.plural(tableName);
		return "${StringFormat.className(conName)}Controller";
	}

	String getControllerFileName(String tableName) => "${getControllerName(tableName)}.dart";

	String getProjectName() => "${getDBName()}Project";

	Future<String> getBaseModel(String tableName) {
		Completer c = new Completer();
		String className = getModelName(tableName);
		initialize().then((bool result) {
			List<Column> fields = getColumns(tableName);
			DABLDDO conn = DBManager.getConnection(connectionName);
			bool autoIncrement = false;
			List<Column> PKs = new List<Column>();
			Column PK;

			for(Column field in fields) {
				if(field.isPrimaryKey()) {
					PKs.add(field);
					if(field.isAutoIncrement()) {
						autoIncrement = true;
					}
				}
			}

			if(PKs.length == 1) {
				PK = PKs.first;
			} else {
				autoIncrement = false;
			}

			BaseModelGenerator bmg = getBaseModelGenerator();
			bmg.className = className;
			bmg.fields = fields;
			bmg.tableName = tableName;
			bmg.PK = PK;
			bmg.PKs = PKs;
			bmg.autoIncrement = autoIncrement;
			bmg.conn = conn;
			bmg.connectionName = connectionName;
			bmg.fromTable = getForeignKeysFromTable(tableName);
			bmg.toTable = getForeignKeysToTable(tableName);
			bmg.baseGenerator = this;

			c.complete(bmg.getFileContents());
		});
		return c.future;
	}

	BaseModelGenerator getBaseModelGenerator() => new BaseModelGenerator();

	String getModel(String tableName) {
		ModelGenerator mg = getModelGenerator();
		mg.baseGenerator = this;
		mg.className = getModelName(tableName);
		return mg.getFileContents();
	}

	ModelGenerator getModelGenerator() => new ModelGenerator();

	String getModelQuery(String tableName) {
		ModelQueryGenerator mqg = getModelQueryGenerator();
		mqg.baseGenerator = this;
		mqg.modelName = getModelName(tableName);
		return mqg.getFileContents();
	}

	ModelQueryGenerator getModelQueryGenerator() => new ModelQueryGenerator();

	Future<String> getBaseModelQuery(String tableName) {
		Completer c = new Completer();
		initialize().then((_){
			BaseModelQueryGenerator mbqg = getBaseModelQueryGenerator();
			c.complete(mbqg.getFileContents());
		});
		return c.future;
	}

	BaseModelQueryGenerator getBaseModelQueryGenerator() => new BaseModelQueryGenerator();

	Future<List<String>> generateModels([List<String> tableNames = null]) {
		Completer c = new Completer();
		initialize().then((_) {
			if(tableNames == null) {
				tableNames = getTableNames();
			} else if(tableNames.isEmpty) {
				return;
			}
			if(!_options.containsKey('base_model_path') || _options['base_model_path'] == null) {
				throw new Exception('base_mode_path not defined');
			}
			if(!_options.containsKey('model_path') || _options['model_path'] == null) {
				throw new Exception('model_path not defined');
			}
			String baseModelPath = _options['base_model_path'];
			String modelPath = _options['model_path'];
			ensureDirectoryExists(baseModelPath);
			ensureDirectoryExists(modelPath);
			List<String> modelFiles = new List<String>();
			for(String tableName in tableNames) {
				String className = StringFormat.variable(getModelName(tableName));
				String baseName =  "${baseModelPath}base_${className}.dart";
				getBaseModel(tableName).then((String contents){
					File output = new File(baseName);
	            	output.writeAsStringSync(contents);
				});

				String modelFilePath = "${modelPath}${className}.dart";
				File modelFile = new File(modelFilePath);
				if(!modelFile.existsSync()) {
					modelFile.writeAsStringSync(getModel(tableName));
				}
				modelFiles.add(baseName);
				modelFiles.add(modelFilePath);

			}
			c.complete(modelFiles);
		});
		return c.future;
	}

	void generateProjectFiles() {
		generateModels().then((List<String> fileNames) {
			ProjectGenerator pg = new ProjectGenerator();
			pg.baseGenerator = this;
			fileNames.sort();
			pg.fileNames = fileNames;
			String projName = StringFormat.variable(getProjectName());
			String projectContents = pg.getFileContents();
			File projFile = new File('${projName}.dart');
			projFile.writeAsStringSync(projectContents);

			File pubFile = new File('pubspec.yaml');
			PubSpecGenerator psg = new PubSpecGenerator();
			psg.baseGenerator = this;
			pubFile.writeAsStringSync(psg.getFileContents());
		});

	}

	void ensureDirectoryExists(String directory) {
		Directory dir = new Directory(directory);
		if(!dir.existsSync()) {
			dir.createSync(recursive: true);
		}
		if(!dir.existsSync()) {
			throw new Exception('could not create directory "${directory}"');
		}
	}

	void setOptions(Map<String, Object> options) {
		_options.addAll(options);
	}
}