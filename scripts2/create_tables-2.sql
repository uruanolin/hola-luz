

DROP TABLE IF EXISTS csv_perfils_inicials_i_demanda_referencia;
CREATE TABLE csv_perfils_inicials_i_demanda_referencia(
    mes integer NOT NULL,
    dia integer NOT NULL,
    hora integer NOT NULL,

    pi_A double precision NOT NULL,
    pi_B double precision NOT NULL,
    pi_C double precision NOT NULL,
    pi_D double precision NOT NULL,
    demanda_referencia double precision NOT NULL,

    CONSTRAINT "PK_csv_perfils_inicials_i_demanda_referencia" PRIMARY KEY (mes,dia,hora)
);

DROP TABLE IF EXISTS csv_demanda_sistema;
CREATE TABLE csv_demanda_sistema(
    year integer NOT NULL,
    mes integer NOT NULL,
    dia integer NOT NULL,
    hora integer NOT NULL,
    horario integer NOT NULL,

    demanda_sistema double precision NOT NULL,
    CONSTRAINT "PK_csv_demanda_sistema" PRIMARY KEY (year,mes,dia,hora,horario)
);

DROP TABLE IF EXISTS csv_coeficients_ajust;
CREATE TABLE csv_coeficients_ajust(
    coeficient_name character varying(32) NOT NULL,

    perfil_A double precision NOT NULL,
    perfil_B double precision NOT NULL,
    perfil_C double precision NOT NULL,
    perfil_D double precision NOT NULL,

    CONSTRAINT "PK_csv_coeficients_ajust" PRIMARY KEY (coeficient_name)
);




------------------- CARGA DE LOS CSV (must be superuser or use \copy through psql)

--COPY csv_perfils_inicials_i_demanda_referencia FROM '/home/u/Documents/holaLuz/myData/' DELIMITER ',' CSV; -- format ['.csv', '.txt']
--COPY csv_demanda_sistema FROM '/home/u/Documents/holaLuz/myData/' DELIMITER ',' CSV;  -- format ['.csv', '.txt']
--COPY csv_coeficients_ajust FROM '/home/u/Documents/holaLuz/myData/coeficients_ajust.csv' DELIMITER ',' CSV;  -- format ['.csv', '.txt']


---------------------------------------------------------------------------

DROP TABLE IF EXISTS perfils_inicials;
CREATE TABLE perfils_inicials(
    mes integer NOT NULL,
    dia integer NOT NULL,
    hora integer NOT NULL,
    perfil_usuari character (1) NOT NULL,

    pi double precision NOT NULL,

    CONSTRAINT "PK_perfils_inicials" PRIMARY KEY (mes, dia, hora, perfil_usuari)
);

DROP TABLE IF EXISTS perfils_finals;
CREATE TABLE perfils_finals(
    mes integer NOT NULL,
    dia integer NOT NULL,
    hora integer NOT NULL,
    perfil_usuari character (1) NOT NULL,

    pf double precision NOT NULL,

    CONSTRAINT "PK_perfils_finals" PRIMARY KEY (mes, dia, hora, perfil_usuari)
);

DROP TABLE IF EXISTS demanda_referencia;
CREATE TABLE demanda_referencia(
    mes integer NOT NULL, --INTEGER
    dia integer NOT NULL,--INTEGER
    hora integer NOT NULL,--INTEGER

    dr double precision NOT NULL, --FLOAT
    CONSTRAINT "PK_demanda_referencia" PRIMARY KEY (mes, dia, hora)
);

DROP TABLE IF EXISTS demanda_sistema;
CREATE TABLE demanda_sistema(
    mes integer NOT NULL,
    dia integer NOT NULL,
    hora integer NOT NULL,

    ds double precision NOT NULL,
    CONSTRAINT "PK_demanda_sistema" PRIMARY KEY (mes, dia, hora)
);

DROP TABLE IF EXISTS coeficients_ajust;
CREATE TABLE coeficients_ajust(
    perfil_usuari character (1) NOT NULL,

    alpha double precision NOT NULL,
    beta double precision NOT NULL,
    gamma double precision NOT NULL,

    CONSTRAINT "PK_coeficients_ajust" PRIMARY KEY (perfil_usuari)
);


------------------- Create taules auxiliars
---------------------------------------------------------------------------

-- step 0
DROP TABLE IF EXISTS c;
CREATE TABLE c0(
    mes integer NOT NULL,
    dia integer NOT NULL,
    perfil_usuari character (1) NOT NULL,

    c double precision NOT NULL,

    CONSTRAINT "PK_c0" PRIMARY KEY (mes, dia, perfil_usuari)
);


DROP TABLE IF EXISTS h;
CREATE TABLE h0(
    mes integer NOT NULL,
    dia integer NOT NULL,
    hora integer NOT NULL,
    perfil_usuari character (1) NOT NULL,

    h double precision NOT NULL,

    CONSTRAINT "PK_h0" PRIMARY KEY (mes, dia, hora, perfil_usuari)
);

DROP TABLE IF EXISTS m;
CREATE TABLE m0(
    mes integer NOT NULL,
    perfil_usuari character (1) NOT NULL,

    m double precision NOT NULL,

    CONSTRAINT "PK_m0" PRIMARY KEY (mes, perfil_usuari)
);

--step 1
DROP TABLE IF EXISTS c;
CREATE TABLE c1(
    mes integer NOT NULL,
    dia integer NOT NULL,
    perfil_usuari character (1) NOT NULL,

    c double precision NOT NULL,

    CONSTRAINT "PK_c1" PRIMARY KEY (mes, dia, perfil_usuari)
);


DROP TABLE IF EXISTS h;
CREATE TABLE h1(
    mes integer NOT NULL,
    dia integer NOT NULL,
    hora integer NOT NULL,
    perfil_usuari character (1) NOT NULL,

    h double precision NOT NULL,

    CONSTRAINT "PK_h1" PRIMARY KEY (mes, dia, hora, perfil_usuari)
);


--final step
DROP TABLE IF EXISTS c;
CREATE TABLE cf(
    mes integer NOT NULL,
    dia integer NOT NULL,
    perfil_usuari character (1) NOT NULL,

    c double precision NOT NULL,

    CONSTRAINT "PK_cf" PRIMARY KEY (mes, dia, perfil_usuari)
);


DROP TABLE IF EXISTS h;
CREATE TABLE hf(
    mes integer NOT NULL,
    dia integer NOT NULL,
    hora integer NOT NULL,
    perfil_usuari character (1) NOT NULL,

    h double precision NOT NULL,

    CONSTRAINT "PK_hf" PRIMARY KEY (mes, dia, hora, perfil_usuari)
);

DROP TABLE IF EXISTS m;
CREATE TABLE mf(
    mes integer NOT NULL,
    perfil_usuari character (1) NOT NULL,

    m double precision NOT NULL,
    CONSTRAINT "PK_mf" PRIMARY KEY (mes, perfil_usuari)
);

------------------- Taules auxiliars acumulatives
---------------------------------------------------------------------------
DROP TABLE IF EXISTS c_accumulate;
CREATE TABLE c_accumulate(
    mes integer NOT NULL,
    perfil_usuari character (1) NOT NULL,

    accumulate_p_month double precision NOT NULL,
    CONSTRAINT "PK_c_accumulate" PRIMARY KEY (mes, perfil_usuari)
);
