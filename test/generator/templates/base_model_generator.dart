import 'package:unittest/unittest.dart';
import 'package:dabl/generator/generator.dart';
import 'package:dabl/dbmanager.dart' as DBManager;
import 'package:ddo/drivers/ddo_mysql.dart';
import 'dart:async';

main() {
	DBManager.addConnection('test', new DDOMySQL('127.0.0.1', 'test', 'test_user', 'password'));

	DefaultGenerator dg = new DefaultGenerator('test');
	test('generates model', (){
		Future<String> result = dg.getBaseModel('task');
		expect(result, completion(isNot(isEmpty)));
	});
}
