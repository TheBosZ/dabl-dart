library dabl_query;
part 'condition.dart';
part 'query_statement.dart';
part 'query_join.dart';

class Query {
  static const String ACTION_COUNT = 'COUNT';
  static const String ACTION_DELETE = 'DELETE';
  static const String ACTION_SELECT = 'SELECT';
  static const String ACTION_UPDATE = 'UPDATE';

  // Comparison types
  static const String EQUAL = '=';
  static const String NOT_EQUAL = '<>';
  static const String ALT_NOT_EQUAL = '!=';
  static const String GREATER_THAN = '>';
  static const String LESS_THAN = '<';
  static const String GREATER_EQUAL = '>=';
  static const String LESS_EQUAL = '<=';
  static const String LIKE = 'LIKE';
  static const String BEGINS_WITH = 'BEGINS_WITH';
  static const String ENDS_WITH = 'ENDS_WITH';
  static const String CONTAINS = 'CONTAINS';
  static const String NOT_LIKE = 'NOT LIKE';
  static const String CUSTOM = 'CUSTOM';
  static const String DISTINCT = 'DISTINCT';
  static const String IN = 'IN';
  static const String NOT_IN = 'NOT IN';
  static const String ALL = 'ALL';
  static const String IS_NULL = 'IS NULL';
  static const String IS_NOT_NULL = 'IS NOT NULL';
  static const String BETWEEN = 'BETWEEN';

// Comparison type for update
  static const String CUSTOM_EQUAL = 'CUSTOM_EQUAL';

  // PostgreSQL comparison types
  static const String ILIKE = 'ILIKE';
  static const String NOT_ILIKE = 'NOT ILIKE';

  // JOIN TYPES
  static const String JOIN = 'JOIN';
  static const String LEFT_JOIN = 'LEFT JOIN';
  static const String RIGHT_JOIN = 'RIGHT JOIN';
  static const String INNER_JOIN = 'INNER JOIN';
  static const String OUTER_JOIN = 'OUTER JOIN';

  // Binary AND
  static const String BINARY_AND = '&';

  // Binary OR
  static const String BINARY_OR = '|';

  // 'Order by' qualifiers
  static const String ASC = 'ASC';
  static const String DESC = 'DESC';

  String _action;
  String _table;
  String _tableAlias;
  bool _distinct = false;
  int _limit;
  int _offset = 0;
  Map<String, String> _columns;
  List _groups;
  List<QueryJoin> _joins;
  List _orders;
  Map _extraTables;
  Map _updateColumnValues;
  Condition _where;
  Condition _having;


  Query([table = null, alias = null]) {
    _where = new Condition();
    this.setTable(table, alias);
  }

  static Query create([table = null, alias = null]) {
    return new Query(table, alias);
  }

  Query setDistinct([bool b = true]) {
    this._distinct = b;
    return this;
  }

  Query setAction(String action) {
    _action = action.toUpperCase();
    return this;
  }

  String getAction() {
    return _action;
  }

  Query addColumn(String column, [String alias = null]){
    if(null != alias) {
      column = "${column} AS \"${alias}\"";
    }
    _columns[column] = column;
    return this;
  }

  Query setColumns(Map columns) {
    _columns = columns;
    return this;
  }

  Map getColumns() {
    return _columns;
  }

  Query setGroups(List groups) {
    _groups = groups;
    return this;
  }

  List getGroups() {
    return _groups;
  }

  Query setTable(name, [String alias = null]) {
    if(name is Query) {
      if(null == alias) {
        throw new Exception('The nested query must have an alias.');
      }
    } else if (null == alias) {
      String table = name as String;
      int space = table.indexOf(" ");
      int as_pos = table.toUpperCase().indexOf(" AS ");
      if(as_pos != space - 3) {
        as_pos = -1;
      }
      if(space >= 0) {
        alias = table.substring(space + 1).trim();
        name = table.substring(0, as_pos > -1 ? space : as_pos).trim();
      }
    }

    if(!alias.isEmpty) {
      this.setAlias(alias);
    }
    _table = name;
    return this;
  }

  String getTable() {
    return _table;
  }

  Query setAlias(String alias) {
    _tableAlias = alias;
    return this;
  }

  String getAlias() {
    return _tableAlias;
  }

  Query addTable(name, [String alias = null]){
    //TODO: This duplicates a lot of setTable, refactor?
    throw new UnimplementedError('Query.addTable is not implemented');
    return this;
  }

  Query setWhere(Condition w) {
    _where = w;
    return this;
  }

  Condition getWhere() {
    return _where;
  }

