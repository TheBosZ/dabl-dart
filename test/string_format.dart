import 'package:unittest/unittest.dart';
import '../lib/string_format.dart';

main() {
	test('lcFirst', () {
		expect(StringFormat.lcFirst('CLASS'), equals('cLASS'));
	});

	test('ucFirst', () {
		expect(StringFormat.ucFirst('cLASS'), equals('CLASS'));
	});

	test('className', (){
		expect(StringFormat.className('test class'), equals('TestClass'));
	});

	test('classMethod', (){
		expect(StringFormat.classMethod('TEST CLASS METHOD'), equals('testClassMethod'));
	});

	test('pluralClassMethod', (){
		expect(StringFormat.pluralClassMethod('TEST CLASS METHOD'), equals('testClassMethods'));
	});


	test('classProperty', (){
		expect(StringFormat.classProperty('TEST CLASS PROPERTY'), equals('testClassProperty'));
	});

	 test('pluralClassProperty', (){
	 	expect(StringFormat.pluralClassProperty('TEST CLASS PROPERTY'), equals('testClassProperties'));
	 });

	test('url', (){
		expect(StringFormat.url('Action_Name'), equals('action-name'));
	});


	test('pluralUrl', (){
		expect(StringFormat.pluralUrl('ACTION_NAME'), equals('action-names'));
	});

	test('variable', (){
		expect(StringFormat.variable('HELLO how are you'), equals('hello_how_are_you'));
	});

	test('constant', (){
		expect(StringFormat.constant('constant name'), equals('CONSTANT_NAME'));
	});

	test('pluralVariable', (){
		expect(StringFormat.pluralVariable('HELLO how are you'), equals('hello_how_are_yous'));
	});

	test('titleCase', (){
		expect(StringFormat.titleCase('my class is really cool'), equals('MyClassIsReallyCool'));
	});

	test('getWords', (){
		expect(StringFormat.getWords('FBar'), equals(['F', 'Bar']));
		expect(StringFormat.getWords('fooB'), equals(['foo', 'B']));
		expect(StringFormat.getWords('45times'), equals(['45', 'times']));
	});


	test('plural', (){
		expect(StringFormat.plural('ox'), equals('oxen'));
	});

	test('removeAccents', (){
		String badStr = 'ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝßàáâãäåæçèéêëìíîïñòóôõöøùúûüýÿĀāĂăĄąĆćĈĉĊċČčĎďĐđĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħĨĩĪīĬĭĮįİıĲĳĴĵĶķĹĺĻļĽľĿŀŁłŃńŅņŇňŉŌōŎŏŐőŒœŔŕŖŗŘřŚśŜŝŞşŠšŢţŤťŦŧŨũŪūŬŭŮůŰűŲųŴŵŶŷŸŹźŻżŽžſƒƠơƯưǍǎǏǐǑǒǓǔǕǖǗǘǙǚǛǜǺǻǼǽǾǿ';
		String goodStr = 'AAAAAAAECEEEEIIIIDNOOOOOOUUUUYsaaaaaaaeceeeeiiiinoooooouuuuyyAaAaAaCcCcCcCcDdDdEeEeEeEeEeGgGgGgGgHhHhIiIiIiIiIiIJijJjKkLlLlLlLlllNnNnNnnOoOoOoOEoeRrRrRrSsSsSsSsTtTtTtUuUuUuUuUuUuWwYyYZzZzZzsfOoUuAaIiOoUuUuUuUuUuAaAEaeOo';
		expect(StringFormat.removeAccents(badStr), equals(goodStr));
	});

	test('clean', (){
		expect(StringFormat.clean('À \' Á \' Â'), equals('A  A  A'));
	});
}