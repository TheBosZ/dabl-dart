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
}
''';
	}
}