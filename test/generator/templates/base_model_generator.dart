import '../../../lib/dabl.dart';
import '../../../lib/string_format.dart';
import 'package:unittest/unittest.dart';
import 'dart:io';

main() {
   	Map<String, String> conn_params = {
   		'driver': 'mysql',
   		'host': '127.0.0.1',
   		'dbname': 'people',
   		'user': 'root',
   		'password': ''
   	};
   	DBManager.addConnection('hoffman', conn_params);
   	DefaultGenerator dg = new DefaultGenerator('people');
   	dg.getBaseModel('task').then((String str){
   		File output = new File('output.dart');
    	output.writeAsStringSync(str);
    	print('done');
    	test('generatesModel', (){
			expect(str, equals('hi'));
		});
   	});
}