  Query addJoin(table_or_column, [on_clause_or_column = null, join_type = Query.JOIN]){
    //TODO: Fill in functionality
    throw new UnimplementedError('Query.addJoin is not implemented');
    return this;
  }

  Query join(String tab_or_col, [String clause_or_column = null, String join = Query.JOIN]){
    return this.addJoin(tab_or_col, clause_or_column, join);
  }

  Query crossJoin(String tab_or_col) {
    return this.addJoin(tab_or_col);
  }

  Query innerJoin(String tab_or_col, [String clause_or_column = null]){
    return this.addJoin(tab_or_col, clause_or_column, Query.INNER_JOIN);
  }

  Query leftJoin(String tab_or_col, [String clause_or_column = null]){
    return this.addJoin(tab_or_col, clause_or_column, Query.LEFT_JOIN);
  }

  Query rightJoin(String tab_or_col, [String clause_or_column = null]){
    return this.addJoin(tab_or_col, clause_or_column, Query.RIGHT_JOIN);
  }

  Query outerJoin(String tab_or_col, [String clause_or_column = null]){
    return this.addJoin(tab_or_col, clause_or_column, Query.OUTER_JOIN);
  }

  Query joinOnce(table_or_column, [on_clause_or_column = null, join_type = Query.JOIN]){
    //TODO: Fill in functionality
    throw new UnimplementedError('Query.joinOnce is not implemented');
    return this;
  }

  Query leftJoinOnce(String tab_or_col, [String clause_or_column = null]){
    return this.joinOnce(tab_or_col, clause_or_column, Query.LEFT_JOIN);
  }

  Query rightJoinOnce(String tab_or_col, [String clause_or_column = null]){
    return this.joinOnce(tab_or_col, clause_or_column, Query.RIGHT_JOIN);
  }

  Query outerJoinOnce(String tab_or_col, [String clause_or_column = null]){
    return this.joinOnce(tab_or_col, clause_or_column, Query.OUTER_JOIN);
  }

  List<QueryJoin> getJoins() {
    return _joins;
  }

  Query setJoins(List<QueryJoin> joins) {
    _joins = joins;
    return this;
  }

  Query addAnd(String column, [value, oper = Query.EQUAL, quote = Condition.QUOTE_LEFT]){
    _where.addAnd(column, value, oper, quote);
    return this;
  }

  Query add(String column, [value, oper = Query.EQUAL, quote = Condition.QUOTE_LEFT]){
    this.addAnd(column, value, oper, quote);
    return this;
  }

  Query andNot(String column, String value) {
    _where.andNot(column, value);
    return this;
  }

  Query andLike(String column, String value) {
    _where.andLike(column, value);
    return this;
  }

  Query andNotLike(String column, String value) {
    _where.andNotLike(column, value);
    return this;
  }

  Query andGreater(String column, String value) {
    _where.andGreater(column, value);
    return this;
  }

  Query andGreaterEqual(String column, String value) {
    _where.andGreaterEqual(column, value);
    return this;
  }


  Query andLess(column, value) {
    this._where.andLess(column, value);
    return this;
  }

  Query andLessEqual(column, value) {
    this._where.andLessEqual(column, value);
    return this;
  }

  Query andNull(column) {
    this._where.andNull(column);
    return this;
  }

  Query andNotNull(column) {
    this._where.andNotNull(column);
    return this;
  }

  Query andBetween(column, $from, $to) {
    this._where.andBetween(column, $from, $to);
    return this;
  }

  Query andBeginsWith(column, value) {
    this._where.andBeginsWith(column, value);
    return this;
  }

  Query andEndsWith(column, value) {
    this._where.andEndsWith(column, value);
    return this;
  }

  Query andContains(column, value) {
    this._where.andContains(column, value);
    return this;
  }

  Query addOr(column, [value = null, $operator = Query.EQUAL, quote = null]) {
     this._where.addOr(column, value, $operator, quote);
     return this;
  }

  Query orNot(column, value) {
    this._where.orNot(column, value);
    return this;
  }

  Query orLike(column, value) {
    this._where.orLike(column, value);
    return this;
  }

  Query orNotLike(column, value) {
    this._where.orNotLike(column, value);
    return this;
  }

  Query orGreater(column, value) {
    this._where.orGreater(column, value);
    return this;
  }

  Query orGreaterEqual(column, value) {
    this._where.orGreaterEqual(column, value);
    return this;
  }

  Query orLess(column, value) {
    this._where.orLess(column, value);
    return this;
  }

  Query orLessEqual(column, value) {
    this._where.orLessEqual(column, value);
    return this;
  }

