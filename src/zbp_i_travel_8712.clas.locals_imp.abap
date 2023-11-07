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

    "Authorizations
    "METHODS get_authorizations FOR AUTHORIZATION
    "IMPORTING keys REQUEST requested_authorizations for travel result result.

ENDCLASS.

CLASS lhc_travel IMPLEMENTATION.

  METHOD get_instance_features.

    "Leer la entidad travel
    READ ENTITIES OF zi_travel_8712 IN LOCAL MODE
        ENTITY Travel
        FIELDS ( TravelUuid TravelId TravelStatus )
        WITH VALUE #( FOR key_row IN keys ( %key = key_row-%key ) )
        RESULT DATA(lt_travel_result).

    "Actualizar salida de la interface
    result = VALUE #( FOR ls_travel IN lt_travel_result
                          (
                          %key                  = ls_travel-%key
                          %field-TravelId       = if_abap_behv=>fc-f-read_only
                          %field-TravelStatus   = if_abap_behv=>fc-f-read_only
                          %assoc-_Booking       = if_abap_behv=>fc-o-enabled

                          %action-acceptTravel = COND #( WHEN ls_travel-TravelStatus = 'A'
                                                         THEN if_abap_behv=>fc-o-disabled
                                                         ELSE if_abap_behv=>fc-o-enabled )

                          %action-rejectTravel = COND #( WHEN ls_travel-TravelStatus = 'X'
                                                         THEN if_abap_behv=>fc-o-disabled
                                                         ELSE if_abap_behv=>fc-o-enabled ) ) ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
    "CB9980000216
