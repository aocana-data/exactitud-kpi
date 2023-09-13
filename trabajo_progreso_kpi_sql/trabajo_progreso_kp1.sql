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
                    /*joiner*/
                    tku."id_broker"
                    /*CAMPOS PARA SEGMENTACION*/

                  , tku."tipo_doc_broker"
                  , tku."documento_broker"
                  , tku."edad"
                  , tku."genero_broker"
                  , tku."nacionalidad_broker"
                  , tku."tipo_programa"
                  , tku."sector_productivo"
                  , CASE
                              WHEN tku."base_origen_vecino" IS NULL THEN 'NO DETERMINADA' --vecino
                              WHEN TRIM(tku."base_origen_vecino") LIKE '' THEN 'NO DETERMINADA'
                              ELSE TRIM(tku."base_origen_vecino")
                    END base_origen
          FROM      "caba-piba-staging-zone-db"."view_typ_tmp_kpi_1" AS tku
          )
        , typ_kpi_users_joinner AS (
          SELECT    id_broker
                  , usrs.*
                  , laboral.*
          FROM      merge_data AS laboral
          LEFT JOIN typ_kpi_users AS usrs USING (id_broker)
          )
        , kpi_fixed AS (
          SELECT    DISTINCT
                    /* SE ARMA LA VALIDACION CONSIDERANDO TODOS LOS ESTADOS, SI TRABAJA O NO*/
                    id_broker
                  , tipo_doc_broker
                  , cuit_del_empleador
                  , documento_broker
                  , fecha_inicio
                  , fecha_fin
                    /*DATOS DE SEGMENTACION*/

                  , edad
                  , nacionalidad_broker
                  , genero_broker
                  , base_origen
                  , tipo_programa
                  , sector_productivo
                    --                , NO EXISTE COL DE BARRIO VULNERABLE
                    --                , NO EXISTE COL MAXIMO NIVEL EDUCATIVO
          FROM      typ_kpi_users_joinner
          )
SELECT    base_origen
        , documento_broker
        , fecha_inicio
        , fecha_fin
FROM      kpi_fixed