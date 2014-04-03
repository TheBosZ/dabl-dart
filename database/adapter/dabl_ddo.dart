part of dabl;

abstract class DABLDDO extends DDO {
	static const int ID_METHOD_NONE = 0;
	static const int ID_METHOD_AUTOINCREMENT = 1;
	static const int ID_METHOD_SEQUENCE = 2;

	String _dbName;

	void setDBName(String name) {
		_dbName = name;
	}

	String getDBName() {
		return _dbName;
	}

	static DABLDDO fact(Map<String, String> connectionParams) {
		DABLDDO obj;
		String dsn;
		String user;
		String password;

		if(connectionParams.containsKey('user')) {
			user = connectionParams['user'];
		}

		if(connectionParams.containsKey('password')) {
			password = connectionParams['password'];
		}

		var options = {DDO.ATTR_ERRMODE: DDO.ERRMODE_EXCEPTION};
		if(connectionParams.containsKey('persistant')) {
			var p = connectionParams['persistant'].trim().toLowerCase();
			switch(p) {
				case 'true':
				case '1':
				case 'on':
					options['persistant'] = true;
					break;
			}
		}

		switch(connectionParams['driver']) {
			case 'sqlite':
		}
	}
}