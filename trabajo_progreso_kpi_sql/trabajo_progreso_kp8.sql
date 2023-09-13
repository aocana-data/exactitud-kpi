WITH      oferta_capacitaciones AS (
          SELECT    DISTINCT "tipo_capacitacion"
                  , "fecha_inicio"
                  , "fecha_fin"
                  , "sector_productivo"
                  , "base_origen_capacitacion" AS base_origen
                  , "descrip_modalidad"
          FROM      "caba-piba-staging-zone-db"."view_typ_tmp_kpi_8"
          )
        , kpi_completitud_data AS (
          SELECT   
                    /*COLUMNAS ESCENCIALES*/
                    "tipo_capacitacion"
                  , "fecha_inicio"
                  , "fecha_fin"
                    /*COLUMNAS PARA SEGMENTACION*/

                  , "base_origen"
                  , "sector_productivo"
                  , "descrip_modalidad"
          FROM      oferta_capacitaciones
          )
SELECT    "base_origen"
        , "tipo_capacitacion"
        , "fecha_inicio"
        , "fecha_fin"
FROM      kpi_completitud_data