


##############  CROSSTABS  ##############

## Method 1

SELECT
  dgt.name AS Categoría_I,
  sdg.name AS Categoría_II,
  COUNT(dg.id) AS Frecuencia,
  CONCAT(TRUNCATE(COUNT(dg.id)/(
    SELECT SUM(table1.Frecuencia) 
    FROM 
    (
      SELECT
        COUNT(dg.id) AS Frecuencia
      FROM player pl 
        # Evento Clínico
        LEFT JOIN clinical_event ce ON pl.id = ce.id_player 
              AND ce.deleted = 0
              AND ce.tenant_code = 'ANFP'
        # Diagnóstico
        LEFT JOIN diagnostic dg ON ce.id = dg.id_clinical_event 
              AND dg.deleted = 0
              AND dg.tenant_code = 'ANFP'
        LEFT JOIN diagnostic_type dgt ON dgt.id = dg.id_diagnostic_type
        LEFT JOIN sub_diagnostic sdg ON sdg.id = dg.id_sub_diagnostic
      WHERE pl.deleted = 0 
        AND pl.tenant_code = 'ANFP'
        AND dgt.name IS NOT NULL
        AND sdg.name IS NOT NULL
      GROUP BY dgt.name, sdg.name
    ) AS table1
  ), 2),'',"%") AS Porcentage

FROM player pl 
  # Evento Clínico
  LEFT JOIN clinical_event ce ON pl.id = ce.id_player 
        AND ce.deleted = 0 
        AND ce.tenant_code = 'ANFP'
  # Diagnóstico
  LEFT JOIN diagnostic dg ON ce.id = dg.id_clinical_event 
        AND dg.deleted = 0
        AND dg.tenant_code = 'ANFP'
  LEFT JOIN diagnostic_type dgt ON dgt.id = dg.id_diagnostic_type
  LEFT JOIN sub_diagnostic sdg ON sdg.id = dg.id_sub_diagnostic

WHERE pl.deleted = 0 
  AND pl.tenant_code = 'ANFP'
  AND dgt.name IS NOT NULL
  AND sdg.name IS NOT NULL

GROUP BY dgt.name, sdg.name

ORDER BY COUNT(dg.id) DESC
  
;

## Method 2

CREATE TEMPORARY TABLE df1
  SELECT
    COUNT(dg.id) AS Frecuencia
  FROM player pl 
    # Evento Clínico
    LEFT JOIN clinical_event ce ON pl.id = ce.id_player 
          AND ce.deleted = 0
          AND ce.tenant_code = 'ANFP'
    # Diagnóstico
    LEFT JOIN diagnostic dg ON ce.id = dg.id_clinical_event 
          AND dg.deleted = 0
          AND dg.tenant_code = 'ANFP'
    LEFT JOIN diagnostic_type dgt ON dgt.id = dg.id_diagnostic_type
    LEFT JOIN sub_diagnostic sdg ON sdg.id = dg.id_sub_diagnostic
  WHERE pl.deleted = 0 
    AND pl.tenant_code = 'ANFP'
    AND dgt.name IS NOT NULL
    AND sdg.name IS NOT NULL
  GROUP BY dgt.name, sdg.name
;

SELECT
  dgt.name AS Categoría_I,
  sdg.name AS Categoría_II,
  COUNT(dg.id) AS Frecuencia,
  CONCAT(TRUNCATE(COUNT(dg.id)/(
    SELECT SUM(table1.Frecuencia) 
    FROM df1 AS table1
  ), 2),'',"%") AS Porcentage

FROM player pl 
  # Evento Clínico
  LEFT JOIN clinical_event ce ON pl.id = ce.id_player 
        AND ce.deleted = 0 
        AND ce.tenant_code = 'ANFP'
  # Diagnóstico
  LEFT JOIN diagnostic dg ON ce.id = dg.id_clinical_event 
        AND dg.deleted = 0
        AND dg.tenant_code = 'ANFP'
  LEFT JOIN diagnostic_type dgt ON dgt.id = dg.id_diagnostic_type
  LEFT JOIN sub_diagnostic sdg ON sdg.id = dg.id_sub_diagnostic

WHERE pl.deleted = 0 
  AND pl.tenant_code = 'ANFP'
  AND dgt.name IS NOT NULL
  AND sdg.name IS NOT NULL

GROUP BY dgt.name, sdg.name

ORDER BY COUNT(dg.id) DESC 
;

DROP TABLE df1
; 





##############  JOINING AND UNION  ##############

