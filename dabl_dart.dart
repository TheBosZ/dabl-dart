import "query.dart";
void main() {
  Query q = new Query();
  q.add('nathan', 2);
  q.add('bob', 'fred');
  Condition c = new Condition();
  c.add('fired', false);
  c.addOr('hired', false);
  q.add(c);
  print(q);
}