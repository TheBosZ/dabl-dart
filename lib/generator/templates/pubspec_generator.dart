part of dabl_generator;

class PubSpecGenerator extends FileGenerator {

	BaseGenerator baseGenerator;

	@override
	String getFileContents() {
		return '''
name: ${baseGenerator.getProjectName()}
description: Insert description here.
dependencies:
  dabl: any
''';
	}
}
