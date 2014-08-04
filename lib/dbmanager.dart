library dbmanager;

import 'dabl.dart';
import 'package:ddo/ddo.dart';

Map<String, DABLDDO> _connections = new Map<String, DABLDDO>();
Map<String, Map<String, String>> _parameters = new Map<String, Map<String, String>>();
Driver _driver;

void setDriver(Driver driver) {
	_driver = driver;
}

void addConnection(String conn_name, Driver driver) {
	setDriver(driver);
	_parameters[conn_name] = driver.dbinfo;
}

DABLDDO getConnection([String db_name = null]){
	if(null == db_name) {
		db_name = _parameters.keys.first;
	}
	if(null == db_name) {
		return null;
	}
	return _connect(db_name);
}

Map getConnections() {
	for(String conn in _parameters.keys){
		_connect(conn);
	}
	return _connections;
}

String getParameter(String db_name, String key) {
	if('password' == key) {
		throw new Exception('DB password is private');
	}

	if(!_parameters.containsKey(db_name)){
		throw new Exception('Configuration for database "${db_name}" not loaded');
	}

	return _parameters[db_name][key];
}

List getConnectionNames() {
	return _parameters.keys;
}

DABLDDO _connect(String key) {
	if(_connections.containsKey(key)) {
		return _connections[key];
	}

	if(!_parameters.containsKey(key)) {
		throw new Exception('Connection "${key}" has not been set');
	}

	var conn = new DABLDDO.factory(_parameters[key], _driver);
	return _connections[key] = conn;
}

void disconnect(String key) {
	_connections.remove(key);
}