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
  List _extraTables;
  List _updateColumnValues;
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
    _distinct = b;
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

  Query addJoin(){
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

  Query joinOnce(){
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

  QueryStatement getWhereClause() {
    return _where.getQueryStatement();
  }

}
