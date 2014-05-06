import "package:dabl_query/query.dart";
import 'lib/dabl.dart';
import 'package:database_reverse_engineer/database_reverse_engineer.dart';
import 'lib/dbmanager.dart';
import 'package:ddo/drivers/ddo_mysql.dart';
void main() {
	Map<String, String> conn_params = {
		'driver': 'mysql',
		'host': '127.0.0.1',
		'dbname': 'hoffman_ssm',
		'user': 'hoffman',
		'password': 'G00bers!'
	};
	addConnection('hoffman', conn_params);

	Driver driver = new DDOMySQL(conn_params['host'], conn_params['dbname'], conn_params['user'], conn_params['password']);
	setDriver(driver);

	DABLDDO conn = getConnection('hoffman');


	conn.getDatabaseSchema().then((Database db) {
		print(db.toString());
	});
}
