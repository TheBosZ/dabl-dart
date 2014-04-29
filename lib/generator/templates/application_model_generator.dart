part of dabl_generator;

class ApplicationModelGenerator extends FileGenerator {

	@override
	String getFileContents() {
		return '''
part of ${baseGenerator.getProjectName()};

abstract class ApplicationModel extends Model {

}
''';
	}
}
