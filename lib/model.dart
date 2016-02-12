part of dabl;

abstract class Model {

	static const String COLUMN_TYPE_CHAR = 'CHAR';
    static const String COLUMN_TYPE_VARCHAR = 'VARCHAR';
    static const String COLUMN_TYPE_LONGVARCHAR = 'LONGVARCHAR';
    static const String COLUMN_TYPE_CLOB = 'CLOB';
    static const String COLUMN_TYPE_NUMERIC = 'NUMERIC';
    static const String COLUMN_TYPE_DECIMAL = 'DECIMAL';
    static const String COLUMN_TYPE_TINYINT = 'TINYINT';
    static const String COLUMN_TYPE_SMALLINT = 'SMALLINT';
    static const String COLUMN_TYPE_INTEGER = 'INTEGER';
    static const String COLUMN_TYPE_INTEGER_TIMESTAMP = 'INTEGER_TIMESTAMP';
    static const String COLUMN_TYPE_BIGINT = 'BIGINT';
    static const String COLUMN_TYPE_REAL = 'REAL';
    static const String COLUMN_TYPE_FLOAT = 'FLOAT';
    static const String COLUMN_TYPE_DOUBLE = 'DOUBLE';
    static const String COLUMN_TYPE_BINARY = 'BINARY';
    static const String COLUMN_TYPE_VARBINARY = 'VARBINARY';
    static const String COLUMN_TYPE_LONGVARBINARY = 'LONGVARBINARY';
    static const String COLUMN_TYPE_BLOB = 'BLOB';
    static const String COLUMN_TYPE_DATE = 'DATE';
    static const String COLUMN_TYPE_TIME = 'TIME';
    static const String COLUMN_TYPE_TIMESTAMP = 'TIMESTAMP';
    static const String COLUMN_TYPE_BU_DATE = 'BU_DATE';
    static const String COLUMN_TYPE_BU_TIMESTAMP = 'BU_TIMESTAMP';
    static const String COLUMN_TYPE_BOOLEAN = 'BOOLEAN';

    static final List<String> textTypes = [
		COLUMN_TYPE_CHAR,
		COLUMN_TYPE_VARCHAR,
		COLUMN_TYPE_LONGVARCHAR,
		COLUMN_TYPE_CLOB,
		COLUMN_TYPE_DATE,
		COLUMN_TYPE_TIME,
		COLUMN_TYPE_TIMESTAMP,
		COLUMN_TYPE_BU_DATE,
		COLUMN_TYPE_BU_TIMESTAMP
	];

    static final List<String> integerTypes = [
    	COLUMN_TYPE_SMALLINT,
    	COLUMN_TYPE_TINYINT,
    	COLUMN_TYPE_INTEGER,
    	COLUMN_TYPE_BIGINT,
    	COLUMN_TYPE_BOOLEAN,
    	COLUMN_TYPE_INTEGER_TIMESTAMP
    ];

    static final List<String> lobTypes = [
    	COLUMN_TYPE_VARBINARY,
    	COLUMN_TYPE_LONGVARBINARY,
    	COLUMN_TYPE_BLOB
    ];

    static final List<String> temporalTypes = [
    	COLUMN_TYPE_DATE,
    	COLUMN_TYPE_TIME,
    	COLUMN_TYPE_TIMESTAMP,
    	COLUMN_TYPE_BU_DATE,
    	COLUMN_TYPE_BU_TIMESTAMP,
    	COLUMN_TYPE_INTEGER_TIMESTAMP
    ];

    static final List<String> numericTypes = [
    	COLUMN_TYPE_SMALLINT,
    	COLUMN_TYPE_TINYINT,
    	COLUMN_TYPE_INTEGER,
    	COLUMN_TYPE_BIGINT,
    	COLUMN_TYPE_FLOAT,
    	COLUMN_TYPE_DOUBLE,
    	COLUMN_TYPE_NUMERIC,
    	COLUMN_TYPE_DECIMAL,
    	COLUMN_TYPE_REAL,
    	COLUMN_TYPE_INTEGER_TIMESTAMP
    ];

