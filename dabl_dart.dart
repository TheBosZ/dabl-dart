import "query.dart";
void main() {
  Query q = new Query('employees');
  String queryinjection = '\'; delete * from * -- bob';
  String firstname = 'bob';
  q.add('type', 2);
  q.add('firstname', firstname, Query.NOT_EQUAL);
  q.add('firstname', queryinjection);
  Condition c = new Condition();
  c.add('fired', false);
  c.addOr('hired', false);
  q.add(c);
  print(q);
}