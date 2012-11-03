CREATE OR REPLACE FUNCTION to_hex(bin bit) RETURNS text
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $$
declare

i int;s text;size int;

begin
size=length(bin);s='';
for i in 1..size by 4 loop
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
COMMENT ON FUNCTION bit_cast(text) IS 'translator HEX-text to bits';

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
