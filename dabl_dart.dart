import "package:dabl_query/query.dart";
import 'lib/dabl.dart';
import 'package:database_reverse_engineer/database_reverse_engineer.dart';
import 'lib/dbmanager.dart';
import 'package:ddo/drivers/ddo_mysql.dart';
void main() {
	Map<String, String> conn_params = {
		'driver': 'mysql',
   		'host': '127.0.0.1',
   		'dbname': 'test',
   		'user': 'test_user',
   		'password': 'test'
   	};
	Driver driver = new DDOMySQL(conn_params['host'], conn_params['dbname'], conn_params['user'], conn_params['password']);
	addConnection('test', driver);

	DABLDDO conn = getConnection('test');


	conn.getDatabaseSchema().then((Database db) {
		print(db.toString());
	});
}
