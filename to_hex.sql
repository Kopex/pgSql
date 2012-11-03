CREATE FUNCTION to_hex(bin bit) RETURNS text
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
