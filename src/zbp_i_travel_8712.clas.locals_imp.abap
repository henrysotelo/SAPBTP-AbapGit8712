CLASS lhc_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR travel RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR travel RESULT result.

    METHODS accepttravel FOR MODIFY
      IMPORTING keys FOR ACTION travel~accepttravel RESULT result.

    METHODS createtravelbytemplate FOR MODIFY
      IMPORTING keys FOR ACTION travel~createtravelbytemplate RESULT result.

    METHODS rejecttravel FOR MODIFY
      IMPORTING keys FOR ACTION travel~rejecttravel RESULT result.

    METHODS validatecustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatecustomer.

    METHODS validatedates FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatedates.

    METHODS validatestatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatestatus.

ENDCLASS.

CLASS lhc_travel IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD accepttravel.
  ENDMETHOD.

  METHOD createtravelbytemplate.

**********************************************************************
* Propiedades del la capa de negocio
* keys[ 1 ]
* result[ 1 ]
* mapped
* failed
* reported
**********************************************************************

*.. Forma 1 leer una entidad, instrucción recomentada
    READ ENTITIES OF zi_travel_8712 IN LOCAL MODE
     ENTITY Travel
      FIELDS ( TravelId AgencyId CustomerId BookingFee TotalPrice CurrencyCode )
       WITH VALUE #( FOR row_key IN keys ( %key = row_key-%key ) )
      RESULT DATA(lt_entity_travel)
      FAILED failed
      REPORTED reported.

    "Declaracion de una tabla interna
    DATA:
    lt_create_travel TYPE TABLE FOR CREATE zi_travel_8712\\Travel.

    "Buscar el ultimo registro del ID
    SELECT MAX( travel_id ) FROM ztb_travel_8712a
        INTO @DATA(lv_travel_id).

    "Obtener la fecha del sistema
    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

    "LLenar tabla para el nuevo registro
    lt_create_travel
        = VALUE #( FOR create_row  IN lt_entity_travel INDEX INTO idx
                  ( TravelId      = lv_travel_id + 1
                    AgencyId      = create_row-AgencyId
                    CustomerId    = create_row-CustomerId
                    BeginDate     = lv_today
                    EndDate       = lv_today + 30
                    BookingFee    = create_row-BookingFee
                    TotalPrice    = create_row-TotalPrice
                    CurrencyCode  = create_row-CurrencyCode
                    Description   = 'Add comments'
                    TravelStatus = 'O' ) ).

    "Modificar la entidadad travel adicionando un nuevo registro
    MODIFY ENTITIES OF zi_travel_8712
        IN LOCAL MODE ENTITY Travel
         CREATE FIELDS ( TravelId
                         AgencyId
                         CustomerId
                         BeginDate
                         EndDate
                         BookingFee
                         TotalPrice
                         CurrencyCode
                         Description
                         TravelStatus )
           WITH lt_create_travel
           MAPPED mapped
           FAILED failed
           REPORTED reported.

    "Devolver los resultado a la capa para visualizar el nuevo resultado
    result
       = VALUE #( FOR result_row IN lt_create_travel INDEX INTO idx
                     ( %cid_ref = keys[ idx ]-%cid_ref
                       %key     = keys[ idx ]-%key
                       %param   = CORRESPONDING #( result_row ) )
                     ).


  ENDMETHOD.

  METHOD rejecttravel.
  ENDMETHOD.

  METHOD validatecustomer.
  ENDMETHOD.

  METHOD validatedates.
  ENDMETHOD.

  METHOD validatestatus.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_travel_8712 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zi_travel_8712 IMPLEMENTATION.

  METHOD save_modified.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