    /**
	 * The maximum size of the instance pool
	 */
    static const int MAX_INSTANCE_POOL_SIZE = 400;

	/**
	 * Array to contain names of modified columns
	 */
	Set<String> modifiedColumns = new Set<String>();

	/**
	 * Whether or not to cache results in the internal object cache
	 */
	bool cacheResults = true;

	/**
	 * Whether or not to save dates as formatted date/time strings
	 */
	bool formatDates = true;

	/**
	 * Whether or not this is a new object
	 */
	bool isNew = true;

	/**
	 * Wether or not the object is out of sync with the databse
	 */
	bool isDirty = false;

	/**
	 * Errors from the validate() step of saving
	 */
	List<String> validationErrors = new List<String>();

	String toString();

	/**
	 * Whether passed type is a temporal (date/time/timestamp) type.
	 */
	static bool isTemporalType(String typ) {
		return Model.temporalTypes.contains(typ);
	}

	static bool isNumericType(String typ) {
		return Model.numericTypes.contains(typ);
	}

	static bool isIntegerType(String typ) {
		return Model.integerTypes.contains(typ);
	}

	static bool isLobType(String typ) {
		return Model.lobTypes.contains(typ);
	}

	static String getTableName() {
		throw new UnimplementedError('getTableName needs to be implemented on the baseModel');
	}

	static String normalizeColumnName(String columnName) {
    	int pos = columnName.lastIndexOf('.');
    	if (pos != -1) {
    		return columnName.substring(pos + 1);
    	}
    	return columnName;
    }

	static Object coerceTemporalValue(Object value, String columnType, [DABLDDO conn = null]) {
		if(null == conn) {
			conn = getConnection();
		}

		if(value is List){
			return value.map((f) => coerceTemporalValue(f, columnType, conn)).toList();
		}

		if(!(value is int)) {
			value = DateTime.parse(value).millisecondsSinceEpoch;
		}

		String format;
		switch(columnType) {
			case Model.COLUMN_TYPE_TIMESTAMP:
				format = conn.getTimestampFormatter();
				break;
			case Model.COLUMN_TYPE_DATE:
				format = conn.getDateFormatter();
				break;
			case Model.COLUMN_TYPE_TIME:
				format = conn.getTimeFormatter();
				break;
			case Model.COLUMN_TYPE_INTEGER_TIMESTAMP:
				return value;
		}
		DateFormat formatter = new DateFormat(format);
		DateTime dt = new DateTime.fromMillisecondsSinceEpoch(value);
		var result = formatter.format(dt);
		return result;
	}

	static List<Model> fromResult(DDOStatement result, List classes, [bool usePool = true]) {
		if(classes == null) {
			throw new ArgumentError('No class name given');
		}
		List<Model> objects = new List<Model>();

		if(classes.length > 1) {
			throw new UnimplementedError('Multiple classes at once isn\'t implemented yet.');
		} else {
			//Can't use easy function because we aren't doing the current class, we're doing whatever class we were asked to do
			ClassMirror cm = reflectClass(classes.first);
			result.setFetchMode(DDO.FETCH_CLASS, cm);
			Model obj;
			String pk = '';
			Model poolObject;
			bool foundInPool;
			while(false != (obj = result.fetch())) {
				if(obj == null) {
					break;
				}
				InstanceMirror im = reflect(obj);
				if(usePool
					&& ( pk != '' || ((pk = cm.invoke(const Symbol('getPrimaryKey'), []).reflectee) != ""))
					&& ( (poolObject = cm.invoke(new Symbol('retrieveFromPool'), [im.invoke(new Symbol("get${StringFormat.titleCase(pk)}"), []).reflectee]).reflectee)) != null) {

        			obj = poolObject;

				} else  {
					//obj.castInts();
					obj.setNew(false);
				}
				objects.add(obj);

				if(usePool) {
					cm.invoke(new Symbol('insertIntoPool'), [obj]);
				}

			}
		}
		return objects;
	}


	bool fromAssociativeResultArray(Map<String, Object> values) {
		// TODO: implement fromAssociativeResultArray
	}

