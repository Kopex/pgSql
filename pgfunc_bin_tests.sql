/**
* @copyright  (c) Kopex 2012
* @link       git://github.com/Kopex/pgSql.git
*/
--tests to_hex
select to_hex(123456789::int),to_hex(123456789::int::bit(32));
select to_hex(X'12ABCDEF'::int),to_hex(X'12ABCDEF');
select to_hex(X'2ABCDEF'::int),to_hex(X'2ABCDEF');
select to_hex(B'001100'::int),to_hex(B'001100');

--tests float8 (64 bit real)
select test,to_hex(x_test::bit(64)),
to_hex(real64bit(test))::text as real64hex,
bit64real(x_test) as bit64real,
bit64real(real64bit(test)) as real64real,
test = bit64real(real64bit(test))
from (
select 0.2::float8 as test,X'3FC999999999999A' as x_test
Union
select 83125::float8 as test,X'40F44B5000000000'
union
select -83125::float8 as test,X'C0F44B5000000000'
union
select 83125.5334300::float8 as test,X'40F44B5888EDE54B' --!!!
union
select -2.350004769126645e-8::float8 as test,X'BE593BA4D81A30B8'
union
select -6.192790934171437e-011::float8 as test,X'BDD105CA09A96020'
) as s;

--tests rev
select "position"(rev(bin) # reverse(bin),B'1')=0 
from (
select X'12' as bin union --8
select X'1234' union --32
select X'12345678' union --64
select X'1234567890ABCDEF' union --128
select X'1234567890ABCDEF'||X'1234567890ABCDEF' --512
) as sub

--conv bin2bytea
select encode(bin2bytea(X'12345678'),'hex')='34127856'