SELECT 
  table1.Posición,
  table1.Total_Eventos_Clínicos,
  table3.Total_KTR

FROM 
(
  SELECT
  pt.name_position AS 'Posición',
  COUNT(ce.id) AS 'Total_Eventos_Clínicos'
  FROM player pl 
    # Jugador
    LEFT JOIN user us ON us.id = pl.id_user 
          AND us.deleted = 0
          AND us.id_user_type = 12
          AND us.tenant_code = 'ANFP'
    LEFT JOIN position_type pt ON pl.id_position_type = pt.id 
    # Evento Clínico
    LEFT JOIN clinical_event ce ON pl.id = ce.id_player 
          AND ce.deleted = 0 
          AND ce.tenant_code = 'ANFP'
  WHERE pl.deleted = 0 
    AND pl.tenant_code = 'ANFP'
  GROUP BY pt.name_position
) AS table1

LEFT JOIN
(
  SELECT 
  table2.Posición,
  SUM(table2.Total_KTR) AS 'Total_KTR'
  FROM 
  (
    SELECT
    pt.name_position AS 'Posición',
    COUNT(kt.id) AS 'Total_KTR'
    FROM player pl 
      # Jugador
      LEFT JOIN user us ON us.id = pl.id_user 
            AND us.deleted = 0
            AND us.id_user_type = 12
            AND us.tenant_code = 'ANFP' 
      LEFT JOIN position_type pt ON pl.id_position_type = pt.id 
      # Tratamiento Kinésico
      LEFT JOIN kinesic_treatment kt ON pl.id = kt.id_player 
            AND kt.deleted = 0
            AND kt.tenant_code = 'ANFP'
    WHERE pl.deleted = 0 
      AND pl.tenant_code = 'ANFP'
    GROUP BY pt.name_position
    
    UNION
    
    SELECT
    pt.name_position AS 'Posición',
    COUNT(kt.id) AS 'Total_KTR'
    FROM player pl 
      # Jugador
      LEFT JOIN user us ON us.id = pl.id_user 
            AND us.deleted = 0
            AND us.id_user_type = 12
            AND us.tenant_code = 'ANFP' 
      LEFT JOIN position_type pt ON pl.id_position_type = pt.id 
      # Evento Clínico
      LEFT JOIN clinical_event ce ON pl.id = ce.id_player 
            AND ce.deleted = 0 
            AND ce.tenant_code = 'ANFP'
      # Diagnóstico
      LEFT JOIN diagnostic dg ON ce.id = dg.id_clinical_event 
            AND dg.deleted = 0
            AND dg.tenant_code = 'ANFP'
      # Tratamiento Kinésico
      LEFT JOIN kinesic_treatment kt ON kt.id_diagnostic = dg.id 
            AND kt.deleted = 0
            AND kt.tenant_code = 'ANFP'
    WHERE pl.deleted = 0 
          AND pl.tenant_code = 'ANFP'
    GROUP BY pt.name_position
  ) AS table2 
  GROUP BY table2.Posición
) AS table3 
ON (table3.Posición = table1.Posición)

UNION

SELECT 
  CASE table1.Posición WHEN 'Defensa central' THEN 'TOTAL' END,
  SUM(table1.Total_Eventos_Clínicos) AS 'Total_Eventos_Clínicos',
  SUM(table3.Total_KTR) AS 'Total_KTR'

FROM 
(
  SELECT
  pt.name_position AS 'Posición',
  COUNT(ce.id) AS 'Total_Eventos_Clínicos'
  FROM player pl 
    # Jugador
    LEFT JOIN user us ON us.id = pl.id_user 
          AND us.deleted = 0
          AND us.id_user_type = 12
          AND us.tenant_code = 'ANFP'
    LEFT JOIN position_type pt ON pl.id_position_type = pt.id 
    # Evento Clínico
    LEFT JOIN clinical_event ce ON pl.id = ce.id_player 
          AND ce.deleted = 0 
          AND ce.tenant_code = 'ANFP'
  WHERE pl.deleted = 0 
    AND pl.tenant_code = 'ANFP'
  GROUP BY pt.name_position
) AS table1