  Query orNull(column) {
    this._where.orNull(column);
    return this;
  }

  Query orNotNull(column) {
    this._where.orNotNull(column);
    return this;
  }

  Query orBetween(column, $from, $to) {
    this._where.orBetween(column, $from, $to);
    return this;
  }

  Query orBeginsWith(column, value) {
    this._where.orBeginsWith(column, value);
    return this;
  }

  Query orEndsWith(column, value) {
    this._where.orEndsWith(column, value);
    return this;
  }

  Query orContains(column, value) {
    this._where.orContains(column, value);
    return this;
  }

  Query groupBy(column) {
    this._groups.add(column);
    return this;
  }

  Query group(column) {
    return this.groupBy(column);
  }

  Query addGroup(column) {
    return this.groupBy(column);
  }

  Query setHaving(Condition $where) {
    this._having = $where;
    return this;
  }

  Condition getHaving() {
    return this._having;
  }

  Query orderBy(String column, [String dir = null]) {
    if (null != dir && '' != dir) {
      dir = dir.toUpperCase();
      if (dir != Query.ASC && dir != Query.DESC) {
        throw new Exception("dir is not a valid sorting direction.");
      }
      column = '${column} ${dir}';
    }
    this._orders.add(column.trim());
    return this;
  }

  Query order(column, [dir = null]) {
    return this.orderBy(column, dir);
  }

  Query addOrder(String column, [String dir = null]) {
    return this.orderBy(column, dir);
  }

  Query setLimit(int limit) {
    this._limit = limit;
    return this;
  }

  int getLimit() {
    return this._limit;
  }

  Query setOffset(int offset) {
    this._offset = offset;
    return this;
  }

  QueryStatement getQuery([conn = null]) {

    // the QueryStatement for the Query
    var stmnt = new QueryStatement(conn);

    // the string statement will use
    StringBuffer qry_s = new StringBuffer();

    switch (this._action) {

      case Query.ACTION_DELETE:
        qry_s.write("DELETE\nFROM ");
        break;
      case Query.ACTION_UPDATE:
        qry_s.write("UPDATE\n");
        break;
      case Query.ACTION_COUNT:
      case Query.ACTION_SELECT:
      default:
        var columns_stmnt = this.getColumnsClause(conn);
        stmnt.addIdentifiers(columns_stmnt.identifiers);
        stmnt.addParams(columns_stmnt.params);
        qry_s.write('SELECT ${columns_stmnt.getString()}\nFROM ');
        break;
    }

    var table_stmnt = this.getTablesClause(conn);
    stmnt.addIdentifiers(table_stmnt.identifiers);
    stmnt.addParams(table_stmnt.params);
    qry_s.write(table_stmnt.toString());
    var join_stmnt;
    if (!this._joins.isEmpty) {
      for (QueryJoin join in this._joins) {
        join_stmnt = join.getQueryStatement(conn);
        qry_s.write("\n\t");
        qry_s.write(join_stmnt.string);
        stmnt.addParams(join_stmnt.params);
        stmnt.addIdentifiers(join_stmnt.identifiers);
      }
    }

    if (Query.ACTION_UPDATE == this._action) {
      if (this._updateColumnValues.isEmpty) {
        throw new RuntimeError('Unable to build UPDATE query without update column values');
      }

      List column_updates = new List();

      this._updateColumnValues.forEach((column_name, column_value) {
        column_updates.add("${QueryStatement.IDENTIFIER} = ${QueryStatement.PARAM}");
        stmnt.addIdentifier(column_name);
        stmnt.addParam(column_value);
      });
      qry_s.write("\nSET ");
      qry_s.write(column_updates.join(','));
    }

    var where_stmnt = this.getWhereClause();

    if (null != where_stmnt && !where_stmnt.getString().trim().isEmpty) {
      qry_s.write("\nWHERE ");
      qry_s.write(where_stmnt.getString());
      stmnt.addParams(where_stmnt.params);
      stmnt.addIdentifiers(where_stmnt.identifiers);
    }

    if (!this._groups.isEmpty) {
      var clause = this.getGroupByClause();
      stmnt.addIdentifiers(clause.identifiers);
      stmnt.addParams(clause.params);
      qry_s.write(clause.getString());
    }

    if (null != this.getHaving()) {
      var having_stmnt = this.getHaving().getQueryStatement();
      if (null != having_stmnt) {
        qry_s.write("\nHAVING ");
        qry_s.write(having_stmnt);
        stmnt.addParams(having_stmnt.params);
        stmnt.addIdentifiers(having_stmnt.identifiers);
      }
    }

    if (Query.ACTION_COUNT != this._action && !this._orders.isEmpty) {
      var clause = this.getOrderByClause();
      stmnt.addIdentifiers(clause.identifiers);
      stmnt.addParams(clause.params);
      qry_s.write(clause.getString());
    }

    if (null != this._limit) {
      /* if (null != conn) {
        if (class_exists('DBMSSQL') && conn instanceof DBMSSQL) {
          qry_s = QueryStatement::embedIdentifiers(qry_s, stmnt.getIdentifiers(), conn);
          stmnt.setIdentifiers(array());
        }
        conn.applyLimit(qry_s, this._offset, this._limit);
      } else { */
        qry_s.write("\nLIMIT ");
        qry_s.write(this._offset != null ? "${this._offset} , " : '');
        qry_s.write(this._limit);
     // }
    }

    if (Query.ACTION_COUNT == this._action && this.needsComplexCount()) {
      var query = qry_s.toString();
      qry_s = new StringBuffer();
      qry_s.write("SELECT count(0)\nFROM (${query}) a");
    }

    stmnt.setString(qry_s.toString());
    return stmnt;
  }

