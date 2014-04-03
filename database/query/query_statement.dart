part of dabl_query;

class QueryStatement {
  /**
   * character to use as a placeholder for a quoted identifier
   */
  static final String IDENTIFIER = '[?]';

  /**
   * character to use as a placeholder for an escaped parameter
   */
  static final String PARAM = '?';

  /**
   * @var string
   */
  String _query_string = '';

  /**
   * @var array
   */
  List _params = new List();

  /**
   * @var DABLPDO
   */
  String _connection;

  /**
   * @var array
   */
  List _identifiers = new List();

  QueryStatement([this._connection = null]);

  void setConnection(conn) {
    this._connection = conn;
  }

  String getConnection() {
    return _connection;
  }

  void setString(String string){
    this._query_string = string;
  }

  String getString() {
    return _query_string;
  }

  void addParams(List params) {
    this._params.addAll(params);
  }

  void setParams(List params) {
    this._params = params;
  }

  void addParam(param) {
    _params.add(param);
  }

  List getParams() {
    return _params;
  }

  void addIdentifiers(List idents) {
    this._identifiers.addAll(idents);
  }

  void setIdentifiers(idents) {
    _identifiers = idents;
  }

  void addIdentifier(ident) {
    _identifiers.add(ident);
  }

  List getIdentifiers() {
    return _identifiers;
  }

  String toString() {
    String string = this._query_string;
    var conn = this._connection;

    // if a connection is available, use it
    /*
    if (null == $conn && class_exists('DBManager')) {
      $conn = DBManager.getConnection();
    }*/

    string = QueryStatement.embedIdentifiers(string, this._identifiers.toList(), conn);
    return QueryStatement.embedParams(string, this._params.toList(), conn);
  }

  static String embedIdentifiers(String string, List identifiers, [conn = null]) {
    /*
    if (null != conn) {
      identifiers = conn.quoteIdentifier(identifiers);
    }
    */

    for(var x = 0; x < identifiers.length; ++x) {
      if(string.indexOf(QueryStatement.IDENTIFIER) == -1){
        break;
      }
      string = string.replaceFirst(QueryStatement.IDENTIFIER, identifiers[x]);
    }

    if(string.indexOf(QueryStatement.IDENTIFIER) != -1){
      throw new Exception('The number of replacements does not match the number of identifiers');
    }
    return string;
  }

  static String embedParams(String string, List params, [conn = null]) {
    if (false && null != conn) {
     // params = $conn->prepareInput($params);
    } else {
      for(int x = 0; x < params.length; ++ x) {
        var value = params[x];
        if (value is num) {
          continue;
        } else if (value is bool) {
          value = (value as bool) ? 1 : 0;
        } else if (null == value ) {
          value = 'NULL';
        } else {
          value = "'${value}'";
        }
        params[x] = value;
      }
    }

    for(var x = 0; x < params.length; ++x) {
      string = string.replaceFirst(QueryStatement.PARAM, params[x].toString());
    }

    if(string.indexOf(QueryStatement.PARAM) != -1){
      throw new Exception('The number of replacements does not match the number of parameters');
    }
    return string;
  }

  bindAndExecute() {
    /*
    var conn = this._connection;
    conn = conn || Adapter.getConnection();
    return conn.execute(this._qString, this._params);
    */
  }
}
