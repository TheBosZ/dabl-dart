part of dabl_generator;

class BaseModelGenerator extends FileGenerator {
	String className;
	String tableName;
	List<Column> fields;
	List<Column> PKs;
	List<ForeignKey> fromTable;
	List<ForeignKey> toTable;
	Column PK;
	bool autoIncrement;
	String get baseClassName => "base${className}";
	DABLDDO conn;
	String connectionName;
	List<String> warnings = new List<String>();
	BaseGenerator baseGenerator;
	List<String> usedMethods = [
		'getTableName',
		'getColumnNames',
		'getColumns',
		'getColumnTypes',
		'getColumnType',
		'hasColumn',
		'getPrimaryKeys',
		'getPrimaryKey',
		'isAutoIncrement',
		'fetchSingle',
		'fetch',
		'fromResult',
		'castInts',
		'insertIntoPool',
		'retrieveFromPool',
		'removeFromPool',
		'flushPool',
		'setPoolEnabled',
		'getPoolEnabled',
		'getAll',
		'doCount',
		'doDelete',
		'doSelect',
		'doSelectOne',
		'doUpdate'
	];

	String getFileContents() {
		fromTable.sort((ForeignKey l, ForeignKey r) => l.getForeignTableName().compareTo(r.getForeignTableName()));
		toTable.sort((ForeignKey l, ForeignKey r) => l.getForeignTableName().compareTo(r.getForeignTableName()));

		StringBuffer result = new StringBuffer('''
part of ${baseGenerator.getProjectName()};

''');
		result.write('''
abstract class ${baseClassName} extends ApplicationModel {

''');
		for(Column field in fields) {
			result.write("\tstatic const String ");
			result.write(StringFormat.constant(field.getName()));
			result.write(" = '");
			result.write(tableName);
			result.write('.');
			result.write(field.getName());
			result.write("';\n");
		}
		result.write(''' 
	/**
	 * Name of the table
	 */
	static const String _tableName = '${tableName}';

	/**
	 * Cache of objects retrieved from the database
	 */
	static Map<String, ${className}> _instancePool = new Map<String, ${className}>();

	static int _instancePoolCount = 0;

	static bool _poolEnabled = true;

	/**
	 * List of objects to batch insert
	 */
	static List<${className}> _insertBatch = new List<${className}>();

	static int _insertBatchSize = 500;

	/**
	 * List of all primary keys
	 */
	static final List<String> _primaryKeys = [
''');
		if(PKs.isNotEmpty) {
			for(Column thePk in PKs) {
				result.write("\t\t'${thePk.getName()}',\n");
			}
		}
		result.write('''
	];

	/**
	 * string name of the primary key column
	 */
	static const String _primaryKey = '${PK != null ? PK.getName() : ''}';

	/**
	 * true if primary key is an auto-increment column
	 */
	static const bool _isAutoIncrement = ${autoIncrement.toString()};

	/**
	 * List of all fully-qualified(table.column) columns
	 */
	static final List<String> _columns = [
''');
		for(Column field in fields) {
			result.write('\t\t${baseClassName}.${StringFormat.constant(field.getName())},\n');
		}
		result.write('''
	];

	/**
	 * List of all column names
	 */
	static final List<String> _columnNames = [
''');
		for(Column field in fields) {
			result.write('\t\t\'${field.getName()}\',\n');
		}
		result.write('''
	];

	/**
	 * map of all column types
	 */
	static final Map<String, String> _columnTypes = {
''');
		for(Column field in fields) {
			result.write("\t\t'${field.getName()}': Model.COLUMN_TYPE_${field.getType()},\n");
		}
		result.write('''
	};
''');
		for(Column field in fields) {
			String def = field.getDefaultValue() != null && field.getDefaultValue().getValue() != 'null' ? field.getDefaultValue().getValue() : null;
			if(field.isNumericType() && def != null) {
				//Fix for MSSQL default value weirdness
				def = def.replaceAll("(", "").replaceAll(")", "");
			}
			result.write('''

	/**
	 * ${conn.quoteIdentifier(field.getName())} ${field.getType()}''');
			if(field.isNotNull()) {
				result.write(' NOT NULL');
			}
			if(def != null) {
				result.write(' DEFAULT ');
				if(isInt(def)) {
					result.write(def);
				} else {
					result.write(conn.quote(def));
				}

			}
			result.write('\n\t */\n');
			if(field.isNumericType() && isInt(def) && def != null) {
				def = null;
			}
			result.write('\t${field.getDartType()} _${field.getName()}');
			if(field.isNumericType() && def != null) {
				result.write(' = ${def}');
			} else if(def != null && def.toLowerCase() != null) {
				result.write(' = \'${addSlashes(def)}\'');
			}
			result.write(';\n');
		}
		//Getters and setters
		for(Column field in fields) {
			String privateName = "_${field.getName()}";
			String def = field.getDefaultValue() != null && field.getDefaultValue().getValue() != 'null' ? field.getDefaultValue().getValue() : null;
            String methodName = StringFormat.titleCase(field.getName());
            String params = '';
            String paramVars = '';
            if(field.isTemporalType()) {
            	String defaultValue = 'null';
            	if(field.getType() == Model.COLUMN_TYPE_INTEGER_TIMESTAMP) {
            		defaultValue = "'${conn.getTimestampFormatter()}'";
            	}
            	params = "[String format = ${defaultValue}]";
            	paramVars = 'format';
            }
            String cacheMethodName = 'get${methodName}';
            String rawMethodName = StringFormat.ucFirst(field.getName());
            if(!usedMethods.contains(cacheMethodName)) {
	            usedMethods.add(cacheMethodName);
	            result.write('''
			
	/** 
	 * Gets the value of the ${field.getName()} field
	 */
	${field.getDartType()} ${cacheMethodName}(${params}) {
''');
	            if(field.isTemporalType()) {
	            	result.write('''
		if(null == ${privateName} || null == ${paramVars}) {
			return ${privateName};
		}
''');
		            if(field.getType() == Model.COLUMN_TYPE_INTEGER_TIMESTAMP) {
		            	result.write('''
		DateFormat formatter = new DateFormat(format);
		return formatter.format(DateTime.parse(${privateName}));
''');
	            	} else {
	            		result.write('''
		if(0 == ${privateName}.indexOf('0000-00-00')) {
			return null;
		}
		DateFormat formatter = new DateFormat(format);
		return formatter.format(DateTime.parse(${privateName}));
''');
	            	}
	            } else {
	            	result.write('''
		return ${privateName};
''');
            }

            result.write('''
	}
''');
            }
            String cacheSetMethod = 'set${methodName}';
            if(!usedMethods.contains(cacheSetMethod)) {
            	usedMethods.add(cacheSetMethod);

            	result.write('''

	/**
	 * Sets the value of the ${field.getName()} field
	 */

	${className} ${cacheSetMethod}(Object value) {
		return setColumnValue('${field.getName()}', value, Model.COLUMN_TYPE_${field.getType()});
	}
''');
            }
            if(rawMethodName.toLowerCase() != methodName.toLowerCase() &&
              !usedMethods.contains('get${rawMethodName}')) {
            	usedMethods.add('get${rawMethodName}');
            	usedMethods.add('set${rawMethodName}');
            	result.write('''

	/**
	 * Convenience functon for ${className}.get${methodName}
	 *
	 * @see ${className}.get${methodName}
	 */
	${field.getDartType()} get${rawMethodName}(${params}) {
		return get${methodName}(${paramVars});
	}

	/**
	 * Convenience function for ${className}.set${methodName}
	 * 
	 * @see ${className}.set${methodName}
	 */
	${className} set${rawMethodName}(${field.getDartType()} value) {
		return set${methodName}(value);
	}
''');
            }
		} //end for each column
		usedMethods.add('getConnection');
		usedMethods.add('retrieveByPK');
		usedMethods.add('retrieveByPKs');
		result.write('''

	static DABLDDO getConnection() {
		return DBManager.getConnection('${connectionName}');
	}

	static ${className} create() => new ${className}();

	static String getTableName() => ${baseClassName}._tableName;

	static List<String> getColumnNames() => ${baseClassName}._columnNames;

	static List<String> getColumns() => ${baseClassName}._columns;

	static Map<String, String> getColumnTypes() => ${baseClassName}._columnTypes;

	static String getColumnType(String columnName) => ${baseClassName}._columnTypes[${baseClassName}.normalizeColumnName(columnName)];

	static List<String> _columnsCache = new List<String>();

	static bool hasColumn(String columnName) {
		
		if (null == _columnsCache) {
			_columnsCache = ${baseClassName}._columnNames.map((String s) => s.toLowerCase()).toList();
		}
		return _columnsCache.contains(${baseClassName}.normalizeColumnName(columnName).toLowerCase());
	}

	static List<String> getPrimaryKeys() => ${baseClassName}._primaryKeys;

	static String getPrimaryKey() => ${baseClassName}._primaryKey;

	static bool isAutoIncrement() => ${baseClassName}._isAutoIncrement;

	static String normalizeColumnName(String columnName) => Model.normalizeColumnName(columnName);

	/**
	 * Searches the database for a row with the ID(primary key) that matches
	 * the one input.
	 */
	static Future<${className}> retrieveByPK(${ PKs.isNotEmpty && PKs.length == 1 ? "${PKs.first.getDartType()} ${StringFormat.variable(PKs.first.getName())}" : 'Object the_pk'}) {
''');
		if(PKs.length > 1) {
			result.write("\t\tthrow new Exception('This table was more than one primary key. Use retrieveByPKs() instead');\n");
		} else if(PKs.length == 0) {
			result.write("\t\tthrow new Exception('This table does not have any primary keys');\n");
		} else {
			result.write("\t\treturn ${baseClassName}.retrieveByPKs(${PKs.isNotEmpty && PKs.length == 1 ? StringFormat.variable(PKs.first.getName()) : 'the_pk'});\n");
		}
		result.write('''
	}

	/**
	 * Searches the database for a row with the primary keys that match
	 * the ones input
	 */
	static Future<${className}> retrieveByPKs(''');
		result.write(PKs.map((Column v) => "${v.getDartType()} ${StringFormat.variable(v.getName())}").join(', '));
		result.write(') {\n');
		if(PKs.length == 0) {
			result.write("\t\tthrow new Exception('This table does not have any primary keys');\n");
		} else {
			for(Column v in PKs) {
				result.write('''
		if(null == ${StringFormat.variable(v.getName())}) {
			return null;
		}
''');
			}
			result.write('''
		if(${baseClassName}._poolEnabled) {
			${className} poolInstance = ${baseClassName}.retrieveFromPool(''');
			if(1 == PKs.length) {
				result.write(StringFormat.variable(PK.getName()));
			} else {
				result.write(PKs.map((Column v) => StringFormat.variable(v.getName())).join('-'));
			}
			result.write(''');
			if(null != poolInstance) {
				return new Future.value(poolInstance);
			}
		}
		Query q = new Query();
''');
			for(Column v in PKs) {
				result.write("\t\tq.add('${v.getName()}', ${StringFormat.variable(v.getName())});\n");
			}
			result.write("\n\t\treturn ${baseClassName}.doSelectOne(q);");
		}
		result.write("\n\t}\n");

		for(Column field in fields) {
			result.write('''

	/**
	 * Searches the database for a row with a ${field.getName()}
	 * that matches the one provided
	 */
	static Future<${className}> retrieveBy${StringFormat.titleCase(field.getName())}(${field.getDartType()} value) {
''');
			if(field.isPrimaryKey() && field.getTable().getPrimaryKey().length == 1) {
				result.write('\t\treturn ${baseClassName}.retrieveByPK(value);\n');
			} else {
				result.write("\t\treturn ${baseClassName}.retrieveByColumn('${field.getName()}', value);\n");
			}
			result.write("\t}\n");
		}

		result.write('''

	static Future<${className}> retrieveByColumn(String field, Object value) {
		Query q = new Query();
		q.add(field, value);
		q.setLimit(1);
''');
		if(PK != null) {
			result.write('''
		q.order('${PK.getName()}');
''');
		}
		result.write('''
		return ${baseClassName}.doSelectOne(q);
	}

	/**
	 * Populates and returns a List of ${className} objects with the results of a query
	 * If the query returns no results, returns an empty List
	 */
	static Future<List<${className}>> fetch(String queryString) {
		DABLDDO conn = ${baseClassName}.getConnection();
		Completer c = new Completer();
		conn.query(queryString).then((DDOStatement result) {
			c.complete(${baseClassName}.fromResult(result, [${className}]));
		});
		return c.future;
	}

	/**
	 * Returns a List of ${className} objects from a DDOStatement (Query result)
	 */
	static List<${className}> fromResult(DDOStatement result, [List<Type> classNames = null, bool usePool = null]) {
		if (null == usePool) {
			usePool = ${baseClassName}._poolEnabled;
		}

		if(classNames == null) {
			classNames = new List<Type>();
			classNames.add(reflect(new Symbol('${className}')).type.reflectedType);
		}
		List<${className}> results = new List<${className}>();
		for(Model m in Model.fromResult(result, classNames, usePool)) {
			results.add(m as ${className});
		}

		return results;
	}

	/**
	 * Casts values of int fields to (int)
	 */
	/* Unneccessary method?
	${className} castInts() {
''');
		for(Column field in fields) {
			if(Model.isIntegerType(field.getType())) {
				result.write("\t\t${field.getName()} = (null == ${field.getName()}) ? null : int.parse(_${field.getName()});\n");
			}
		}
		result.write('''
		return this;
	}
	*/

	/**
	 * Add (or replace) to the instance pool
	 */
	static void insertIntoPool(${className} obj) {
		if(!${baseClassName}._poolEnabled) {
			return;
		}
''');
		if(PKs.isEmpty) {
			result.write('''
		//This table doesn't have primary keys, so there's no way to key the instance
		return;
''');
		} else {
		result.write('''
		if (${baseClassName}._instancePoolCount > Model.MAX_INSTANCE_POOL_SIZE) {
			return;
		}

		${baseClassName}._instancePool[obj.getPrimaryKeyValues().join('-')] = obj;
		${baseClassName}._instancePoolCount = ${baseClassName}._instancePool.length;
''');
		}
		result.write('''
	}

	/**
	 * Return the cached instance from the pool
	 */
	static ${className} retrieveFromPool(Object pkValue) {
		if(!${baseClassName}._poolEnabled || null == pkValue) {
			return null;
		}
		String key = pkValue.toString();
		if(_instancePool.containsKey(key)) {
			return _instancePool[key];
		}
		return null;
	}

	/**
	 * Remove the object from the instance pool.
	 */
	static void removeFromPool(Object obj) {
		String pk = (obj is Model) ? obj.getPrimaryKeyValues().join('-') : obj.toString();
		if(${baseClassName}._instancePool.containsKey(pk)) {
			${baseClassName}._instancePool.remove(pk);
			${baseClassName}._instancePoolCount = ${baseClassName}._instancePool.length;
		}
	}

	/**
	 * Empty the instance pool.
	 */
	static void flushPool() => ${baseClassName}._instancePool.clear();

	static void setPoolEnabled([bool b = true]) {
		${baseClassName}._poolEnabled = b;
	}
	
	static bool getPoolEnabled() => ${baseClassName}._poolEnabled;
	
	static Future<int> doCount([Query q = null]) {
		q = q != null ? q.clone() : new Query();
		DABLDDO conn = ${baseClassName}.getConnection();
		if (q.getTable() == null) {
			q.setTable(${baseClassName}.getTableName());
		}
		return q.doCount(conn);
	}

	static Future<int> doDelete(Query q, [bool flushPool = true]) {
		DABLDDO conn = ${baseClassName}.getConnection();
		q = q.clone();
		if (q.getTable() == null) {
			q.setTable(${baseClassName}.getTableName());
		}
		Future<int> result = q.doDelete(conn);
		
		if (flushPool) {
			${baseClassName}.flushPool();
		}
		return result;
	}

	static Future<List<${className}>> doSelect([Query q = null, List<Type> additionalClasses = null]) {
		if(additionalClasses == null) {
			additionalClasses = new List<Type>();
		}
		additionalClasses.insert(0, ${className});
		Completer c = new Completer();
		${baseClassName}.doSelectRS(q).then((DDOStatement result) {
			c.complete(${baseClassName}.fromResult(result, additionalClasses));
		});
		return c.future;
	}

	static Future<${className}> doSelectOne([Query q = null, List<Type> additionalClasses = null]) {
		q = q != null ? q.clone() : new Query();
		q.setLimit(1);
		Completer c = new Completer();
		${baseClassName}.doSelect(q, additionalClasses).then((List<${className}> objs) {
			c.complete(objs.first);
		});
		return c.future;
	}

	static Future<int> doUpdate(Map columnValues, [Query q = null]) {
		q = q != null ? q.clone() : new Query();
		DABLDDO conn = ${baseClassName}.getConnection();

		if (q.getTable() == null) {
			q.setTable(${baseClassName}.getTableName());
		}

		return q.doUpdate(columnValues, conn);
	}

	/**
	 * Set the maximum insert batch size, once this size is reached the batch automatically inserts.
	 */
	static int setInsertBatchSize([int size = 500]) => ${baseClassName}._insertBatchSize = size;
	
	/**
	 * Queue for batch insert
	 */
	${className} queueForInsert() {
		if(${baseClassName}._insertBatch.length >= ${baseClassName}._insertBatchSize) {
			${baseClassName}.insertBatch();
		}

		${baseClassName}._insertBatch.add(this);

		return this;
	}

	static Future<int> insertBatch() {
		if (${baseClassName}._insertBatch.isEmpty) {
			return new Future.value(0);
		}

		DABLDDO conn = ${baseClassName}.getConnection();
		List<String> columns = ${baseClassName}.getColumnNames();
		String quotedTable = conn.quoteIdentifier(${baseClassName}.getTableName());
''');
		if(autoIncrement) {
			result.write('''
		Object pk = ${baseClassName}.getPrimaryKey();
		if (columns.contains(pk)) {
			columns.remove(pk);
		}
''');
		}
		result.write('''
	
		List values = new List();

		List<String> queryS = new List<String>();
		queryS.add('INSERT INTO \${quotedTable} (\${columns.map((String s) => conn.quoteIdentifier(s)).join(', ')}) VALUES');

		List<String> placeHolders;
		for(${className} obj in ${baseClassName}._insertBatch) {
			placeHolders = new List<String>();

			if (!obj.validate()) {
				throw new Exception('Cannot save ${className} with validation errors: \${obj.getValidationErrors().join(', ')}');
			}
''');
		if(fields.where((Column c) => c.getName() == 'Created').isNotEmpty) {
			result.write('''
			if (obj.isNew && ${baseClassName}.hasColumn('Created') && !obj.isColumnModified('Created')) {
				obj.setCreated(new DateTime.now().toIso8601String());
			}
''');
		}
		if(fields.where((Column c) => c.getName() == 'Updated').isNotEmpty) {
        			result.write('''
			if ((obj.isNew || obj.isModified()) && ${baseClassName}.hasColumn('Updated') && !obj.isColumnModified('Updated')) {
				obj.setUpdated(new DateTime.now().toIso8601String());
			}
''');
		}
		result.write('''

			for (String column in columns) {
''');
		if(autoIncrement) {
			result.write('''
				if (column == pk) {
					continue;
				}
''');
		}
		result.write('''
				values.add(obj.getColumn(column));
				placeHolders.add('?');
			}
			queryS.add('(\${placeHolders.join(', ')})');
		}

		QueryStatement statement = new QueryStatement(conn);
		statement.setString(queryS.join('\\n'));
		statement.setParams(values);
		Completer c = new Completer();
		statement.bindAndExecute().then((DDOStatement results) {
			for (${className} obj in ${baseClassName}._insertBatch) {
				obj.setNew(false);
				obj.resetModified();
				if(obj.hasPrimaryKeyValues()) {
					${baseClassName}.insertIntoPool(obj);
				} else {
					obj.setDirty(true);
				}
			}
			${baseClassName}._insertBatch.clear();
			c.complete(results.rowCount());
		});
		return c.future;
	}

	static Object coerceTemporalValue(Object value, String columnType, [DABLDDO conn = null]) {
		if (null == conn) {
			conn = ${baseClassName}.getConnection();
		}
		return Model.coerceTemporalValue(value, columnType, conn);
	}

	static Future<DDOStatement> doSelectRS([Query q = null]) {
		q = q != null ? q.clone() : new Query();
		DABLDDO conn = ${baseClassName}.getConnection();

		if (q.getTable() == null) {
			q.setTable(${baseClassName}.getTableName());
		}

		return q.doSelect(conn);
	}
''');

		//Foreign keys to this table

		Map<String, int> toTableList = new Map<String, int>();
		for(ForeignKey r in fromTable) {
			String toTable = r.getForeignTableName();
			if(toTableList.containsKey(toTable)) {
				if(toTableList[toTable] == 1) {
					warnings.add("${tableName} has more than one foreign key to ${toTable}. ${toTable}.get${tableName}s will not be created.");
				}
				++toTableList[toTable];
			} else {
				toTableList[toTable] = 1;
			}
		}

		for(ForeignKey r in fromTable) {
			String toTable = r.getForeignTableName();
			String toClassName = baseGenerator.getModelName(toTable);
			String baseToClassName = "base${toClassName}";
			String lcToClassName = toClassName.toLowerCase();
			List<String> foreignColumns = r.getForeignColumns();
			String toColumn = foreignColumns.first;
			String tcToColumn = StringFormat.titleCase(toColumn);
			List<String> localColumns = r.getLocalColumns();
			String fromColumn = localColumns.first;
			bool namedId = false;
			Column foreignColumn = r.getForeignTable().getColumn(toColumn);
			bool fkIsPk = foreignColumn.isPrimaryKey();
			String fromColumnClean;
			String fromColumnMethodName = StringFormat.titleCase(fromColumn);

			int idPos = fromColumn.toLowerCase().lastIndexOf('_id');
			if(idPos != fromColumn.length - 3) {
				idPos = fromColumn.lastIndexOf('Id');
				if(idPos != fromColumn.length - 2) {
					idPos = fromColumn.lastIndexOf('ID');
					if(idPos != fromColumn.length - 2) {
						idPos = -1;
					}
				}
			}

			if(idPos != -1) {
				fromColumnClean = fromColumn.substring(0, idPos);
				bool isField = false;
				for(Column field in fields) {
					if(field.getName() == fromColumnClean) {
						isField = true;
						break;
					}
				}

				if(isField) {
					warnings.add("Can't create convenience functions for column ${fromColumn}: get${fromColumnClean}() and set${fromColumnClean}(), consider renaming ${fromColumnClean}.");
				} else {
					namedId = true;
				}
			}
			String fkProperty;
			if(!fkIsPk) {
				fkProperty = "_${toClassName}RelatedBy${StringFormat.titleCase(fromColumn)}";
				result.write('''
		${toClassName} _${fkProperty};
''');
			}
			if(namedId) {
				usedMethods.add('set${StringFormat.titleCase(fromColumnClean)}');
				result.write('''

	${className} set${StringFormat.titleCase(fromColumnClean)}([${toClassName} ${lcToClassName} = null]) {
		return set${toClassName}RelatedBy${StringFormat.titleCase(fromColumn)}(${lcToClassName});
	}

''');
			}
			usedMethods.add('set${toClassName}RelatedBy${StringFormat.titleCase(fromColumn)}');
			result.write('''
	${className} set${toClassName}RelatedBy${StringFormat.titleCase(fromColumn)}([${toClassName} ${lcToClassName} = null]) {
		if (null == ${lcToClassName}) {
			set${fromColumnMethodName}(null);
		} else {
			if (null == ${lcToClassName}.get${tcToColumn}()) {
				throw new Exception('Cannot connect a ${toClassName} without a ${toColumn}');
			}
			set${fromColumnMethodName}(${lcToClassName}.get${tcToColumn}());
		}
''');
			if(!fkIsPk) {
				result.write('''

			if (getCacheResults() != null) {
				${fkProperty} = ${lcToClassName};
			}
''');
			}
			result.write('''

		return this;
	}
''');
			if(namedId) {
				usedMethods.add('get${StringFormat.titleCase(fromColumnClean)}');
				result.write('''

	/**
	 * Returns a ${toTable} object with a ${toColumn}
	 * that matches this.${fromColumn}
	 */
	Future<${toClassName}> get${StringFormat.titleCase(fromColumnClean)}() {
		return get${toClassName}RelatedBy${StringFormat.titleCase(fromColumn)}();
	}
''');
			}
			usedMethods.add('get${toClassName}RelatedBy${StringFormat.titleCase(fromColumn)}');
			result.write('''

	/**
	 * Returns a ${toTable} object with a ${toColumn}
	 * that matches this.${fromColumn}
	 */
	Future<${toClassName}> get${toClassName}RelatedBy${StringFormat.titleCase(fromColumn)}() {
		Object fkValue = get${StringFormat.titleCase(fromColumn)}();
		if (null == fkValue) {
			return null;
		}
''');
			if(fkIsPk) {
				result.write("\n\t\treturn ${baseToClassName}.retrieveByPK(fkValue);\n");
			} else {
				result.write('''
		${toClassName} result = ${fkProperty};
		if (null != result && result.get${StringFormat.titleCase(toColumn)}() == fkValue) {
			return result;
		}

		result = ${baseToClassName}.retrieveBy${StringFormat.titleCase(toColumn)}(fkValue);

		if (getCacheResults()) {
			${fkProperty} = result;
		}

		return result;
''');
			}
			result.write('\n\t}\n');

			if(namedId) {
				usedMethods.add('doSelectJoin${StringFormat.titleCase(fromColumnClean)}');
				result.write('''

	static Future<List<${className}>> doSelectJoin${StringFormat.titleCase(fromColumnClean)}([Query q = null, String joinType = Query.LEFT_JOIN]) {
		return ${baseClassName}.doSelectJoin${toClassName}RelatedBy${StringFormat.titleCase(fromColumn)}(q, joinType);
	}
''');
			}
			if(toTableList[toTable] < 2) {
				if(!usedMethods.contains('get${toClassName}')) {
					usedMethods.add('get${toClassName}');
					result.write('''

	/**
	 * Returns a ${toTable} object with a ${toColumn}
	 * that matches this.${fromColumn}
	 */
	Future<${toClassName}> get${toClassName}() {
		return get${toClassName}RelatedBy${StringFormat.titleCase(fromColumn)}();
	}
''');
				}
				if(!usedMethods.contains('set${toClassName}')) {
					usedMethods.add('set${toClassName}');
					result.write('''

	${className} set${toClassName}([${toClassName} ${lcToClassName} = null]) {
		return set${toClassName}RelatedBy${StringFormat.titleCase(fromColumn)}(${lcToClassName});
	}
''');
				}
			}
		usedMethods.add('doSelectJoin${toClassName}RelatedBy${StringFormat.titleCase(fromColumn)}');
		result.write('''

	static Future<List<${className}>> doSelectJoin${toClassName}RelatedBy${StringFormat.titleCase(fromColumn)}([Query q = null, String joinType = Query.LEFT_JOIN]) {
		q = q != null ? q.clone() : new Query();
		List<String> columns = q.getColumns().values;
		String alias = q.getAlias();
		String thisTable = alias != null ? alias : ${baseClassName}.getTableName();
		if(columns.isEmpty) {
			if(alias != null) {
				for(String columnName in ${baseClassName}.getColumns()) {
					columns.add("\${alias}.\${columnName}");
				}
			} else {
				columns = ${baseClassName}.getColumns();
			}
		}

		String toTable = ${baseToClassName}.getTableName();
		q.join(toTable, "\${thisTable}.${fromColumn} = \${toTable}.${toColumn}\", joinType);
		for (String column in ${baseToClassName}.getColumns()) {
			columns.add(column);
		}
		q.setColumns(columns.asMap());

		return ${baseClassName}.doSelect(q, ['${toClassName}']);
	}
''');
		}
		usedMethods.add('doSelectJoinAll');
		result.write('''

	static Future<List<${className}>> doSelectJoinAll([Query q = null, String joinType = Query.LEFT_JOIN]) {
		q = q != null ? q.clone() : new Query();
		List<String> columns = q.getColumns().values;
		List<Type> classes = new List<Type>();
		String alias = q.getAlias();
		String thisTable = alias != null ? alias : ${baseClassName}.getTableName();
		if(columns.isEmpty) {
			if(alias != null) {
				for(String columnName in ${baseClassName}.getColumns()) {
					columns.add('\${alias}.\${columnName}');
				}
			} else {
				columns = ${baseClassName}.getColumns();
			}
		}

		String toTable;
''');
		for(ForeignKey r in fromTable) {
			String totable = r.getForeignTableName();
			String toClassName = baseGenerator.getModelName(totable);
			String baseToClassName = "base${toClassName}";
			List<String> foreignColumns = r.getForeignColumns();
			String toColumn = foreignColumns.first;
			List<String> localColumns = r.getLocalColumns();
			String fromColumn = localColumns.first;
			result.write('''

		toTable = ${baseToClassName}.getTableName();
		q.join(toTable, "\${thisTable}.${fromColumn} = \${toTable}.${toColumn}", joinType);
		for(String column in ${baseToClassName}.getColumns()) {
			columns.add(column);
		}
		classes.add(${toClassName});
''');
		}
		result.write('''

		q.setColumns(columns.asMap());
		return ${baseClassName}.doSelect(q, classes);
	}
''');
		Map<String, int> fromTableList = new Map<String, int>();
		for(ForeignKey r in toTable){
			String fromTable = r.getTableName();

			if(fromTableList.containsKey(fromTable)) {
				++fromTableList[fromTable];
			} else {
				fromTableList[fromTable] = 1;
			}

			String fromClassName = baseGenerator.getModelName(fromTable);
			String baseFromClassName = "base${fromClassName}";
			List<String> localColumns = r.getLocalColumns();
			String fromColumn = localColumns.first;
			List<String> foreignColumns = r.getForeignColumns();
			String toColumn = foreignColumns.first;
			String toTable = r.getForeignTableName();
			String tcToColumn = StringFormat.titleCase(toColumn);
			String tcFromColumn = StringFormat.titleCase(fromColumn);
			String tcFromClassName = StringFormat.titleCase(fromClassName);
			String cacheProperty = "_${fromClassName}sRelatedBy${tcFromColumn}_c";
			String cacheGetMethodNameQuery = "get${tcFromClassName}sRelatedBy${tcFromColumn}Query";
			String cacheCountMethodName = "count${tcFromClassName}sRelatedBy${tcFromColumn}";
			String cacheDeleteMethodName = "delete${tcFromClassName}sRelatedBy${tcFromColumn}";
			String cacheGetMethodName = "get${tcFromClassName}sRelatedBy${tcFromColumn}";

			if(!usedMethods.contains(cacheGetMethodNameQuery)) {
				usedMethods.add(cacheGetMethodNameQuery);
				result.write('''

	/**
	 * Returns a Query for selecting ${fromTable} objects(rows) from the ${fromTable} table
	 * with a ${fromColumn} that matches this.${toColumn}.
	 */
	Query ${cacheGetMethodNameQuery}([Query q = null]) {
		return getForeignObjectsQuery('${fromTable}', '${fromColumn}', '${toColumn}', q);
	}
''');
			}
			if(!usedMethods.contains(cacheCountMethodName)) {
				usedMethods.add(cacheCountMethodName);
				result.write('''

	/**
	 * Returns the count of ${fromClassName} objects(rows) from the ${fromTable} table
	 * with a ${fromColumn} that matches this.${toColumn}.
	 */
	Future<int> ${cacheCountMethodName}([Query q = null]) {
		if(null == get${tcToColumn}()) {
			return new Future.value(0);
		}
		return ${baseFromClassName}.doCount(get${StringFormat.titleCase(fromClassName)}sRelatedBy${StringFormat.titleCase(fromColumn)}Query(q));
	}
''');
			}
			if(!usedMethods.contains('SET_CACHE_VARIABLE${cacheProperty}')) {
				usedMethods.add('SET_CACHE_VARIABLE${cacheProperty}');
				result.write('''

	List<${fromClassName}> ${cacheProperty} = new List<${fromClassName}>();
''');
			}
			if(!usedMethods.contains(cacheDeleteMethodName)) {
				usedMethods.add(cacheDeleteMethodName);
				result.write('''
			
	/**
	 * Deletes the ${fromTable} objects(rows) from the ${fromTable} table
	 * with a ${fromColumn} that matches this.${toColumn}
	 */
	Future<int> ${cacheDeleteMethodName}([Query q = null]) {
		if (null == get${tcToColumn}()) {
			return new Future.value(0);
		}
		${cacheProperty}.clear(); //Clear cached objects
		return ${baseFromClassName}.doDelete(get${tcFromClassName}sRelatedBy${tcFromColumn}Query(q));
	}
''');
			}
			if(!usedMethods.contains(cacheGetMethodName)) {
				usedMethods.add(cacheGetMethodName);
				result.write('''

	/**
	 * Returns a list of ${fromClassName} objects with a ${fromColumn}
	 * that matches this.${toColumn}.
	 * When first called, this method will cache the result.
	 * After that, if this.${toColumn} is not modified, the
	 * method will return the cached result instead of querying the database
	 * a second time (for performance purposes).
	 */
	Future<List<${fromClassName}>> ${cacheGetMethodName}([Query q = null]) {
		if (null == get${tcToColumn}()) {
			return new Future.value(new List<${fromClassName}>());
		}

		if (
			null == q &&
			getCacheResults() &&
			${cacheProperty}.isNotEmpty &&
			!isColumnModified('${toColumn}')
		) {
			return new Future.value(${cacheProperty});
		}
		Completer c = new Completer();
		${baseFromClassName}.doSelect(${cacheGetMethodNameQuery}(q)).then((List<${fromClassName}> result) {
			if (getCacheResults() && q != null) { //We can't cache when sent a Query object
				${cacheProperty} = result;
			}
			c.complete(result);
		});

		return c.future;
	}
''');
			}
		} //end for foreignkeys from table
		for(ForeignKey r in toTable) {
			String fromTable = r.getTableName();
			if(fromTableList.containsKey(fromTable) && fromTableList[fromTable] > 1) {
				continue;
			}

			String fromClassName = baseGenerator.getModelName(fromTable);
			List<String> localColumns = r.getLocalColumns();
			String fromColumn = localColumns.first;
			List<String> foreignColumns = r.getForeignColumns();
			String toColumn = foreignColumns.first;
			String toTable = r.getForeignTableName();

			String tcFromClassName = StringFormat.titleCase(fromClassName);
			String tcFromColumn = StringFormat.titleCase(fromColumn);

			String cacheGetMethod = "get${tcFromClassName}s";
			String cacheGetQueryMethod = "get${tcFromClassName}sQuery";
			String cacheDeleteMethod = "delete${tcFromClassName}s";
			String cacheCountMethod = "count${tcFromClassName}s";

			if(!usedMethods.contains(cacheGetMethod)) {
				usedMethods.add(cacheGetMethod);
				result.write('''

	/**
	 * Convenience function for ${className}.get${fromClassName}sRelatedBy${fromColumn}
	 */
	Future<List<${fromClassName}>> ${cacheGetMethod}([Object extra = null]) {
		return get${tcFromClassName}sRelatedBy${tcFromColumn}(extra);
	}
''');
			}

			if(!usedMethods.contains(cacheGetQueryMethod)) {
				usedMethods.add(cacheGetQueryMethod);
				result.write('''

	/**
	 * Convenience function for ${className}.get${fromClassName}sRelatedBy($fromColumn}Query
	 */
	Query ${cacheGetQueryMethod}([Query q = null]) {
		return get${tcFromClassName}sRelatedBy${tcFromColumn}Query(q);
	}
''');
			}

			if(!usedMethods.contains(cacheDeleteMethod)) {
				usedMethods.add(cacheDeleteMethod);
				result.write('''

	/**
	 * Convenience function for ${className}.delete($fromClassName}sRelatedBy${tcFromColumn}
	 */
	Future<int> ${cacheDeleteMethod}([Query q = null]) {
		return delete${tcFromClassName}sRelatedBy${tcFromColumn}(q);
	}
''');
			}

			if(!usedMethods.contains(cacheCountMethod)) {
				usedMethods.add(cacheCountMethod);
				result.write('''

	/**
	 * Convenience function for ${className}.count${tcFromClassName}sRelatedBy${fromColumn}
	 */
	Future<int> ${cacheCountMethod}([Query q = null]) {
		return count${tcFromClassName}sRelatedBy${tcFromColumn}(q);
	}
''');
			}
		} //end for foreignkeys to table
		result.write('''

	/**
	 * Returns true if the column values validate
	 */
	bool validate() {
		validationErrors = new List<String>();
''');
		for(Column field in fields) {
			if(
				field.isNotNull() &&
				!field.isAutoIncrement() &&
				field.getDefaultValue() == null &&
				!field.isPrimaryKey() &&
				!(['created', 'updated'].contains(field.getName()))
			) {
				result.write('''
		if (null == get${StringFormat.titleCase(field.getName())}()) {
			validationErrors.add('${field.getName()} must not be null');
		}
''');

			}
		}
		result.write('''
		return validationErrors.isEmpty;
	}

	Query getForeignObjectsQuery(String foreignTable, String foreignColumn, String localColumn, [Query q = null]) {
		Object value = getColumn(localColumn);
		if (null == value) {
			throw new Exception('NULL cannot be used to match keys.');
		}

		String column = "\${foreignTable}.\${foreignColumn}";

		if (q != null) {
			q = q.clone();
			String alias = q.getAlias();
			if (alias != null && foreignTable == q.getTable()) {
				column = "\${alias}.\${foreignColumn}";
			}
		} else {
			q = new Query();
		}
		q.add(column, value);
		return q;
	}

	Model setColumnValue(String columnName, Object value, [String columnType = null]) {
		return setColumnValueByLibrary(columnName, value, '${baseGenerator.getProjectName()}', columnType);
	}

	List<Object> getPrimaryKeyValues() {
	    List<String> vals = new List<String>();
	    InstanceMirror im = reflect(this);

		 for(String pk in getPrimaryKeys()) {
	    	var name = MirrorSystem.getName(new Symbol("_\${pk}"));
	    	var symb = MirrorSystem.getSymbol(name, currentMirrorSystem().findLibrary(new Symbol('${baseGenerator.getProjectName()}')));
	    	vals.add(im.getField(symb).reflectee.toString());
	    }
	    return vals;
	}
}
	
''');
		return result.toString();
	}
}