LEFT JOIN
(
  SELECT 
  table2.Posición,
  SUM(table2.Total_KTR) AS 'Total_KTR'
  FROM 
  (
    SELECT
    pt.name_position AS 'Posición',
    COUNT(kt.id) AS 'Total_KTR'
    FROM player pl 
      # Jugador
      LEFT JOIN user us ON us.id = pl.id_user 
            AND us.deleted = 0
            AND us.id_user_type = 12
            AND us.tenant_code = 'ANFP' 
      LEFT JOIN position_type pt ON pl.id_position_type = pt.id 
      # Tratamiento Kinésico
      LEFT JOIN kinesic_treatment kt ON pl.id = kt.id_player 
            AND kt.deleted = 0
            AND kt.tenant_code = 'ANFP'
    WHERE pl.deleted = 0 
      AND pl.tenant_code = 'ANFP'
    GROUP BY pt.name_position
    UNION
    SELECT
    pt.name_position AS 'Posición',
    COUNT(kt.id) AS 'Total_KTR'
    FROM player pl 
      # Jugador
      LEFT JOIN user us ON us.id = pl.id_user 
            AND us.deleted = 0
            AND us.id_user_type = 12
            AND us.tenant_code = 'ANFP' 
      LEFT JOIN position_type pt ON pl.id_position_type = pt.id 
      # Evento Clínico
      LEFT JOIN clinical_event ce ON pl.id = ce.id_player 
            AND ce.deleted = 0 
            AND ce.tenant_code = 'ANFP'
      # Diagnóstico
      LEFT JOIN diagnostic dg ON ce.id = dg.id_clinical_event 
            AND dg.deleted = 0
            AND dg.tenant_code = 'ANFP'
      # Tratamiento Kinésico
      LEFT JOIN kinesic_treatment kt ON kt.id_diagnostic = dg.id 
            AND kt.deleted = 0
            AND kt.tenant_code = 'ANFP'
    WHERE pl.deleted = 0 
      AND pl.tenant_code = 'ANFP'
    GROUP BY pt.name_position
  ) AS table2 
  GROUP BY table2.Posición
) AS table3 
ON (table3.Posición = table1.Posición)



#############  FULL JOIN & DATE INTERVALS  ##############

SELECT
DateInterval.Fecha AS 'Fecha',
CASE 
  WHEN table1.EventosClínicos IS NULL THEN '0' 
  ELSE table1.EventosClínicos END AS 'Eventos Clínicos',
CASE 
  WHEN table2.AccionesKinésicas IS NULL THEN '0' 
  ELSE table2.AccionesKinésicas END AS 'Acciones Kinésicas',
CASE 
  WHEN table3.TratamientosKinésicos IS NULL THEN '0' 
  ELSE table3.TratamientosKinésicos END AS 'Tratamientos Kinésicos'

