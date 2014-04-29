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
	 * Cache of objects retrieved from the database
	 */
	static Map<String, Model> _instancePool = new Map<String, Model>();

    static int _instancePoolCount = 0;

    static bool _poolEnabled = true;

    /**
	 * List of objects to batch insert
	 */
    static List<Model> _insertBatch;

    /**
	 * Maximum size of the insert batch
	 */
	static int _insertBatchSize = 500;

	/**
	 * Array of all primary keys
	 */
	static List<String> _primaryKeys;

	/**
	 * string name of the primary key column
	 */
	static String _primaryKey;

	/**
	 * true if primary key is an auto-increment column
	 */
	static bool _isAutoIncrement = false;

	/**
	 * array of all fully-qualified(table.column) columns
	 */
	static List<String> _columns;

	/**
	 * array of all column names
	 */
	static List<String> _columnNames;

	/**
	 * array of all column types
	 */
	static Map<String, String> _columnTypes;

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

	static Object create() {
		throw new UnimplementedError('Create() not implemented yet');
	}

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

	static List<String> getColumnNames() {
		return _columnNames;
	}

	static List<String> getColumns() {
		return _columns;
	}

	static Map<String, String> getColumnTypes() {
		return _columnTypes;
	}

	static String getColumnType(String col_name) {
		return _columnTypes[normalizeColumnName(col_name)];
	}

	static List<String> _lowerCaseColumns = new List<String>();

	static bool hasColumn(String col_name) {
		throw new UnimplementedError('hasColumn() not implemented yet');
	}

	static String normalizeColumnName(String columnName) {
    	int pos = columnName.lastIndexOf('.');
    	if (pos != -1) {
    		return columnName.substring(pos + 1);
    	}
    	return columnName;
    }

	static String getPrimaryKey() {
		return _primaryKey;
	}

	static List<String> getPrimaryKeys() {
		return _primaryKeys;
	}

	static bool isAutoIncrement() {
		return _isAutoIncrement;
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
		return formatter.format(new DateTime.fromMillisecondsSinceEpoch(value));
	}

	static Object retrieveByColumn(String field, Object value) {
		if(field == _primaryKey) {
			return retrieveByPK(value);
		}

		Query q = getQuery().add(field, value).setLimit(1);
		if(_primaryKey != null){
			q.orderBy(_primaryKey);
		}

		return doSelectOne(q);
	}

	static Query getQuery([Map<String, Object> params = null, Query q = null]) {
		q = q != null ? q : new Query();

		if(q.getTable() == null) {
			q.setTable(getTableName());
		}

		params.forEach((k, param) {
			if(hasColumn(k)) {
				q.add(k, param);
			}
		});

		if(params.containsKey('order_by') && hasColumn(params['order_by'])) {
			q.orderBy(params['order_by'],
				params.containsKey('dir') && params['dir'] == Query.DESC ? Query.DESC : Query.ASC);
		}

		if(params.containsKey('limit')){
			q.setLimit(params['limit']);
		}
		return q;
	}

	static void insertIntoPool(Model object) {
		if(!_poolEnabled ||
			_instancePoolCount >= Model.MAX_INSTANCE_POOL_SIZE ||
			_primaryKeys.isEmpty) {
			return;
		}

		String key = object.getPrimaryKeyValues().join('-');
		if(key == null || key.isEmpty){
			return;
		}

		if(!_instancePool.containsKey(key)){
			++_instancePoolCount;
		}

		_instancePool[key] = object;
	}

	static Model retrieveFromPool(Object key) {
		if(!_poolEnabled || null == key) {
			return null;
		}

		String skey = key.toString();
		if(_instancePool.containsKey(skey)){
			return _instancePool[key];
		}
		return null;
	}

	static void removeFromPool(Object obj_or_pk) {
		String skey;
		if(obj_or_pk is Model) {
			skey = obj_or_pk.getPrimaryKeyValues().join('-');
		} else {
			skey = obj_or_pk.toString();
		}
		if(_instancePool.containsKey(skey)){
			--_instancePoolCount;
			_instancePool.remove(skey);
		}
	}

	static void flushPool() {
		_instancePool = new Map<String, Model>();
		_instancePoolCount = 0;
	}

	static void setPoolEnabled([bool enable = true]) {
		_poolEnabled = enable;
	}

	static bool getPoolEnabled() {
		return _poolEnabled;
	}

	static List<Model> getAll([String extra = null]) {
		throw new UnimplementedError('Use doSelect instead');
	}

	static Future<int> doCount([Query q = null]){
		q = q != null ? q : getQuery();
		if(q.getTable() == null) {
			q.setTable(getTableName());
		}
		return q.doCount(getConnection());
	}

	static Future<List<Model>> doSelect([Query q = null, List<Type> additional_classes = null]){
		throw new UnimplementedError('doSelect should be overridden in child class');
		String modelname = '';
		if(additional_classes == null) {
			additional_classes = new List<Type>();
		}

		additional_classes.insert(0, modelname);
		Completer c = new Completer();
		doSelectRS(q).then((DDOStatement result) {
			c.complete(fromResult(result, additional_classes));
		});
		return c.future;
	}

	static Future<Model> doSelectOne([Query q= null, List<Type> additional_classes = null]) {
		q = q != null ? q : getQuery();
		q.setLimit(1);
		Completer c = new Completer();
		doSelect(q, additional_classes).then((List<Model> objs) {
			c.complete(objs.first);
		});
		return c.future;
	}

	static Future<DDOStatement> doSelectRS([Query q = null]) {
		q = q != null ? q : getQuery();
		if(q.getTable() == null) {
			q.setTable(getTableName());
		}
		return q.doSelect(getConnection());
	}

	static Object doSelectIterator([Query q = null]) {
		throw new UnimplementedError();
	}

	static List<Model> fromResult(DDOStatement result, List<Type> classes, [bool usePool = true]) {
		if(classes == null) {
			throw new ArgumentError('No class name given');
		}
		List<Model> objects = new List<Model>();

		if(classes.length > 1) {
			throw new UnimplementedError('Multiple classes at once isn\'t implemented yet.');
		} else {
			ClassMirror cm = reflectClass(classes.first);
			result.setFetchMode(DDO.FETCH_CLASS, classes.first);
			Model obj;
			String pk;
			Model poolObject;
			bool foundInPool;
			while(false != (obj = result.fetch())) {
				if(obj == null) {
					break;
				}
				InstanceMirror im = reflect(obj);
				if(usePool
					&& ( pk != null || ((pk = cm.invoke(const Symbol('getPrimaryKey'), []).reflectee) != null))
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

	bool fromNumericResultArray(List values, int startCol);

	bool fromAssociativeResultArray(Map<String, Object> values);

	static int doDelete(Query q, [bool flushPool = true]) {
		throw new UnsupportedError('doDelete needs to be overridden in the child class');
	}

	static List<Model> doUpdate(List values, [Query q = null]) {
		throw new UnsupportedError('doUpdate needs to be overridden in the child class');
	}

	static int setInsertBatchSize([int size = 500]){
		throw new UnsupportedError('setInsertBatchSize needs to be overridden in the child class');
	}

	static int insertBatch() {
		throw new UnsupportedError('insertBatch needs to be overridden in the child class');
	}

	Model queueForInsert();

	Model copy();

	bool isModified() => modifiedColumns.isNotEmpty;

	bool isColumnModified(String columnName);

	Set<String> getModifiedColumns() => modifiedColumns;

	Model resetModified();

	Model fromArray(Map<String, Object> array);

	Map<String, Object> toArray();

	Map<String, Object> jsonSerialize();

	Model setCacheResults([bool value = true]);

	bool getCacheResults() => cacheResults;

	bool hasPrimaryKeyValues();

	List<Object> getPrimaryKeyValues();

	bool validate();

	List<String> getValidationErrors() => validationErrors;

	int delete();

	int save();

	int archive();

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

	int _insert();

	int _update();

	Query getForeignObjectsQuery(String foreignTable, String foreignColumn, String localColumn, [Query q = null]);

	Object getColumn(String colName) {
		InstanceMirror im = reflect(this);
		return im.invoke(new Symbol("get${StringFormat.titleCase(colName)}"), []).reflectee;
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
			var name = MirrorSystem.getName(new Symbol("_${columnName}"));
			var symb = MirrorSystem.getSymbol(name, currentMirrorSystem().findLibrary(new Symbol(libraryName)));
			im.setField(symb, value);
			modifiedColumns.add(columnName);
		}

		return this;
	}

	static DABLDDO getConnection() {
		return DBManager.getConnection();
	}

	static Model retrieveByPK(Object id) {
		throw new UnsupportedError('retrieveByPK needs to be overridden in child class');
	}
}