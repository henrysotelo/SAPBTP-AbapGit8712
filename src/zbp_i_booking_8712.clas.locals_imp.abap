CLASS lhc_booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculatetotalflightprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR booking~calculatetotalflightprice.

    METHODS calculatetotalsupplimprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR booking~calculatetotalsupplimprice.

    METHODS validatestatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR booking~validatestatus.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Booking RESULT result.

ENDCLASS.

CLASS lhc_booking IMPLEMENTATION.

  METHOD calculatetotalflightprice.

    IF NOT keys IS INITIAL.

      zcl_aux_travel_det_8712=>calculate_price( it_travel_uuid
                              = VALUE #( FOR GROUPS <booking> OF booking_key IN keys
                                GROUP BY booking_key-ParentUuid WITHOUT MEMBERS ( <booking> ) ) ).
    ENDIF.

  ENDMETHOD.

  METHOD calculatetotalsupplimprice.
  ENDMETHOD.

  METHOD validatestatus.

    READ ENTITY IN LOCAL MODE zi_travel_8712\\Booking
      FIELDS ( BookingStatus )
       WITH VALUE #( FOR <row_key> IN keys (  %key = <row_key>-%key ) )
         RESULT DATA(lt_booking_result).


    LOOP AT lt_booking_result INTO DATA(ls_booking_result).

      CASE ls_booking_result-BookingStatus.
        WHEN 'N'. "New
        WHEN 'X'. "Cancelled
        WHEN 'B'. "Booking

        WHEN OTHERS.

          APPEND VALUE #( %key = ls_booking_result-%key ) TO failed-booking.

          APPEND VALUE #( %key  = ls_booking_result-%key
                          %msg  = new_message( id        = 'ZMC_TRAVEL_8712'
                                               number    = '007'
                                               v1        = ls_booking_result-BookingId
                                               severity  = if_abap_behv_message=>severity-error )
                          %element-BookingStatus = if_abap_behv=>mk-on ) TO reported-booking.
      ENDCASE.

    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_features.

    "Leer la entidad travel
    READ ENTITIES OF zi_travel_8712 IN LOCAL MODE
        ENTITY Booking
        FIELDS ( BookingUuid BookingId BookingDate CustomerId BookingStatus )
        WITH VALUE #( FOR key_row IN keys ( %key = key_row-%key ) )
        RESULT DATA(lt_booking_result).

    "Actualizar salida de la interface
    result = VALUE #( FOR ls_travel IN lt_booking_result
                          (
                          %key                      = ls_travel-%key
                          %assoc-_BookingSupplement = if_abap_behv=>fc-o-enabled  ) ).
  ENDMETHOD.

ENDCLASS.
