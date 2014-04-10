library dart_generator;

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

	get options => _options;

	String _connectionName;

	//@var DOMDocument
	Object dbSchema;

	//@var Database
	Object _database;

	String _baseModelTemplate = '/templates/base-model.dart';

	String _baseModelQueryTemplate = '/templates/base-model-query.dart';

	BaseGenerator(this._connectionName) {
		//Get database schema and set it based on connection
	}

	List<String> getTableNames() {
		List<String> names = new List<String>();
		//TODO: Get tables and names from database
		return names;
	}

	List<Object> getColumns(String tableName) {

	}

}