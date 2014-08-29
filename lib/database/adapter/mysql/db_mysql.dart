part of dabl;

class DBMySQL extends DABLDDO {

	DBMySQL(Driver driver) :
    	super(driver);

	int _transactionDepth = 0;

	String toUpperCase(String s) => "UPPER(${s})";

	String ignoreCase(String s) => toUpperCase(s);

	String concatString(String s1, String s2) => "CONCAT({$s1}, ${s2})";

	String subString(String s, int pos, int len) => "SUBSTRING(${s}, ${pos}, ${len})";

	String strLength(String s) => "CHAR_LENGTH(${s})";

	Future lockTable(String table) {
		return exec("LOCK TABLE ${table} WRITE");
	}

	Future unlockTable(String table) {
		return exec("UNLOCK TABLES");
	}

	Object quoteIdentifier(Object t) {
		if(t is List) {
			return t.map((s) => quoteIdentifier(s)).toList();
		}
		if(t is String) {
			if(t.contains(new RegExp(r'[` (\*]'))) {
				return t;
			}
			return "`${t.replaceAll('.', '`.`')}`";
		}
		return t;
	}

	bool useQuoteIdentifier() {
		return true;
	}

	String applyLimit(String sql, int offset, int limit) {
		if(limit > 0) {
			String off = offset > 0 ? "${offset}, " : "";
			sql = "${sql} LIMIT ${off} ${limit}";
		} else if(offset > 0) {
			sql = "${sql} LIMIT ${offset}, 18446744073709551615";
		}
		return sql;
	}

	String random([int seed = null]){
		return "RAND(${seed})";
	}

	String dateFormat(String field, String format, [String alias = null]){
		alias = alias != null ? " AS ${quoteIdentifier(alias)}" : '';
		return "DATE_FORMAT(${field}, '${format}')${alias}";
	}

	Future beginTransaction() {
		Future res;
		if(_transactionDepth == 0) {
			res = super.beginTransaction();
		} else {
			res = exec("SAVEPOINT LEVEL${_transactionDepth}");
		}
		++_transactionDepth;
		return res;
	}

	Future commit() {
		--_transactionDepth;
		if(_transactionDepth == 0) {
			return super.commit();
		}
		return exec("RELEASE SAVEPOINT LEVEL${_transactionDepth}");
	}

	Future rollBack() {
		if(_transactionDepth == 0) {
			throw new Exception('Rollback error: There is no transaction started');
		}

		--_transactionDepth;

		if(_transactionDepth ==0) {
			return super.rollBack();
		}
		return exec("ROLLBACK TO SAVEPOINT LEVEL${_transactionDepth}");
	}
}