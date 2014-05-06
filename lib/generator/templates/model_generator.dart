part of dabl_generator;

class ModelGenerator extends FileGenerator {
	String className;
	BaseGenerator baseGenerator;

	String getFileContents() {
		String projectName = baseGenerator.getProjectName();
		String baseClassName = "base${className}";
		return '''
part of ${projectName};

class ${className} extends base${className} {

	static String getPrimaryKey() => ${baseClassName}.getPrimaryKey();

	static ${className} retrieveFromPool(Object pkValue) => ${baseClassName}.retrieveFromPool(pkValue);

	static void insertIntoPool(${className} obj) => ${baseClassName}.insertIntoPool(obj);

	static bool hasColumn(String columnName) => ${baseClassName}.hasColumn(columnName);

	static List<String> getColumns() => ${baseClassName}.getColumns();

	static List<String> getColumnNames() => ${baseClassName}.getColumnNames();

	static String getTableName() => ${baseClassName}.getTableName();

	static List<String> getPrimaryKeys() => ${baseClassName}.getPrimaryKeys();

	static bool isAutoIncrement() => ${baseClassName}.isAutoIncrement;

	static DABLDDO getConnection() => ${baseClassName}.getConnection();
}
''';
	}
}