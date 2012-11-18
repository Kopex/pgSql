/**
* @copyright  (c) Kopex 2012
* @link       git://github.com/Kopex/pgSql.git
*/

CREATE OR REPLACE FUNCTION to_hex(bin bit) RETURNS text
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $$
declare

i int;s text;size int;k int;

begin
size=length(bin);s='';
k = size % 4;
if k > 0 then
  s = upper(to_hex(substring(bin,1,k)::int));
end if;
for i in k+1..size by 4 loop
  s = s || upper(to_hex(substring(bin,i,4)::int));
end loop;
return s;
end
$$;
COMMENT ON FUNCTION to_hex(bin bit) IS 'convertor any bits to HEX-text';

CREATE OR REPLACE FUNCTION hex_cast(text) RETURNS bit varying
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $_$
declare retval record;
begin
execute 'select X' || quote_literal($1) || ' as a' into retval;
return retval.a;
end
$_$;
COMMENT ON FUNCTION hex_cast(text) IS 'translator HEX-text to bits';

CREATE OR REPLACE FUNCTION bit_cast(text) RETURNS bit varying
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $_$
begin
return B'' || $1;
end
$_$;
COMMENT ON FUNCTION bit_cast(text) IS 'translator BIN-text to bits';

CREATE OR REPLACE FUNCTION get_bit(bin bit,r int,len int default 0) RETURNS integer 
  LANGUAGE plpgsql IMMUTABLE STRICT
  AS $$
declare
  ln int;
begin
  if len <= 0 then ln = length(bin);
  else ln = len;
  end if;
  return substring(bin,ln-r,1)::int;
end
$$;
COMMENT ON FUNCTION get_bit(bit, integer, integer) IS 'get digit (r 0...len-1]) value from any bits';

CREATE OR REPLACE FUNCTION bin2bytea(bin bit)
  RETURNS bytea AS
$BODY$
declare
k int;l int;s bytea;i int;b varbit;
begin
l=length(bin);
s=rpad('',l/8,'-=');
for k in 1..l by 16  loop
  b = substring(bin,k,16);
  --Raise info '%',to_hex(b);
  For i in 0..15 loop 
    s=set_bit(s,i+k-1,get_bit(b,i));
  end loop;
end loop;
return s;
end
$BODY$
LANGUAGE 'plpgsql' IMMUTABLE STRICT;
COMMENT ON FUNCTION bin2bytea(bit) is 'convertor any bit (size >=16 and (size mod 16 =0) bit) to bytea';

CREATE OR REPLACE FUNCTION overbin(bin1 bit,bin2 bit,pos integer,len integer default NULL::int) RETURNS bit 
AS $$
declare
  l int;
begin
  if len > 0 then l=len; else l=length(bin2);end if;
      
  return substring(bin1, 1, (pos - 1)) || bin2 || substring(bin1, (pos + l));
end
$$
LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION swapbits(bin bit,dig1 int,dig2 int,len int) RETURNS bit 
AS $$
declare
  x varbit;
begin
  x = B'' || repeat('0',length(bin)-len)||repeat('1',len);
  x = ((bin >> dig1) # (bin >> dig2)) & x;
  return bin # ((x << dig1) | (x << dig2));
end
$$
LANGUAGE plpgsql IMMUTABLE STRICT;
COMMENT ON FUNCTION swapbits(bit,int,int,int) is 'Обмен порции битов из разряда 1 и 2 длинной len';

CREATE OR REPLACE FUNCTION setbits(bin1 bit,bin2 bit,pos int) RETURNS bit 
AS $$
declare
  mk varbit;vl varbit;
  l1 int;l2 int;i int;
begin
  l1 = length(bin1);
  l2 = length(bin2);
  i = pos - 1;

  mk = bit_cast(repeat('1',l1));
  vl = (bin2||substring(mk,1,l1-l2)) >> i;
  mk = (mk >> i) & (mk << (l1-l2-i));
   
  return bin1 #  ((bin1 # vl) & mk);
end
$$
LANGUAGE plpgsql IMMUTABLE STRICT;
COMMENT ON FUNCTION setbits(bit,int,int,int) is 'Копирование bin2 в bin1 с позиции Pos';
