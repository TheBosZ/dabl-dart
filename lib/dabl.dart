library dabl;

import 'package:ddo/ddo.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:dabl_query/query.dart';

import 'string_format.dart';
export 'string_format.dart';
import 'dbmanager.dart' as DBManager;

@MirrorsUsed(
	targets: 'DABLDDO,DBMySQL,DBWebSQL,Model',
	override: '*'
)
import 'dart:mirrors';

part 'database/adapter/dabl_ddo.dart';
part 'database/adapter/mysql/db_mysql.dart';
part 'database/adapter/websql/db_websql.dart';
part 'model.dart';
part 'reflected_model.dart';