	bool fromNumericResultArray(List values, int startCol) {
		// TODO: implement fromNumericResultArray
	}

	static int doDelete(Query q, [bool flushPool = true]) {
		throw new UnsupportedError('doDelete needs to be overridden in the child class');
	}

	static Future<int> doUpdate(Map values, ClassMirror cm, [Query q = null]) {
		q = q != null ? q.clone() : new Query();
		DABLDDO conn = cm.invoke(const Symbol('getConnection'), []).reflectee;

		if(q.getTable() == null) {
			q.setTable(cm.invoke(const Symbol('getTableName'), []).reflectee);
		}
		return q.doUpdate(values, conn);
	}

	static int setInsertBatchSize([int size = 500]){
		throw new UnsupportedError('setInsertBatchSize needs to be overridden in the child class');
	}

	static int insertBatch() {
		throw new UnsupportedError('insertBatch needs to be overridden in the child class');
	}

	Model queueForInsert();

	Model copy() {
		Model self = _getChildClass().newInstance(const Symbol(''), []).reflectee;
		Map<String, Object> values = toArray();
		for(String key in _doChildStaticMethod(const Symbol('getPrimaryKeys'))) {
			if (values.containsKey(key)) {
				values.remove(key);
			}
		}
		self.fromArray(values);
		return self;
	}

	bool isModified() => modifiedColumns.isNotEmpty;

	bool isColumnModified(String columnName) {
		Set<String> modColumns = _doChildInstanceMethod(const Symbol('getModifiedColumns'));
		return modColumns.map((String col) => col.toLowerCase()).contains(normalizeColumnName(columnName).toLowerCase());
	}

	Set<String> getModifiedColumns() => modifiedColumns;

	Model resetModified() {
		modifiedColumns.clear();
		return this;
	}

	Model fromArray(Map<String, Object> array) {
		for(String column in array.keys) {
			if (!_doChildStaticMethod(const Symbol('hasColumn'), [column])) {
				continue;
			}
			_doChildInstanceMethod(new Symbol('set${StringFormat.titleCase(column)}'), [array[column]]);
		}
		return this;
	}

	Map<String, Object> toArray() {
		Map<String, Object> results = {};
		List columns = _getChildColumns();
		for(String column in columns) {
			results[column] = getColumn(column);
		}
		return results;
	}

	Map<String, Object> toJson() => toArray();

	Model setCacheResults([bool value = true]);

	bool getCacheResults() => cacheResults;

	bool hasPrimaryKeyValues() => getPrimaryKeyValues().isNotEmpty;

	List<Object> getPrimaryKeyValues() {
		List<Object> values = [];
		List<String> pks = _doChildStaticMethod(const Symbol('getPrimaryKeys'));
		for(String pk in pks) {
			values.add(_doChildInstanceMethod(new Symbol('get${pk}')));
		}
		return values;
	}

	bool validate() => validationErrors.isEmpty;

	List<String> getValidationErrors() => validationErrors;

	/**
	 * Creates and executes DELETE Query for this object
	 * Deletes any database rows with a primary key(s) that match $this
	 * NOTE/BUG: If you alter pre-existing primary key(s) before deleting, then you will be
	 * deleting based on the new primary key(s) and not the originals,
	 * leaving the original row unchanged(if it exists).  Also, since NULL isn't an accurate way
	 * to look up a row, I return if one of the primary keys is null.
	 * @return int number of records deleted
	 */
	Future<int> delete() async {
		List<String> pks = _doChildStaticMethod(const Symbol('getPrimaryKeys'));
		if(pks == null || pks.isEmpty) {
			throw new Exception('This table has no primary keys');
		}
		Query q = _doChildStaticMethod(const Symbol('getQuery'));
		for(String pk in pks) {
			if(pk == null || pk.isEmpty) {
				throw new Exception('Cannot delete using NULL primary key.');
			}
			Object pkVal = _doChildInstanceMethod(new Symbol('get${pk}'));
			q.addAnd(pk, pkVal);
		}
		q.setTable(_doChildStaticMethod(const Symbol('getTableName')));

		int cnt = await _doChildStaticMethod(const Symbol('doDelete'), [q, false]);
		_doChildStaticMethod(const Symbol('removeFromPool'), [this]);
		return cnt;
	}

