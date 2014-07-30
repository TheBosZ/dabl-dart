import 'package:dabl/dabl.dart';
import 'package:dabl/string_format.dart';
import 'package:dabl/dbmanager.dart' as DBManager;
import '../../../packages/unittest/unittest.dart';
import 'dart:io';
import 'package:dabl/generator/generator.dart';

main() {
   	Map<String, String> conn_params = {
   		'driver': 'mysql',
   		'host': '127.0.0.1',
   		'dbname': 'people',
   		'user': 'root',
   		'password': 'password'
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