*    DATA lv_authh TYPE c LENGTH 2.
*    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).
*    IF lv_user EQ 'CB9980000216'.
*      lv_authh = if_abap_behv=>auth-allowed.
*    ELSE.
*      lv_authh = if_abap_behv=>auth-unauthorized.
*    ENDIF.
    DATA(lv_auth) = COND #( WHEN cl_abap_context_info=>get_user_technical_name( ) EQ 'CB9980000216'
                            THEN if_abap_behv=>auth-allowed
                            ELSE if_abap_behv=>auth-unauthorized ).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_keys>).

      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<ls_result>).

      <ls_result>
        = VALUE #(  %key = <ls_keys>-%key
                    %op-%update                    = lv_auth
                    %delete                        = lv_auth
                    %action-acceptTravel           = lv_auth
                    %action-rejectTravel           = lv_auth
                    %action-createTravelByTemplate = lv_auth
                    %assoc-_Booking                = lv_auth ).

      <ls_result>-%key = <ls_keys>-%key.
      <ls_result>-%action-acceptTravel = if_abap_behv=>auth-allowed.

    ENDLOOP.
  ENDMETHOD.

  METHOD accepttravel.

    "Modificar entidades travel
    MODIFY ENTITIES OF zi_travel_8712 IN LOCAL MODE
         ENTITY Travel
         UPDATE FIELDS ( TravelStatus  )
         WITH VALUE #( FOR key_row1 IN keys ( TravelUuid   = key_row1-TravelUuid
                                              TravelStatus = 'A'  ) ) "Accepted
         FAILED failed
         REPORTED reported.

    READ ENTITIES OF zi_travel_8712 IN LOCAL MODE
        ENTITY Travel
        FIELDS (  AgencyId
                  CustomerId
                  BeginDate
                  EndDate
                  BookingFee
                  TotalPrice
                  CurrencyCode
                  TravelStatus
                  Description
                  LocalCreatedBy
                  LocalCreatedAt
                  LocalLastChangedBy
                  LocalLastChangedAt )
       WITH VALUE #( FOR key_row2 IN keys ( TravelUuid = key_row2-TravelUuid ) )
       RESULT DATA(lt_data).

    result  = VALUE #( FOR ls_travel IN lt_data ( TravelUuid =  ls_travel-TravelUuid
                                                  %param     =  ls_travel ) ).


    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<ls_travel>).

      DATA(lv_travel_msg) = <ls_travel>-TravelId.

      SHIFT lv_travel_msg LEFT DELETING LEADING '0'.

      APPEND VALUE #( TravelUuid =  <ls_travel>-TravelUuid
                         %msg  = new_message(  id        = 'ZMC_TRAVEL_8712'
                                               number    = '005'
                                               v1        = lv_travel_msg
                                               severity  = if_abap_behv_message=>severity-success )
                         %element-CustomerId = if_abap_behv=>mk-on ) TO reported-travel.
    ENDLOOP.

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

    "Modificar entidades travel
    MODIFY ENTITIES OF zi_travel_8712 IN LOCAL MODE
         ENTITY Travel
         UPDATE FIELDS ( TravelStatus  )
         WITH VALUE #( FOR key_row1 IN keys ( TravelUuid   = key_row1-TravelUuid
                                              TravelStatus = 'X'  ) ) "Rejected
         FAILED failed
         REPORTED reported.

    READ ENTITIES OF zi_travel_8712 IN LOCAL MODE
        ENTITY Travel
        FIELDS (  AgencyId
                  CustomerId
                  BeginDate
                  EndDate
                  BookingFee
                  TotalPrice
                  CurrencyCode
                  TravelStatus
                  Description
                  LocalCreatedBy
                  LocalCreatedAt
                  LocalLastChangedBy
                  LocalLastChangedAt )
       WITH VALUE #( FOR key_row2 IN keys ( TravelUuid = key_row2-TravelUuid ) )
       RESULT DATA(lt_data).

    result  = VALUE #( FOR ls_travel IN lt_data ( TravelUuid =  ls_travel-TravelUuid
                                                  %param     =  ls_travel ) ).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<ls_travel>).

      DATA(lv_travel_msg) = <ls_travel>-TravelId.

      SHIFT lv_travel_msg LEFT DELETING LEADING '0'.

      APPEND VALUE #( TravelUuid =  <ls_travel>-TravelUuid
                         %msg  = new_message(  id        = 'ZMC_TRAVEL_8712'
                                               number    = '006'
                                               v1        = lv_travel_msg
                                               severity  = if_abap_behv_message=>severity-success )
                         %element-CustomerId = if_abap_behv=>mk-on ) TO reported-travel.
    ENDLOOP.


  ENDMETHOD.

  METHOD validatecustomer.

    "Leer la entidad travel
    READ ENTITIES OF zi_travel_8712 IN LOCAL MODE
         ENTITY Travel
         FIELDS ( CustomerId )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_travel).

    "Definición de tabla interna
    DATA
    lt_customer TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    "Implementacion de tabla interna
    lt_customer
    = CORRESPONDING #( lt_travel DISCARDING DUPLICATES MAPPING  customer_id = CustomerId ).

    "Eliminar customer sin datos
    DELETE lt_customer WHERE customer_id IS INITIAL.

    "Lectura de base de datos
    SELECT FROM /dmo/customer FIELDS customer_id
        FOR ALL ENTRIES IN @lt_customer
        WHERE customer_id EQ @lt_customer-customer_id
        INTO TABLE @DATA(lt_customer_db).


    "Recorrer para ejecutar las validaciones
    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      IF <ls_travel>-CustomerId IS INITIAL
        OR NOT line_exists( lt_customer_db[ customer_id = <ls_travel>-CustomerId ] ).

        APPEND VALUE #( TravelUuid = <ls_travel>-TravelUuid ) TO failed-travel.

        APPEND VALUE #( TravelUuid =  <ls_travel>-TravelUuid
                        %msg  = new_message(  id        = 'ZMC_TRAVEL_8712'
                                              number    = '001'
                                              v1        =  <ls_travel>-TravelUuid
                                              severity  = if_abap_behv_message=>severity-error )
                        %element-CustomerId = if_abap_behv=>mk-on ) TO reported-travel.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validatedates.

    "Leer la entidad travel
    READ ENTITIES OF zi_travel_8712 IN LOCAL MODE
         ENTITY Travel
         FIELDS ( BeginDate EndDate )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_travel_result).


    LOOP AT lt_travel_result INTO DATA(ls_travel_result).

      IF ls_travel_result-EndDate LT ls_travel_result-BeginDate.

        APPEND VALUE #( %key       = ls_travel_result-%key
                        TravelUuid =  ls_travel_result-TravelUuid ) TO failed-travel.


        APPEND VALUE #( %key  = ls_travel_result-%key
                         %msg  = new_message( id        = 'ZMC_TRAVEL_8712'
                                              number    = '005'
                                              v1        = ls_travel_result-BeginDate
                                              v2        = ls_travel_result-EndDate
                                              v3        = ls_travel_result-TravelUuid
                                              severity  = if_abap_behv_message=>severity-error )
                        %element-BeginDate = if_abap_behv=>mk-on
                        %element-EndDate   = if_abap_behv=>mk-on ) TO reported-travel.

      ELSEIF ls_travel_result-BeginDate > cl_abap_context_info=>get_system_date( ).

        APPEND VALUE #( %key       = ls_travel_result-%key
                        TravelUuid =  ls_travel_result-TravelUuid ) TO failed-travel.


        APPEND VALUE #( %key  = ls_travel_result-%key
                        %msg  = new_message( id        = 'ZMC_TRAVEL_8712'
                                             number    = '002'
                                             severity  = if_abap_behv_message=>severity-error )
                       %element-BeginDate = if_abap_behv=>mk-on
                       %element-EndDate   = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validatestatus.

    READ ENTITY IN LOCAL MODE zi_travel_8712\\Travel
     FIELDS ( TravelStatus )
      WITH VALUE #( FOR <row_key> IN keys (  %key = <row_key>-%key ) )
        RESULT DATA(lt_travel_result).


    LOOP AT lt_travel_result INTO DATA(ls_travel_result).

      CASE ls_travel_result-TravelStatus.
        WHEN 'O'. "Open
        WHEN 'X'. "Cancelled
        WHEN 'A'. "Accepted

        WHEN OTHERS.

          APPEND VALUE #( %key = ls_travel_result-%key ) TO failed-travel.

          APPEND VALUE #( %key  = ls_travel_result-%key
                          %msg  = new_message( id        = 'ZMC_TRAVEL_8712'
                                               number    = '004'
                                               v1        = ls_travel_result-TravelStatus
                                               severity  = if_abap_behv_message=>severity-error )
                          %element-TravelStatus = if_abap_behv=>mk-on ) TO reported-travel.
      ENDCASE.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_travel_8712 DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PUBLIC SECTION.
    CONSTANTS:
      lv_create TYPE string VALUE 'CREATE',
      lv_update TYPE string VALUE 'UPDATE',
      Lv_delete TYPE string VALUE 'DELETE'.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zi_travel_8712 IMPLEMENTATION.

  METHOD save_modified.

    DATA:
      lt_travel_log   TYPE STANDARD TABLE OF ztb_log_8712,
      lt_travel_log_u TYPE STANDARD TABLE OF ztb_log_8712.

    DATA(lv_user)
      = cl_abap_context_info=>get_user_technical_name(  ).