	Future<int> save() {
		if (isDirty) {
			throw new Exception('Cannot save dirty ${runtimeType.toString()}. Perhaps it was already saved using bulk insert.');
		}

		if (!validate()) {
			throw new Exception('Cannot save ${runtimeType.toString()} with validation errors: ${getValidationErrors().join(', ')}');
		}

		DABLDDO conn = getConnection();

		if (isNew && _doChildStaticMethod(const Symbol('hasColumn'), ['created']) && !_doChildInstanceMethod(const Symbol('isColumnModified'), ['created'])) {
			_doChildInstanceMethod(const Symbol('setCreated'), [new DateTime.now().toIso8601String()]);
		}

		if ((isNew || isModified()) && _doChildStaticMethod(const Symbol('hasColumn'), ['updated']) && !_doChildInstanceMethod(const Symbol('isColumnModified'), ['updated'])) {
			_doChildInstanceMethod(const Symbol('setUpdated'), [new DateTime.now().toIso8601String()]);
		}

		if (isNew){
			return _insert();
		}
		return _update();
	}

	Future<int> archive() {
		if (!_doChildStaticMethod(new Symbol('hasColumn'), ['archived'])) {
			throw new Exception('Cannot call archive on models without "archived" column');
		}

		if (null != _doChildInstanceMethod(new Symbol('getArchived'))) {
			throw new Exception('This ${runtimeType.toString()} is already archived');
		}
		_doChildInstanceMethod(new Symbol('setArchived'), [new DateTime.now().toIso8601String()]);

		return save();
	}

	//bool isNew() => isNew;

	Model setNew(bool isNew) {
		this.isNew = isNew;
		return this;
	}

	//bool isDirty() => _isDirty;

	Model setDirty(bool dirty);

	/** Castints isn't necessary
	Model castInts();
	*/

	Future<int> _insert() {
		DABLDDO conn = getConnection();

		String pk = _doChildStaticMethod(const Symbol('getPrimaryKey'));

		List<String> fields = new List<String>();
		List values = new List();
		List<String> placeHolders = new List<String>();
		for(String column in _getChildColumns()) {
			Object value = _doChildInstanceMethod(new Symbol('get${StringFormat.titleCase(column)}'));
			if(null == value && !_doChildInstanceMethod(const Symbol('isColumnModified'), [column])) {
				continue;
			}
			fields.add(conn.quoteIdentifier(column));
			values.add(value);
			placeHolders.add('?');
		}

		String quotedTable = conn.quoteIdentifier(_doChildStaticMethod(const Symbol('getTableName')));
		String queryS = 'INSERT INTO ${quotedTable} (${fields.join(', ')}) VALUES (${placeHolders.join(', ')})';
		//TODO: When DBPostgres gets created, enabled this code
		/*
		if(pk != null && isAutoIncrement() && conn is DBPostgres) {
			queryS += ' RETURNING ${conn.quoteIdentifier(pk)}';
		}*/

		QueryStatement statement = new QueryStatement(conn);
		statement.setString(queryS);
		statement.setParams(values);

		return statement.bindAndExecute().then((DDOStatement result) {
			int count = result.rowCount();

			if(pk != null && _doChildStaticMethod(const Symbol('isAutoIncrement'))) {
				var id = null;
				if(conn.isGetIdAfterInsert()) {
					id = result.lastInsertId();
				}
				if(null != id) {
					_doChildInstanceMethod(new Symbol('set${StringFormat.titleCase(pk)}'), [id]);
				}
			}

			resetModified();
			setNew(false);

			_doChildStaticMethod(const Symbol('insertIntoPool'), [this]);
			return count;
		});

	}

