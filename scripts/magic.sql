
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


INSERT INTO c (mes, dia, perfil_usuari, c0)
SELECT mes, dia, perfil_usuari, SUM(pi)
FROM perfils_inicials
GROUP BY mes, dia, perfil_usuari;


INSERT INTO h (mes, dia, hora, perfil_usuari, h0)
SELECT  perfils.mes, perfils.dia, perfils.hora, perfils.perfil_usuari,
        ((SELECT pi FROM perfils_inicials AS p WHERE p.mes=perfils.mes AND p.dia=perfils.dia AND p.hora=perfils.hora AND p.perfil_usuari=perfils.perfil_usuari)/
        (SELECT c0 FROM c AS c WHERE c.mes=perfils.mes AND c.dia=perfils.dia AND c.perfil_usuari=perfils.perfil_usuari)) AS h0
FROM perfils_inicials AS perfils;








INSERT INTO c_accumulate (mes, perfil_usuari, accumulate_p_month)
SELECT c.mes, c.perfil_usuari, SUM(c.c0) AS suma_c_per_mes
FROM c as c
GROUP BY c.mes, c.perfil_usuari;


INSERT INTO m (mes, perfil_usuari, m0)
SELECT DISTINCT c.mes, c.perfil_usuari,
( (SELECT  acc.accumulate_p_month FROM c_accumulate AS acc WHERE acc.mes=c.mes AND acc.perfil_usuari=c.perfil_usuari) /
(SELECT sum_year FROM (SELECT acc2.perfil_usuari, SUM(acc2.accumulate_p_month) AS sum_year FROM c_accumulate AS acc2 WHERE acc2.perfil_usuari=c.perfil_usuari GROUP BY acc2.perfil_usuari) AS foo) )
FROM c AS c;

--(h.h0 * (1 + ((alpha) * (( big division) -1) ) ) )
-- big_division = ( (SELECT) / (SELECT) ) /  ( (SELECT) / (SELECT) )
