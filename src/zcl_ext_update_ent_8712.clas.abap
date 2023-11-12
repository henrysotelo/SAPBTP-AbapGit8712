CLASS zcl_ext_update_ent_8712 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_EXT_UPDATE_ENT_8712 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    MODIFY ENTITIES OF zi_travel_8712
            ENTITY Travel
            UPDATE FIELDS ( AgencyId Description )
            WITH VALUE #( ( TravelUuid    = '9F680AE07AC208AD1800C6527A2CBF37'
                            AgencyId      = '070042'
                            Description   = 'Upadate external entity' ) )
            FAILED DATA(failed)
            REPORTED DATA(reported).

    READ ENTITIES OF zi_travel_8712
        ENTITY Travel
        FIELDS ( AgencyId Description )
        WITH VALUE #( ( TravelUuid = '9F680AE07AC208AD1800C6527A2CBF37' ) )
        RESULT DATA(result)
        FAILED failed
        REPORTED reported.

    COMMIT ENTITIES.

    IF failed IS INITIAL.
      out->write( 'Commit Successfull' ).
    ELSE.
      out->write( 'Commit Failed' ).
    ENDIF.


  ENDMETHOD.
ENDCLASS.