  QueryStatement getTablesClause(conn) {

    var table = this.getTable();

    if (null == table) {
      throw new Exception('No table specified.');
    }

    var statement = new QueryStatement(conn);
    String alias = this.getAlias();
    var table_statement;
    String table_string;
    // if table is a Query, get its QueryStatement
    if (table is Query) {
      table_statement = (table as Query).getQuery(conn);
      table_string = '(${table_statement.getString()})';
    } else {
      table_statement = null;
    }

    switch (this._action) {
      case Query.ACTION_UPDATE:
      case Query.ACTION_COUNT:
      case Query.ACTION_SELECT:
        // setup identifiers for table_string
        if (null != table_statement) {
          statement.addIdentifiers(table_statement.identifiers);
          statement.addParams(table_statement.params);
        } else {
          // if table has no spaces, assume it is an identifier
          if ((table as String).indexOf(" ") == -1) {
            statement.addIdentifier(table);
            table_string = QueryStatement.IDENTIFIER;
          } else {
            table_string = table.toString();
          }
        }

        // append $alias, if it's not empty
        if (!alias.isEmpty) {
          table_string = "${table_string} AS ${alias}";
        }
        StringBuffer sb = new StringBuffer();
        // setup identifiers for any additional tables
        if (!this._extraTables.isEmpty) {
          String extra_table_string;
          sb.write("(");
          sb.write(table_string);
          this._extraTables.forEach((String t_alias, extra_table) {
            if (extra_table is Query) {
              var extra_table_statement = (extra_table as Query).getQuery(conn);
              extra_table_string = '(${extra_table_statement.getString()}) AS  ${t_alias}';
              statement.addParams(extra_table_statement.params);
              statement.addIdentifiers(extra_table_statement.identifiers);
            } else {
              extra_table_string = extra_table.toString();
              if (extra_table_string.indexOf(' ') == -1) {
                extra_table_string = QueryStatement.IDENTIFIER;
                statement.addIdentifier(extra_table);
              }
              if (t_alias != extra_table) {
                extra_table_string = "${extra_table_string} AS ${t_alias}";
              }
            }
            sb.write(", ");
            sb.write(extra_table_string);
          });
          sb.write(")");
        }
        statement.setString(sb.toString());
        break;
      case Query.ACTION_DELETE:
        if (null != table_statement) {
          statement.addIdentifiers(table_statement.identifiers);
          statement.addParams(table_statement.params);
        } else {
          // if table has no spaces, assume it is an identifier
          if (table.indexOf(' ') == -1) {
            statement.addIdentifier(table);
            table_string = QueryStatement.IDENTIFIER;
          } else {
            table_string = table;
          }
        }

        // append $alias, if it's not empty
        if (!alias.isEmpty) {
          table_string = "${table_string} AS ${alias}";
        }
        statement.setString(table_string);
        break;
      default:
        throw new RuntimeError('Uknown action "' + this._action + '", cannot build table list');
    }
    return statement;
  }

  bool hasAggregates() {
    if (!this._groups.isEmpty) {
      return true;
    }
    this._columns.forEach((k, String column) {
      if (column.indexOf('(') != -1) {
        return true;
      }
    });
    return false;
  }

  bool needsComplexCount() {
    return this.hasAggregates()
    || null != this._having
    || null != this._distinct;
  }

