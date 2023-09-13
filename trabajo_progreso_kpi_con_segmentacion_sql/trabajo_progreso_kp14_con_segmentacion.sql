WITH      merge_data AS (
          SELECT    DISTINCT
                    -- cols requeridas
                    tbp."id_broker"
                  , tbp."cuit_del_empleador"
                  , tbp."fecha_inicio"
                  , tbp."fecha_fin"
          FROM      "caba-piba-staging-zone-db"."tbp_typ_def_registro_laboral_formal" tbp
          )
        , typ_kpi_users AS (
          SELECT   
                    -- PARA ESTOS CASOS ESTAMOS CONSIDERANDO LAS BASES DE ORIGEN QUE PROVIENEN DESDE REGISTRO LABORAL
                    --	SEA EL CASO PODEMOS DELEGAR ESOS DATOS DESDE OTRA ÁREA 
                    /*EN ESTA VIEW SOLAMENTE CONTAMOS CON 2 VARIABLES VALUES : '' & CAPACITACIONES*/
                    /*joiner*/
                    "id_broker"
                    /*CAMPOS PARA SEGMENTACION*/

                  , kpi.*
                  , tku."tipo_doc_broker"
                  , tku."documento_broker"
                  , tku."edad"
                  , tku."genero_broker"
                  , tku."nacionalidad_broker"
                  , UPPER(TRIM(tku."tipo_programa")) AS tipo_programa
                  , tku."sector_productivo"
                  , CASE
                              WHEN tku."base_origen_vecino" IS NULL THEN 'NO DETERMINADA' --vecino
                              WHEN TRIM(tku."base_origen_vecino") LIKE '' THEN 'NO DETERMINADA'
                              ELSE TRIM(tku."base_origen_vecino")
                    END base_origen
                  , tku."cursada_estado_beneficiario"
                    -- FECHAS DE INICIO DE LAS CAPACITACIONES

                  , tku."capacitacion_fecha_inicio"
                  , tku."capacitacion_fecha_fin"
          FROM      "caba-piba-staging-zone-db"."view_typ_tmp_kpi_1" AS tku
          LEFT JOIN merge_data AS kpi USING (id_broker)
          )
        , filter_programa AS (
          /*EN ESTE SECTOR PUEDO EMPEZAR A TRABAJAR LAS POSIBILIDADESDE DE HACER LA SEGMENTACION 
          DE ESPACIOS TEMPORALES DE 3-6-12 MESES*/
          SELECT    *
          FROM      typ_kpi_users
          WHERE     TRUE
          AND       tipo_programa LIKE 'PRÁCTICAS FORMATIVAS'
          )
        , kpi_values_principales_completitud AS (
          SELECT    DISTINCT
                    /*COLUMNAS NECESARIAS */
                    "id_broker"
                  , "base_origen"
                  , "documento_broker"
                  , "cuit_del_empleador"
                  , "tipo_programa"
                  , "fecha_inicio"
                  , "fecha_fin"
                  , "capacitacion_fecha_inicio"
                  , "capacitacion_fecha_fin"
                  , "cursada_estado_beneficiario"
                    /*COLUMNAS PARA LA SEGMENTACION*/

                  , "edad"
                  , "nacionalidad_broker"
                  , "genero_broker"
                    -- , NO ENCONTRADA RESIDENCIA BARRIOS VULNERABLES
                    -- , NO ENCONTRADA MAXIMO NIVEL EDUCATIVO ALCANZANDO

                  , "sector_productivo"
          FROM      filter_programa
          )
SELECT    "base_origen"
        , "id_broker"
        , "cuit_del_empleador"
        , "documento_broker"
        , "cursada_estado_beneficiario"
        , "fecha_inicio"
        , "fecha_fin"
        , "tipo_programa"
        , "capacitacion_fecha_inicio"
        , "capacitacion_fecha_fin"
        , "edad"
        , "nacionalidad_broker"
        , "genero_broker"
        , "sector_productivo"
FROM      kpi_values_principales_completitud