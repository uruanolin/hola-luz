
------------------- Inserts from CSV data ---------------------------------
---------------------------------------------------------------------------

----- Perfils Inicials
INSERT INTO perfils_inicials (mes, dia, hora, perfil_usuari, pi)
SELECT mes, dia, hora, 'a', pi_A FROM csv_perfils_inicials_i_demanda_referencia;

INSERT INTO perfils_inicials (mes, dia, hora, perfil_usuari, pi)
SELECT mes, dia, hora, 'b', pi_B FROM csv_perfils_inicials_i_demanda_referencia;

INSERT INTO perfils_inicials (mes, dia, hora, perfil_usuari, pi)
SELECT mes, dia, hora, 'c', pi_C FROM csv_perfils_inicials_i_demanda_referencia;

INSERT INTO perfils_inicials (mes, dia, hora, perfil_usuari, pi)
SELECT mes, dia, hora, 'd', pi_D FROM csv_perfils_inicials_i_demanda_referencia;

----- Demanda de referencia
INSERT INTO demanda_referencia (mes, dia, hora, dr)
SELECT mes, dia, hora, demanda_referencia FROM csv_perfils_inicials_i_demanda_referencia;

----- Demanda del sistema
INSERT INTO demanda_sistema (mes, dia, hora, ds)
SELECT mes, dia, hora, demanda_sistema FROM csv_demanda_sistema;


----------------------------------> intentar pivotar la tabla cargada en vez del hardcoded
----- Coeficients d'ajust
INSERT INTO coeficients_ajust (perfil_usuari, alpha, beta, gamma)
VALUES ('a', 0.29, 0.61, 1.6), ('b', 0.1, 0.51, 2), ('c', 1.1, 1, 1.3), ('d', 0.2, 0.1, 0.83);








------------------- Insert data into taules auxiliars
---------------------------------------------------------------------------


------------------- Step 0
---------------------------------------------------------------------------

INSERT INTO c0 (mes, dia, perfil_usuari, c)
SELECT mes, dia, perfil_usuari, SUM(pi)
FROM perfils_inicials
GROUP BY mes, dia, perfil_usuari;


INSERT INTO h0 (mes, dia, hora, perfil_usuari, h)
SELECT  perfils.mes, perfils.dia, perfils.hora, perfils.perfil_usuari,
        ((SELECT pi FROM perfils_inicials AS p WHERE p.mes=perfils.mes AND p.dia=perfils.dia AND p.hora=perfils.hora AND p.perfil_usuari=perfils.perfil_usuari)/
        (SELECT c FROM c0 WHERE c0.mes=perfils.mes AND c0.dia=perfils.dia AND c0.perfil_usuari=perfils.perfil_usuari)) AS calculated_h
FROM perfils_inicials AS perfils;






INSERT INTO c_accumulate (mes, perfil_usuari, accumulate_p_month)
SELECT mes, perfil_usuari, SUM(c) AS suma_c_per_mes
FROM c0
GROUP BY mes, perfil_usuari;


INSERT INTO m0 (mes, perfil_usuari, m)
SELECT DISTINCT c0.mes, c0.perfil_usuari,
( (SELECT  acc.accumulate_p_month FROM c_accumulate AS acc WHERE acc.mes=c0.mes AND acc.perfil_usuari=c0.perfil_usuari) /
(SELECT sum_year FROM (SELECT acc2.perfil_usuari, SUM(acc2.accumulate_p_month) AS sum_year FROM c_accumulate AS acc2 WHERE acc2.perfil_usuari=c0.perfil_usuari GROUP BY acc2.perfil_usuari) AS foo) )
FROM c0;





------------------- Step 1
---------------------------------------------------------------------------

--(h.h0 * (1 + ((alpha) * (( big division) -1) ) ) )
-- big_division = ( (SELECT) / (SELECT) ) /  ( (SELECT) / (SELECT) )




