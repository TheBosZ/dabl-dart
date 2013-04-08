part of dabl_query;

class QueryJoin {

    var _table;

    var _alias;

    var _onClause;

    bool _isLikePropel = false;

    String _leftColumn;

    String _rightColumn;

    String _joinType = Query.JOIN;

    QueryJoin(var table_or_column, [on_clause_or_column = null, join_type = Query.JOIN]) {

      // check for Propel type join: table.column, table.column
      if (
          !(table_or_column is Query)
          && !(on_clause_or_column is Condition)) {
            String clause = on_clause_or_column as String;
            String table = table_or_column as String;
            if(
                clause.indexOf('=') == -1
            && clause.indexOf(' ') == -1
            && clause.indexOf('(') == -1
            && clause.allMatches('.').length == 1
            && table.indexOf(' ') == -1
            && table.indexOf('=') == -1
            && table.indexOf('(') == -1
            && table.allMatches('.').length == 1
        ) {
          this._isLikePropel = true;
          this._leftColumn = table_or_column;
          this._rightColumn = on_clause_or_column;
          this.setTable(this._rightColumn.substring(0, this._rightColumn.indexOf('.')));
          this.setJoinType(join_type);
          return;
        }
      }

      this.setTable(table_or_column)
      ..setOnClause(on_clause_or_column)
      ..setJoinType(join_type);
  }

  String toString() {
    QueryJoin j = this;
    if (j.getTable().isEmpty) {
      j.setTable('{UNSPECIFIED-TABLE}');
    }
    return j.getQueryStatement().toString();
  }

  static QueryJoin create(table_or_column, [on_clause_or_column = null, join_type = Query.JOIN]) {
    return new QueryJoin(table_or_column, on_clause_or_column, join_type);
  }

  QueryJoin setTable(var table_name) {
    if (!table_name is Query) {
      String tname = table_name as String;
      int space = tname.lastIndexOf(' ');
      var as_pos = tname.toUpperCase().lastIndexOf(' AS ');
      if (as_pos != space - 3) {
        as_pos = false;
      }
      if (space != 0) {
        this.setAlias(tname.substring(space + 1).trim());
        tname = tname.substring(0, as_pos == false ? space : as_pos).trim();
      }
      table_name = tname;
    }
    this._table = table_name;
    return this;
  }

  QueryJoin setAlias(var alias) {
    this._alias = alias;
    return this;
  }

  QueryJoin setOnClause(var on_clause) {
    this._isLikePropel = false;
    this._onClause = on_clause;
    return this;
  }

  QueryJoin setJoinType(var join_type) {
    this._joinType = join_type;
    return this;
  }

  getQueryStatement([conn = null]) {
    QueryStatement statement = new QueryStatement(conn);
    var table = this._table;
    var on_clause = this._onClause;
    var join_type = this._joinType;
    var alias = this._alias;

    if (table is Query) {
      QueryStatement table_statement = (table as Query).getQuery(conn);
      table = '(' + table_statement.getString() + ')';
      statement.addParams(table_statement.getParams());
      statement.addIdentifiers(table_statement.getIdentifiers());
    } else {
      statement.addIdentifier(table);
      table = QueryStatement.IDENTIFIER;
    }

    if (alias) {
      table += " AS ${alias}";
    }

    if (this._isLikePropel) {
      statement.addIdentifiers([this._leftColumn, this._rightColumn]);
      on_clause = QueryStatement.IDENTIFIER + ' = ' + QueryStatement.IDENTIFIER;
    } else if (null == on_clause) {
      on_clause = '1 = 1';
    } else if (on_clause is Condition) {
      QueryStatement on_clause_statement = (on_clause as Condition).getQueryStatement();
      on_clause = on_clause_statement.getString();
      statement.addParams(on_clause_statement.getParams());
      statement.addIdentifiers(on_clause_statement.getIdentifiers());
    }

    if ('' != on_clause) {
      on_clause = "ON (${on_clause})";
    }

    statement.setString("${join_type} ${table} ${on_clause}");
    return statement;
  }

  getTable() {
    return this._table;
  }

  String getAlias() {
    return this._alias;
  }

  getOnClause() {
    if (this._isLikePropel) {
      return this._leftColumn + ' = ' + this._rightColumn;
    }
    return this._onClause;
  }

  String getJoinType() {
    return this._joinType;
  }


}
