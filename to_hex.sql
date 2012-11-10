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

declare

retval record;

begin

for retval in execute 'select X' || quote_literal($1) || ' as a' loop
	return retval.a;
end loop;

end
$_$;
COMMENT ON FUNCTION hex_cast(text) IS 'translator HEX-text to bits';

CREATE OR REPLACE FUNCTION bit_cast(text) RETURNS bit varying
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $_$

declare

retval record;

begin

for retval in execute 'select B' || quote_literal($1) || ' as a' loop
	return retval.a;
end loop;

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

