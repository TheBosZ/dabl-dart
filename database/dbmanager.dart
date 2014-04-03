library dabl;

import './query/query.dart';
import '../../pdodart/ddo.dart';
part './adapter/dabl_ddo.dart';

part 'model.dart';


class DBManager {
	static Map<String, String> _connections = new Map<String, String>();
	static Map<String, Map<String, String>> _parameters = new Map<String, Map<String, String>>();

	static void addConnection(String conn_name, Map conn_params) {
		_parameters[conn_name] = conn_params;
	}

	static dynamic getConnection([String db_name = null]){
		if(null == db_name) {
			db_name = _parameters.keys.first;
		}
		if(null == db_name) {
			return null;
		}
		return _connect(db_name);
	}

	static Map getConnections() {
		for(String conn in _parameters.keys){
			_connect(conn);
		}
		return _connections;
	}

	static String getParameter(String db_name, String key) {
		if('password' == key) {
			throw new Exception('DB password is private');
		}

		if(!_parameters.containsKey(db_name)){
			throw new Exception('Configuration for database "${db_name}" not loaded');
		}

		return _parameters[db_name][key];
	}

	static List getConnectionNames() {
		return _parameters.keys;
	}

	//Will actually return a connection, when the class is built
	static dynamic _connect(String key) {
		if(_connections.containsKey(key)) {
			return _connections[key];
		}

		if(!_parameters.containsKey(key)) {
			throw new Exception('Connection "${key}" has not been set');
		}

		var conn = new DDO();
		return _connections[key] = conn;
	}

	static void disconnect(String key) {
		_connections.remove(key);
	}

}