FROM
## Date Time Interval
(
  SELECT 
  DateTable.Date_Interval AS Fecha 
  FROM 
  (
    SELECT 
    adddate('2021-01-01', t4*10000 + t3*1000 + t2*100 + t1*10 + t0) AS Date_Interval 
    FROM
     (select 0 t0 union select 1 union select 2 union select 3 union select 4 
      union select 5 union select 6 union select 7 union select 8 union select 9) t0,
     (select 0 t1 union select 1 union select 2 union select 3 union select 4 
      union select 5 union select 6 union select 7 union select 8 union select 9) t1,
     (select 0 t2 union select 1 union select 2 union select 3 union select 4 
      union select 5 union select 6 union select 7 union select 8 union select 9) t2,
     (select 0 t3 union select 1 union select 2 union select 3 union select 4 
      union select 5 union select 6 union select 7 union select 8 union select 9) t3,
     (select 0 t4 union select 1 union select 2 union select 3 union select 4 
      union select 5 union select 6 union select 7 union select 8 union select 9) t4
   ) AS DateTable 
  WHERE Date_Interval 
    BETWEEN (
      SELECT MIN(min_date.MinDate)
      FROM
      (
        SELECT
        MIN(DATE(ce.created)) AS MinDate
      FROM player pl 
        # Evento Clínico
          LEFT JOIN clinical_event ce ON pl.id = ce.id_player 
                AND ce.deleted = 0 
                AND ce.tenant_code = 'ANFP'
          # Diagnóstico
          LEFT JOIN diagnostic dg ON ce.id = dg.id_clinical_event 
                AND dg.deleted = 0
                AND dg.tenant_code = 'ANFP'
          # Tratamiento Kinésico
          LEFT JOIN kinesic_treatment kt1 ON pl.id = kt1.id_player 
                AND kt1.deleted = 0
                AND kt1.tenant_code = 'ANFP'
          LEFT JOIN kinesic_treatment kt2 ON kt2.id_diagnostic = dg.id 
                AND kt2.deleted = 0
                AND kt2.tenant_code = 'ANFP'    
      WHERE pl.deleted = 0 
        AND pl.tenant_code = 'ANFP'
      UNION
      SELECT
      MIN(DATE(kt1.date)) AS MinDate
      FROM player pl 
        # Evento Clínico
          LEFT JOIN clinical_event ce ON pl.id = ce.id_player 
                AND ce.deleted = 0 
                AND ce.tenant_code = 'ANFP'
          # Diagnóstico
          LEFT JOIN diagnostic dg ON ce.id = dg.id_clinical_event 
                AND dg.deleted = 0
                AND dg.tenant_code = 'ANFP'
          # Tratamiento Kinésico
          LEFT JOIN kinesic_treatment kt1 ON pl.id = kt1.id_player 
                AND kt1.deleted = 0
                AND kt1.tenant_code = 'ANFP'
          LEFT JOIN kinesic_treatment kt2 ON kt2.id_diagnostic = dg.id 
                AND kt2.deleted = 0
                AND kt2.tenant_code = 'ANFP'    
      WHERE pl.deleted = 0 
        AND pl.tenant_code = 'ANFP'
      UNION
      SELECT
      MIN(DATE(kt2.date)) AS MinDate
      FROM player pl 
        # Evento Clínico
          LEFT JOIN clinical_event ce ON pl.id = ce.id_player 
                AND ce.deleted = 0 
                AND ce.tenant_code = 'ANFP'
          # Diagnóstico
          LEFT JOIN diagnostic dg ON ce.id = dg.id_clinical_event 
                AND dg.deleted = 0
                AND dg.tenant_code = 'ANFP'
          # Tratamiento Kinésico
          LEFT JOIN kinesic_treatment kt1 ON pl.id = kt1.id_player 
                AND kt1.deleted = 0
                AND kt1.tenant_code = 'ANFP'
          LEFT JOIN kinesic_treatment kt2 ON kt2.id_diagnostic = dg.id 
                AND kt2.deleted = 0
                AND kt2.tenant_code = 'ANFP'    
      WHERE pl.deleted = 0 
        AND pl.tenant_code = 'ANFP'
      ) AS min_date
        ) 
      AND CURRENT_DATE
  ORDER BY Date_Interval DESC
) AS DateInterval

  LEFT JOIN 
  ## Clinical Event
  (
    SELECT
    DATE(ce.created) AS Fecha,
    COUNT(ce.id) AS EventosClínicos
    FROM player pl 
      # Evento Clínico
      LEFT JOIN clinical_event ce ON pl.id = ce.id_player 
        AND ce.deleted = 0 
        AND ce.tenant_code = 'ANFP'
    WHERE pl.deleted = 0 
      AND pl.tenant_code = 'ANFP' 
    GROUP BY DATE(ce.created) 
    ORDER BY DATE(ce.created) DESC
  ) AS table1 ON DateInterval.Fecha = table1.Fecha

  LEFT JOIN 
  ## Kinesic Actions
  (
    SELECT
    DATE(kt1.date) AS Fecha,
    COUNT(kt1.id) AS AccionesKinésicas
    FROM player pl 
      LEFT JOIN kinesic_treatment kt1 ON pl.id = kt1.id_player 
        AND kt1.deleted = 0
        AND kt1.tenant_code = 'ANFP'
    WHERE pl.deleted = 0 
      AND pl.tenant_code = 'ANFP'
    GROUP BY DATE(kt1.date)
    ORDER BY DATE(kt1.date) DESC
  ) AS table2 ON DateInterval.Fecha = table2.Fecha
  
  LEFT JOIN
  ## Kinesic Treatments
  (
    SELECT
    DATE(kt2.date) AS Fecha,
    COUNT(kt2.id) AS TratamientosKinésicos    
    FROM player pl 
    # Evento Clínico
    LEFT JOIN clinical_event ce ON pl.id = ce.id_player 
      AND ce.deleted = 0 
      AND ce.tenant_code = 'ANFP'
    # Diagnóstico
    LEFT JOIN diagnostic dg ON ce.id = dg.id_clinical_event 
      AND dg.deleted = 0
      AND dg.tenant_code = 'ANFP'
    # Tratamiento Kinésico
    LEFT JOIN kinesic_treatment kt2 ON kt2.id_diagnostic = dg.id 
      AND kt2.deleted = 0
      AND kt2.tenant_code = 'ANFP'    
    WHERE pl.deleted = 0 
      AND pl.tenant_code = 'ANFP'
    GROUP BY DATE(kt2.date)
    ORDER BY DATE(kt2.date) DESC
  ) AS table3 ON DateInterval.Fecha = table3.Fecha

ORDER BY DateInterval.Fecha DESC

;

















