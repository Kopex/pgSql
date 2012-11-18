/**
* @copyright  (c) Kopex 2012
* @link       git://github.com/Kopex/pgSql.git
* references  http://babbage.cs.qc.cuny.edu/IEEE-754
*/
CREATE OR REPLACE FUNCTION bit32real(bit) RETURNS real
    LANGUAGE plpgsql
    AS $_$
declare
	s int;
	e int;
	m int;
	r real;
begin
	if ($1>>31)::int THEN s=-1; else s=1;end if;
	e = ($1<<1)::bit(8)::int;
	if e=0 then m=(($1 & X'007fffff')<<1)::int;
	else        m=(($1 & X'007fffff')|X'00800000')::int;
	end if;
	e=e-127-23;
	return s*m*pow(2,e);
end
$_$;

CREATE OR REPLACE FUNCTION real32bit(inp real) RETURNS bit
    LANGUAGE plpgsql
    AS $$
declare
	BinVal bit[2102];Res bit[32];
	znak bit;Result "bit";
	intpart int;decpart real;
	cnst CONSTANT int = 2102;
	bias CONSTANT int = 1024;
	index1 int;binexpnt int;b bit;index2 int;
begin
     
  if inp = 0 then return 0::bit(32);end if;
  if inp < 0 then znak=1; else znak=0; end if;

        --convert and seperate input to integer and decimal parts
        intpart = floor(abs(inp))::int;
        decpart = abs(inp) - intpart;
        --convert integer part
        index1 = bias;
        while(((intpart::real / 2) != 0) and (index1 >= 0)) loop
        
          BinVal[index1] = (intpart % 2)::bit;
          if (intpart % 2 = 0) then intpart = intpart / 2;
          else intpart = floor(intpart::real / 2 - 0.5)::int;--???
          end if;
          index1= index1 - 1;
        end loop;

        --convert decimal part
        index1 = bias + 1;
        while ((decpart > 0) and (index1 < cnst)) loop
        
          decpart = decpart * 2;
          if (decpart >= 1) then
            b = 1; 
            decpart = decpart-1; 
          else 
	    b = 0; 
	  end if;
	  
	  BinVal[index1]=b;
	  index1  = index1 +1;
  end loop;

  --obtain exponent value
  index1 = 0;

  --find most significant bit of significand
  while ((index1 < cnst) and (coalesce(BinVal[index1],0::bit) != 1::bit)) loop 
  index1 = index1+1; end loop;

  binexpnt = bias - index1;
	index1=index1+1;
	For index2 in 1 .. 31 loop
	  if (index2 > 8) then
		Res[index2] = coalesce(BinVal[index1],0::bit);
		index2 =index2+1;
		index1 =index1+1;
	  else
		Res[index2] =0::bit;
	  end if;
	  IF (index1 = cnst) then exit; end if;
	end loop;

	--convert exponent value to binary representation
     index1 = 8;
     binexpnt = binexpnt+127;    
    while ((binexpnt::real / 2) != 0) loop
      Res[index1] = binexpnt % 2;
      if (binexpnt % 2 = 0) then binexpnt = binexpnt / 2;
      else binexpnt = floor(binexpnt::real / 2 - 0.5)::int;
      end if;
      index1 = index1 - 1;
    end loop;	
	Result=znak;
	For index1 in 1 .. 31 loop
	  Result=Result||Res[index1];
	end loop;
	
return Result;
end
$$;

CREATE OR REPLACE FUNCTION bit64real(bit) RETURNS double precision
    LANGUAGE plpgsql
    AS $_$
declare
	s int;
	e int;
	m int8;
begin
	if ($1>>63)::int8 THEN s=-1; else s=1;end if;
	e = ($1<<1)::bit(11)::int;
	if e=0 then m=(($1 & X'000fffffffffffff')<<1)::int8;
	else        m=(B'1'||(($1<<12)::bit(52)))::"bit"::int8;
	end if;
	e=e-1023-52;
	return s*m*pow(2,e);
end
$_$;

CREATE OR REPLACE FUNCTION real64bit(inp double precision) RETURNS bit
    LANGUAGE plpgsql
    AS $$
declare
	BinVal bit[2102];Res bit[64];
	znak bit;Result "bit";
	intpart int8;decpart float8;
	cnst CONSTANT int = 2102;
	bias CONSTANT int = 1024;
	
	index1 int;binexpnt int;b bit;index2 int;
begin
     
  --for index1 in 0 .. cnst loop BinVal[index1]=0; end loop;
  if inp < 0 then znak=1; else znak=0; end if;
        --convert and seperate input to integer and decimal parts
        intpart = floor(abs(inp));
        decpart = abs(inp) - intpart;
        --convert integer part
        index1 = bias;
        while(((intpart::float8 / 2) != 0) and (index1 >= 0)) loop
        
          BinVal[index1] = (intpart % 2)::bit;
          if (intpart % 2 = 0) then intpart = intpart / 2;
          else intpart = floor(intpart::float8 / 2 - 0.5)::int8;--???
          end if;
          index1= index1 - 1;
        end loop;

        --convert decimal part
        index1 = bias + 1;
        while ((decpart > 0) and (index1 < cnst)) loop
        
          decpart = decpart * 2;
          if (decpart >= 1) then
            b = 1; 
            decpart = decpart-1; 
          else 
	    b = 0; 
	  end if;
	  
	  BinVal[index1]=b;
	  index1  = index1 +1;
  end loop;

  --obtain exponent value
  index1 = 0;

  --find most significant bit of significand
  while ((index1 < cnst) and (coalesce(BinVal[index1],0::bit) != 1::bit)) loop 
  index1 = index1+1; end loop;

  binexpnt = bias - index1;
	index1=index1+1;
	For index2 in 1 .. 63 loop
	  if (index2 > 11) then
		Res[index2] = coalesce(BinVal[index1],0::bit);
		index2 =index2+1;
		index1 =index1+1;
	  else
		Res[index2] =0::bit;
	  end if;
	  IF (index1 = cnst) then exit; end if;
	end loop;

	--convert exponent value to binary representation
     index1 = 11;--f64
     binexpnt = binexpnt+1023;--f64    
    while ((binexpnt::float8 / 2) != 0) loop
      Res[index1] = binexpnt % 2;
      if (binexpnt % 2 = 0) then binexpnt = binexpnt / 2;
      else binexpnt = floor(binexpnt::float8 / 2 - 0.5)::int8;
      end if;
      index1 = index1 - 1;
    end loop;	
	Result=znak;
	For index1 in 1 .. 63 loop
	  Result = Result||Res[index1];
	end loop;
	
return Result;
end
$$;
