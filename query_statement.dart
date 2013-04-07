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
  String query_string = '';

  /**
   * @var array
   */
  List params = new List();

  /**
   * @var DABLPDO
   */
  String _connection;

  /**
   * @var array
   */
  List identifiers = new List();

  QueryStatement([this._connection = null]);

  void setConnection(conn) {
    this._connection = conn;
  }

  String getConnection() {
    return _connection;
  }

  void setString(String string){
    this.query_string = string;
  }

  String getString() {
    return query_string;
  }

  void addParams(List params) {
    this.params.addAll(params);
  }

  void setParams(List params) {
    this.params = params;
  }

  void addParam(param) {
    params.add(param);
  }

  List getParams() {
    return params;
  }

  void addIdentifiers(List idents) {
    identifiers.addAll(idents);
  }

  void setIdentifiers(idents) {
    identifiers = idents;
  }

  void addIdentifier(ident) {
    identifiers.add(ident);
  }


  static String embedParams(String string, List parameters, [conn]) {
    if(string.split(QueryStatement.IDENTIFIER).length - 1 != parameters.length) {
      throw new Exception("The number of occurences of ${QueryStatement.IDENTIFIER} does not match the number of parameters");
    }

    if(parameters.length == 0) {
      return string;
    }

    var currentIndex = string.length;
    var plen = QueryStatement.IDENTIFIER.length;
    var identifier;
    for(var x = parameters.length - 1; x>=0; --x) {
      identifier = parameters[x];
      currentIndex = string.lastIndexOf(IDENTIFIER, currentIndex);
      if(currentIndex == -1) {
        throw new Exception("The number of occurences of ${QueryStatement.IDENTIFIER} does not match the number of parameters");
      }
      string = string.substring(0, currentIndex).concat(identifier).concat(string.substring(currentIndex + plen));
    }

    return string;
  }
}