  QueryStatement getColumnsClause(conn) {
    String table = this.getTable();

    if (table.isEmpty) {
      throw new Exception('No table specified.');
    }

    QueryStatement statement = new QueryStatement(conn);
    String alias = this.getAlias();
    String action = this._action;

    if (Query.ACTION_DELETE == action) {
      return statement;
    }

    if (Query.ACTION_COUNT == action) {
      if (!this.needsComplexCount()) {
        statement.setString('count(0)');
        return statement;
      }

      if (null == this.getHaving()) {
        if (!this._groups.isEmpty) {
          var groups = this._groups;

          for(var x = 0; x < groups.length; ++x) {
            statement.addIdentifier(groups[x]);
            groups[x] = QueryStatement.IDENTIFIER;
          }
          statement.setString(groups.join(', '));
          return statement;
        }

        if (null != this._distinct && !this._columns.isEmpty) {
          List columns_to_use = new List();
          this._columns.forEach((k, String column) {
            if (column.indexOf('(') != -1) {
              statement.addIdentifier(column);
              columns_to_use.add(QueryStatement.IDENTIFIER);
            }
          });
          if (!columns_to_use.isEmpty) {
            statement.setString(columns_to_use.join(', '));
            return statement;
          }
        }
      }
    }

    // setup columns_string
    String columns_string;
    if (!this._columns.isEmpty) {
      List placeholders = new List();
      _columns.forEach((k, String column) {
        statement.addIdentifier(column);
        placeholders.add(QueryStatement.IDENTIFIER);
      });
      columns_string = placeholders.join(', ');
    } else if (!alias.isEmpty) {
      // default to selecting only columns from the target table
      columns_string = "${alias}.*";
    } else {
      // default to selecting only columns from the target table
      columns_string = QueryStatement.IDENTIFIER + '.*';
      statement.addIdentifier(table);
    }

    if (this._distinct) {
      columns_string = "DISTINCT ${columns_string}";
    }

    statement.setString(columns_string);
    return statement;
  }

  QueryStatement getWhereClause() {
    return this.getWhere().getQueryStatement();
  }

  QueryStatement getOrderByClause([conn = null]) {
    QueryStatement statement = new QueryStatement(conn);
    List qorders = new List();
    for (String order in this._orders) {
      List order_parts = order.split(" ");
      if (order_parts.length == 1 || order_parts.length == 2) {
        statement.addIdentifier(order_parts[0]);
        order_parts[0] = QueryStatement.IDENTIFIER;
      }
      qorders.add(order_parts.join(" "));
    }
    statement.setString("\nORDER BY " + qorders.join(", "));
    return statement;
  }

  QueryStatement getGroupByClause([conn = null]) {
    var statement = new QueryStatement(conn);
    if (!this._groups.isEmpty) {
      List sgroups = new List();
      for(var group in this._groups) {
        statement.addIdentifier(group);
        sgroups.add(QueryStatement.IDENTIFIER);
      }
      statement.setString("\nGROUP BY " + sgroups.join(', '));
    }
    return statement;
  }

  String toString() {
    Query q = this;
    if (q.getTable().isEmpty) {
      q.setTable('{UNSPECIFIED-TABLE}');
    }
    return q.getQuery().toString();
  }

  int doCount([conn = null]) {
    Query q = this;

    if (q.getTable().isEmpty) {
      throw new RuntimeError('No table specified.');
    }

    q.setAction(Query.ACTION_COUNT);
    return q.getQuery(conn).bindAndExecute().fetchColumn();
  }

  int doDelete([conn = null]) {
    Query q = this;

    if (q.getTable().isEmpty) {
      throw new RuntimeError('No table specified.');
    }

    q.setAction(Query.ACTION_DELETE);
    return q.getQuery(conn).bindAndExecute().rowCount();
  }

  doSelect([conn = null]) {
    Query q = this;

    if (q.getTable().isEmpty) {
      throw new RuntimeError('No table specified.');
    }

    q.setAction(Query.ACTION_SELECT);
    return q.getQuery(conn).bindAndExecute();
  }

  /**
   * Do not use this if you can avoid it.  Just use doUpdate.
   * @deprecated
   * @see Query::doUpdate
   * @return Query

  function setUpdateColumnValues(array column_values) {
    this._updateColumnValues = column_values;
    return this;
  }*/

  int doUpdate(Map column_values, [conn = null]) {
    Query q = this;

    q._updateColumnValues = column_values;

    if (q.getTable().isEmpty) {
      throw new RuntimeError('No table specified.');
    }

    q.setAction(Query.ACTION_UPDATE);
    return  q.getQuery(conn).bindAndExecute().rowCount();
  }

}
