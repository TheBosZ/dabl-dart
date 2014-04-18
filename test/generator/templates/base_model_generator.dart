import '../../../lib/dabl.dart';
import '../../../lib/string_format.dart';
import '../../../packages/unittest/unittest.dart';
import 'dart:io';

main() {
   	Map<String, String> conn_params = {
   		'driver': 'mysql',
   		'host': '127.0.0.1',
   		'dbname': 'hoffman_ssm',
   		'user': 'hoffman',
   		'password': 'G00bers!'
   	};
   	DBManager.addConnection('hoffman', conn_params);
   	DefaultGenerator dg = new DefaultGenerator('hoffman');
   	dg.getBaseModel('task').then((String str){
   		File output = new File('output.dart');
    	output.writeAsStringSync(str);
    	print('done');
    	test('generatesModel', (){
			expect(str, equals('hi'));
		});
   	});
}