INSERT INTO h1 (mes, dia, hora, perfil_usuari, h)

SELECT h0.mes, h0.dia, h0.hora, h0.perfil_usuari,

(h0.h * (1 + ((SELECT ajust.alpha FROM coeficients_ajust AS ajust WHERE ajust.perfil_usuari=h0.perfil_usuari) *
(( (SELECT dsis.ds FROM demanda_sistema AS dsis WHERE dsis.mes=h0.mes AND dsis.dia=h0.dia AND dsis.hora=h0.hora) /
(SELECT SUM(dsis.ds) FROM demanda_sistema AS dsis WHERE dsis.mes=h0.mes AND dsis.dia=h0.dia) ) /
( (SELECT dref.dr FROM demanda_referencia AS dref WHERE dref.mes=h0.mes AND dref.dia=h0.dia AND dref.hora=h0.hora) /
(SELECT SUM(dref.dr) FROM demanda_referencia AS dref WHERE dref.mes=h0.mes AND dref.dia=h0.dia) ) -1) ) ) )

FROM h0;




INSERT INTO c1 (mes, dia, perfil_usuari, c)

SELECT c0.mes, c0.dia, c0.perfil_usuari,

(c0.c * (1 + ((SELECT ajust.beta FROM coeficients_ajust AS ajust WHERE ajust.perfil_usuari=c0.perfil_usuari) *
(( (SELECT SUM(dsis.ds) FROM demanda_sistema AS dsis WHERE dsis.mes=c0.mes AND dsis.dia=c0.dia) /
(SELECT SUM(dsis.ds) FROM demanda_sistema AS dsis WHERE dsis.mes=c0.mes) ) /
( (SELECT SUM(dref.dr) FROM demanda_referencia AS dref WHERE dref.mes=c0.mes AND dref.dia=c0.dia) /
(SELECT SUM(dref.dr) FROM demanda_referencia AS dref WHERE dref.mes=c0.mes) ) -1) ) ) )

FROM c0;



------------------- Final Step
---------------------------------------------------------------------------


INSERT INTO mf (mes, perfil_usuari, m)

SELECT m0.mes, m0.perfil_usuari,

(m0.m * (1 + ((SELECT ajust.gamma FROM coeficients_ajust AS ajust WHERE ajust.perfil_usuari=m0.perfil_usuari) *
((( SELECT SUM(dsis.ds) FROM demanda_sistema AS dsis WHERE dsis.mes=m0.mes) /
( SELECT SUM(dref.dr) FROM demanda_referencia AS dref WHERE dref.mes=m0.mes ) ) -1) ) ) )

FROM m0;




INSERT INTO hf (mes, dia, hora, perfil_usuari, h)
SELECT h1.mes, h1.dia, h1.hora, h1.perfil_usuari,
( ( h1.h ) / ( SELECT SUM(h1_1.h) FROM  h1 AS h1_1 WHERE h1_1.mes=h1.mes AND h1_1.dia=h1.dia AND h1_1.perfil_usuari=h1.perfil_usuari) )
FROM h1;



INSERT INTO cf (mes, dia, perfil_usuari, c)
SELECT c1.mes, c1.dia, c1.perfil_usuari,
( ( c1.c ) / ( SELECT SUM(c1_1.c) FROM  c1 AS c1_1 WHERE c1_1.mes=c1.mes AND c1_1.perfil_usuari=c1.perfil_usuari) )
FROM c1;




------------------- Final Profiles
---------------------------------------------------------------------------

INSERT INTO perfils_finals (mes, dia, hora, perfil_usuari, pf)
SELECT hf.mes, hf.dia, hf.hora, hf.perfil_usuari, (hf.h * cf.c * mf.m)
FROM hf, cf, mf
WHERE hf.mes=cf.mes AND hf.mes=mf.mes AND hf.dia=cf.dia AND hf.perfil_usuari=cf.perfil_usuari AND hf.perfil_usuari=mf.perfil_usuari;
