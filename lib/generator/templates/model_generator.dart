part of dabl;

class ModelGenerator extends FileGenerator {
	String className;
	BaseGenerator baseGenerator;

	String getFileContents() {
		String projectName = baseGenerator.getProjectName();
		return '''
part of ${projectName};

class ${className} extends base${className} {

}
''';
	}
}