***********************************************************************
***********************************************************************
    IF NOT create-travel IS INITIAL.
      lt_travel_log
          = CORRESPONDING #( create-travel
                     MAPPING travel_uuid = TravelUuid
                             travel_id   = TravelId ).
      "________________________________________________________________
      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<ls_travel_log>).
        "Obtener el tiempo
        GET TIME STAMP FIELD <ls_travel_log>-created_at.
        "Constante - crear
        <ls_travel_log>-changing_operation = lsc_zi_travel_8712=>lv_create.


        "Leer la tabla de la entidad travel
        "________________________________________________________________
        READ TABLE create-travel
        WITH TABLE KEY entity COMPONENTS TravelUuid = <ls_travel_log>-travel_uuid
            INTO DATA(ls_travel).

        IF sy-subrc EQ 0.

          IF ls_travel-%control-BookingFee = cl_abap_behv=>flag_changed.

            <ls_travel_log>-changed_field_name = 'BookingFee'.
            <ls_travel_log>-changed_value      = ls_travel-BookingFee.
            <ls_travel_log>-user_mod           = lv_user.
            TRY.
                <ls_travel_log>-change_id      = cl_system_uuid=>create_uuid_x16_static( ).
              CATCH cx_uuid_error.
            ENDTRY.

            APPEND <ls_travel_log> TO lt_travel_log_u.

          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

***********************************************************************
***********************************************************************
    IF NOT update-travel IS INITIAL.

      lt_travel_log
          = CORRESPONDING #( update-travel
                     MAPPING travel_uuid = TravelUuid
                             travel_id   = TravelId ).

      LOOP AT update-travel INTO DATA(ls_update_travel).

        ASSIGN lt_travel_log[
                  travel_uuid = ls_update_travel-TravelUuid
                  travel_id   = ls_update_travel-TravelId ]
                  TO FIELD-SYMBOL(<ls_update_travel_db>).

        GET TIME STAMP FIELD <ls_update_travel_db>-created_at.

        IF ls_update_travel-%control-CustomerId   EQ cl_abap_behv=>flag_changed.
          <ls_update_travel_db>-changed_field_name = 'CustomerId'.
          <ls_update_travel_db>-changed_value      = ls_update_travel-CustomerId.
          <ls_update_travel_db>-changing_operation = lsc_zi_travel_8712=>lv_update.
          <ls_update_travel_db>-user_mod           = lv_user.
          TRY.
              <ls_update_travel_db>-change_id      = cl_system_uuid=>create_uuid_x16_static( ).
            CATCH cx_uuid_error.
          ENDTRY.

          APPEND <ls_update_travel_db> TO lt_travel_log_u.
        ENDIF.

      ENDLOOP.

    ENDIF.
***********************************************************************
***********************************************************************
    IF NOT delete-travel IS INITIAL.
      "________________________________________________________________
      lt_travel_log
            = CORRESPONDING #( delete-travel
                       MAPPING travel_uuid = TravelUuid  ).

      "________________________________________________________________
      LOOP AT lt_travel_log ASSIGNING <ls_travel_log>.

        "Obtener el tiempo
        GET TIME STAMP FIELD <ls_travel_log>-created_at.
        "Constante - crear
        <ls_travel_log>-changing_operation = lsc_zi_travel_8712=>lv_delete.

        <ls_travel_log>-user_mod           = lv_user.
        TRY.
            <ls_travel_log>-change_id      = cl_system_uuid=>create_uuid_x16_static( ).
          CATCH cx_uuid_error.
        ENDTRY.

        APPEND <ls_travel_log> TO lt_travel_log_u.

      ENDLOOP.
    ENDIF.

    IF NOT lt_travel_log_u IS INITIAL.
      INSERT ztb_log_8712 FROM TABLE @lt_travel_log_u.
    ENDIF.

  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