	Future<int> _update() {
		List<String> pks = _doChildStaticMethod(const Symbol('getPrimaryKeys'),[]);

		if (pks == null || pks.isEmpty) {
			throw new Exception('This table has no primary keys');
		}

		Map<String, Object> columnValues = new Map<String, Object>();

		for(String column in getModifiedColumns()) {
			columnValues[column] = _doChildInstanceMethod(new Symbol('get${StringFormat.titleCase(column)}'), []);
		}

		if(columnValues.isEmpty) {
			return new Future.value(0);
		}

		Query q = new Query();

		for(String pk in pks) {
			Object pkVal = _doChildInstanceMethod(new Symbol('get${StringFormat.titleCase(pk)}'), []);
			if(pkVal == null) {
				throw new Exception('Cannot update with NULL primary key.');
			}
			q.add(pk, pkVal);
		}
		return doUpdate(columnValues, reflectClass(this.runtimeType), q).then((int count) {
			resetModified();
			return count;
		});
	}

	Query getForeignObjectsQuery(String foreignTable, String foreignColumn, String localColumn, [Query q = null]);

	Object getColumn(String colName) {
		return _doChildInstanceMethod(new Symbol("get${StringFormat.titleCase(colName)}"), []);
	}

	Model setColumnValue(String columnName, Object value, [String columnType = null]);

	Model setColumnValueByLibrary(String columnName, Object value, String libraryName, [String columnType = null, DABLDDO connection = null]) {
		if (null == columnType) {
			columnType = getColumnType(columnName);
		}

		List<Object> trueVals = [true, 1, '1', 'on', 'true'];
		List<Object> falseVals = [false, 0, '0', 'off', 'false'];

		columnName = normalizeColumnName(columnName);

		if (columnType == Model.COLUMN_TYPE_BOOLEAN) {
			if(value is String) {
				value = (value as String).toLowerCase();
			}
			if(trueVals.contains(value)) {
				value = 1;
			} else if (falseVals.contains(value)) {
				value = 0;
			} else if ('' == value || null == value) {
				value = null;
			} else {
				throw new ArgumentError("'${value.toString()}' is not a valid boolean value");
			}
		} else {
			bool temporal = Model.isTemporalType(columnType);
			bool numeric = Model.isNumericType(columnType);

			if(temporal || numeric) {
				if(value is String) {
					value = (value as String).trim();
				}
				if ('' == value || 'null' == value) {
					value = null;
				} else if (null != value) {
					if(temporal && formatDates) {
						value = Model.coerceTemporalValue(value, columnType, connection);
					} else if(numeric) {
						if(value is bool) {
							value = (value as bool) ? 1 : 0;
						} else if (Model.isIntegerType(columnType)) {
							if(!(value is int)) {
								value = int.parse(value.toString());
							}
						} else {
							double floatVal = double.parse(value);
						}
					}
				}
			}
		}


		if(value != getColumn(columnName)) {
			InstanceMirror im = reflect(this);
			var name = MirrorSystem.getName(new Symbol("${columnName}"));
			var symb = MirrorSystem.getSymbol(name, currentMirrorSystem().findLibrary(new Symbol(libraryName)));
			im.setField(symb, value);
			modifiedColumns.add(columnName);
		}

		return this;
	}

	InstanceMirror _getChildInstance() => reflect(this);

	ClassMirror _getChildClass() => reflectClass(this.runtimeType);

	Object _doChildMethod(Symbol s, {bool isStatic: false, List params: null}) {
		if (params == null) {
			params = [];
		}
		if (isStatic) {
			return _getChildClass().invoke(s, params).reflectee;
		}
		return _getChildInstance().invoke(s, params).reflectee;
	}

	Object _doChildInstanceMethod(Symbol s, [List params = null]) => _doChildMethod(s, isStatic: false, params: params);

	Object _doChildStaticMethod(Symbol s, [List params = null]) => _doChildMethod(s, isStatic: true, params: params);

	List _getChildColumns() => _doChildStaticMethod(const Symbol('getColumnNames'));

	static DABLDDO getConnection() {
		return DBManager.getConnection();
	}

	static Model retrieveByPK(Object id) {
		throw new UnsupportedError('retrieveByPK needs to be overridden in child class');
	}

	static String getColumnType(String columnName) {
		throw new UnsupportedError('getColumnType needs to be overridden in child class');
	}
}
