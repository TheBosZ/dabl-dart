part of dabl_generator;

class ProjectGenerator extends FileGenerator {

	BaseGenerator baseGenerator;
	List<String> fileNames;

	@override
	String getFileContents() {
		StringBuffer result = new StringBuffer();
		result.write('''
library ${baseGenerator.getProjectName()};

import 'package:dabl/dabl.dart';
import 'package:dabl_query/query.dart';

''');
		for(String name in fileNames) {
			result.write('''
part '${name}';
''');
		}

		return result.toString();
	}
}
