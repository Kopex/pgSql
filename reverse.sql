/**
* @copyright  (c) Kopex 2012
* @link       git://github.com/Kopex/pgSql.git
* references  http://graphics.stanford.edu/~seander/bithacks.html
*/
CREATE OR REPLACE FUNCTION rev16(bin bit)
  RETURNS bit AS
$BODY$
declare
  i varbit;
begin
  i=bin;
  case length(i)
  when 16 then
    i = (((i & X'aaaa') >> 1) | ((i & X'5555') << 1));
    i = (((i & X'cccc') >> 2) | ((i & X'3333') << 2));
    i = (((i & X'f0f0') >> 4) | ((i & X'0f0f') << 4));
    i = (((i & X'ff00') >> 8) | ((i & X'00ff') << 8));
  when 32 then
    i = (((i & X'aaaaaaaa') >> 1) | ((i & X'55555555') << 1));
    i = (((i & X'cccccccc') >> 2) | ((i & X'33333333') << 2));
    i = (((i & X'f0f0f0f0') >> 4) | ((i & X'0f0f0f0f') << 4));
    i = (((i & X'ff00ff00') >> 8) | ((i & X'00ff00ff') << 8));
  end case;
  return i;
end
$BODY$
  LANGUAGE 'plpgsql' IMMUTABLE STRICT
  COST 100;

CREATE OR REPLACE FUNCTION rev32(bin bit)
  RETURNS bit AS
$BODY$
declare
  i bit(32);
begin
  i=bin;
    i = (((i & X'aaaaaaaa') >> 1) | ((i & X'55555555') << 1));
    i = (((i & X'cccccccc') >> 2) | ((i & X'33333333') << 2));
    i = (((i & X'f0f0f0f0') >> 4) | ((i & X'0f0f0f0f') << 4));
    i = (((i & X'ff00ff00') >> 8) | ((i & X'00ff00ff') << 8));
    return ((i >> 16) | (i << 16));
end
$BODY$
  LANGUAGE 'plpgsql' IMMUTABLE STRICT
  COST 100;

CREATE OR REPLACE FUNCTION rev(bin bit)
  RETURNS bit AS
$BODY$
declare
  v varbit;mask varbit;
  s bit(32);i int;
  len int;
begin
  len=length(bin);
  mask = B''||repeat('1',len);
  s=len::bit(32);
  v=bin;
  loop
    s=s>>1;i=s::int;
    EXIT WHEN i = 0;
    mask = mask # (mask << i);
    --Raise info '% % %',i,to_hex(mask),to_hex(~mask);
    v = ((v >> i) & mask) | ((v << i) & ~mask);
  end loop;
  return v;
end
$BODY$
  LANGUAGE plpgsql IMMUTABLE STRICT
  COST 100;

CREATE OR REPLACE FUNCTION reverse(bin bit)
  RETURNS bit AS
$BODY$
declare
  s varbit;
  i int;
begin

  i=length(bin);
  if i % 8 = 0 then
    return rev(bin);
  else
    s=B'';
    While i>0 loop
      s=s||substring(bin,i,1);
      i=i-1;
    end loop;
    return s;
  end if;
end
$BODY$
  LANGUAGE plpgsql IMMUTABLE STRICT
  COST 100;

CREATE OR REPLACE FUNCTION _re16(bit)
  RETURNS bit AS
$BODY$

begin

return
reverse(substring($1,1,16))||
reverse(substring($1,17,16))||
reverse(substring($1,33,16))||
reverse(substring($1,49,16))||
reverse(substring($1,65,16))||
reverse(substring($1,81,16))||
reverse(substring($1,97,16))||
reverse(substring($1,113,16))||
reverse(substring($1,129,16))||
reverse(substring($1,145,16))||
reverse(substring($1,161,16))||
reverse(substring($1,177,16))||
reverse(substring($1,193,16))||
reverse(substring($1,209,16))||
reverse(substring($1,225,16))||
reverse(substring($1,241,16))||
reverse(substring($1,257,16))||
reverse(substring($1,273,16))||
reverse(substring($1,289,16))||
reverse(substring($1,305,16))||
reverse(substring($1,321,16))||
reverse(substring($1,337,16))||
reverse(substring($1,353,16))||
reverse(substring($1,369,16))||
reverse(substring($1,385,16))||
reverse(substring($1,401,16))||
reverse(substring($1,417,16))||
reverse(substring($1,433,16))||
reverse(substring($1,449,16))||
reverse(substring($1,465,16))||
reverse(substring($1,481,16))||
reverse(substring($1,497,16));

end
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;