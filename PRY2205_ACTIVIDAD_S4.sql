
-- ==========================================
-- PRY2205 - ACTIVIDAD SEMANA 4
-- CONSULTA DE BASES DE DATOS
-- ==========================================


-- ==========================================
-- CASO 1: LISTADO DE TRABAJADORES
-- ==========================================

SELECT
    TO_CHAR(t.numrut, 'FM99G999G999',
        'NLS_NUMERIC_CHARACTERS = '',.''')
        || '-' || t.dvrut AS "RUT Trabajador",

    INITCAP(t.nombre || ' ' || t.appaterno || ' ' || t.apmaterno)
        AS "Nombre Completo",

    TO_CHAR(t.sueldo_base, 'FM$999G999G999',
        'NLS_NUMERIC_CHARACTERS = '',.''')
        AS "Sueldo Base",

    UPPER(tt.desc_categoria) AS "Tipo Trabajador",

    UPPER(c.nombre_ciudad) AS "Ciudad Trabajador"

FROM trabajador t

INNER JOIN comuna_ciudad c
    ON t.id_ciudad = c.id_ciudad

INNER JOIN tipo_trabajador tt
    ON t.id_categoria_t = tt.id_categoria

WHERE t.sueldo_base BETWEEN 650000 AND 3000000

ORDER BY c.nombre_ciudad DESC, t.sueldo_base ASC;



-- ==========================================
-- CASO 2: LISTADO DE CAJEROS
-- ==========================================

SELECT
    TO_CHAR(t.numrut, 'FM99G999G999',
        'NLS_NUMERIC_CHARACTERS = '',.''')
        || '-' || t.dvrut AS "RUT Trabajador",

    INITCAP(t.nombre || ' ' || t.appaterno)
        AS "Nombre Trabajador",

    COUNT(tc.nro_ticket) AS "Total Tickets",

    TO_CHAR(SUM(tc.monto_ticket),
        'FM$999G999G999',
        'NLS_NUMERIC_CHARACTERS = '',.''')
        AS "Total Vendido",

    TO_CHAR(NVL(SUM(ct.valor_comision), 0),
        'FM$999G999G999',
        'NLS_NUMERIC_CHARACTERS = '',.''')
        AS "Comision Total",

    UPPER(tt.desc_categoria) AS "Tipo Trabajador",

    UPPER(c.nombre_ciudad) AS "Ciudad Trabajador"

FROM trabajador t

INNER JOIN tipo_trabajador tt
    ON t.id_categoria_t = tt.id_categoria

INNER JOIN tickets_concierto tc
    ON t.numrut = tc.numrut_t

LEFT JOIN comisiones_ticket ct
    ON tc.nro_ticket = ct.nro_ticket

INNER JOIN comuna_ciudad c
    ON t.id_ciudad = c.id_ciudad

WHERE UPPER(tt.desc_categoria) = 'CAJERO'

GROUP BY
    t.numrut,
    t.dvrut,
    t.nombre,
    t.appaterno,
    tt.desc_categoria,
    c.nombre_ciudad

HAVING SUM(tc.monto_ticket) > 50000

ORDER BY SUM(tc.monto_ticket) DESC;



-- ==========================================
-- CASO 3: LISTADO DE BONIFICACIONES
-- ==========================================

SELECT
    TO_CHAR(t.numrut, 'FM99G999G999',
        'NLS_NUMERIC_CHARACTERS = '',.''')
        || '-' || t.dvrut AS "RUT Trabajador",

    INITCAP(t.nombre || ' ' || t.appaterno || ' ' || t.apmaterno)
        AS "Nombre Trabajador",

    EXTRACT(YEAR FROM t.fecing)
        AS "Año Ingreso",

    TRUNC(MONTHS_BETWEEN(SYSDATE, t.fecing) / 12)
        AS "Años Antiguedad",

    COUNT(DISTINCT af.numrut_carga)
        AS "Cargas Familiares",

    CASE
        WHEN COUNT(DISTINCT af.numrut_carga) > 0
            THEN 'SI'
        ELSE 'NO'
    END AS "Asignacion Familiar",

    UPPER(i.nombre_isapre)
        AS "Sistema Salud",

    TO_CHAR(t.sueldo_base, 'FM$999G999G999',
        'NLS_NUMERIC_CHARACTERS = '',.''')
        AS "Sueldo Base",

    CASE
        WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, t.fecing) / 12) <= 10
            THEN 10
        ELSE 15
    END AS "Porcentaje Antiguedad",

    ROUND(
        t.sueldo_base *
        CASE
            WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, t.fecing) / 12) <= 10
                THEN 0.10
            ELSE 0.15
        END
    ) AS "Bono Antiguedad",

    CASE
        WHEN UPPER(i.nombre_isapre) = 'FONASA'
            THEN ROUND(t.sueldo_base * 0.01)
        ELSE 0
    END AS "Bono Salud",

    ROUND(
        t.sueldo_base *
        CASE
            WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, t.fecing) / 12) <= 10
                THEN 0.10
            ELSE 0.15
        END
    )
    +
    CASE
        WHEN UPPER(i.nombre_isapre) = 'FONASA'
            THEN ROUND(t.sueldo_base * 0.01)
        ELSE 0
    END AS "Total Bonificacion"

FROM trabajador t

INNER JOIN isapre i
    ON t.cod_isapre = i.cod_isapre

INNER JOIN est_civil ec
    ON t.numrut = ec.numrut_t

LEFT JOIN asignacion_familiar af
    ON t.numrut = af.numrut_t

WHERE ec.fecter_estcivil IS NULL
   OR ec.fecter_estcivil > SYSDATE

GROUP BY
    t.numrut,
    t.dvrut,
    t.nombre,
    t.appaterno,
    t.apmaterno,
    t.fecing,
    t.sueldo_base,
    i.nombre_isapre

ORDER BY t.numrut ASC;
