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
import 'package:dabl/dbmanager.dart' as DBManager;
export 'package:dabl/dbmanager.dart';
import 'package:dabl_query/query.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:mirrors';

part 'application_model.dart';

''');
		for(String name in fileNames) {
			result.write('''
part '${name}';
''');
		}

		return result.toString();
	}
}
