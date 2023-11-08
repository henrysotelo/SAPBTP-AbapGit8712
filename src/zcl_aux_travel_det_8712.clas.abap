CLASS zcl_aux_travel_det_8712 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    "Tipos de entidades
    TYPES:
      tt_travel_reported      TYPE TABLE FOR REPORTED zi_travel_8712,
      tt_booking_reported     TYPE TABLE FOR REPORTED zi_booking_8712,
      tt_supplements_reported TYPE TABLE FOR REPORTED zi_booksuppl_8712.

    "Tipos tablas
    TYPES:
      tt_travel_uuid TYPE TABLE OF sysuuid_x16.

    CLASS-METHODS:
      calculate_price
        IMPORTING
          it_travel_uuid     TYPE tt_travel_uuid
        EXPORTING
          it_travel_reported TYPE tt_travel_reported.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_aux_travel_det_8712 IMPLEMENTATION.

  METHOD calculate_price.

    DATA:
      lv_total_booking_price TYPE /dmo/total_price,
      lv_total_supplem_price TYPE /dmo/total_price.

    IF it_travel_uuid IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zi_travel_8712
     ENTITY Travel
     FIELDS ( TravelUuid TravelId CurrencyCode )
     WITH VALUE #( FOR travel_uuid IN it_travel_uuid
                      ( TravelUuid = travel_uuid ) )
     RESULT DATA(lt_read_travel).


    READ ENTITIES OF zi_travel_8712
     ENTITY Travel BY \_Booking
       FROM VALUE #( FOR travel_uuid IN it_travel_uuid
                      ( TravelUuid = travel_uuid
                        %control-FlightPrice   = if_abap_behv=>mk-on
                        %control-CurrencyCode  = if_abap_behv=>mk-on ) )
      RESULT DATA(lt_read_booking).


    LOOP AT lt_read_booking INTO DATA(ls_booking)
              GROUP BY ls_booking-ParentUuid INTO DATA(lv_travel_key).

      ASSIGN lt_read_travel[ KEY entity COMPONENTS TravelUuid = lv_travel_key ]
             TO FIELD-SYMBOL(<ls_travel>).

      LOOP AT GROUP lv_travel_key INTO DATA(ls_booking_result)
              GROUP BY ls_booking_result-CurrencyCode INTO DATA(lv_curr).

        lv_total_booking_price = 0.


        LOOP AT GROUP lv_curr INTO DATA(ls_booking_line).
          lv_total_booking_price += ls_booking_line-FlightPrice.
        ENDLOOP.

        IF lv_curr EQ <ls_travel>-CurrencyCode.
          "Update price in the table travel
          <ls_travel>-TotalPrice += lv_total_booking_price.

        ELSE.

          /dmo/cl_flight_amdp=>convert_currency(
            EXPORTING
              iv_amount               = lv_total_booking_price
              iv_currency_code_source = lv_curr
              iv_currency_code_target = <ls_travel>-CurrencyCode
              iv_exchange_rate_date   = cl_abap_context_info=>get_system_date(  )
            IMPORTING
              ev_amount               = DATA(lv_amount_converted) ).

          "Update price in the table travel
          <ls_travel>-TotalPrice += lv_amount_converted.

        ENDIF.
      ENDLOOP.
    ENDLOOP.

**********************************************************************
**********************************************************************
    READ ENTITIES OF zi_travel_8712
    ENTITY Booking BY \_BookingSupplement
      FROM VALUE #( FOR ls_travel IN lt_read_booking
                     ( BookingUuid            = ls_travel-BookingUuid
                       ParentUuid             = ls_travel-ParentUuid
                       %control-Price         = if_abap_behv=>mk-on
                       %control-CurrencyCode  = if_abap_behv=>mk-on ) )
     RESULT DATA(lt_read_Supplement).


    LOOP AT lt_read_Supplement INTO DATA(ls_booking_suppl)
           GROUP BY ls_booking_suppl-ParentUuid INTO lv_travel_key.


      ASSIGN lt_read_travel[ KEY entity COMPONENTS TravelUuid = lv_travel_key ]
               TO <ls_travel>.

      LOOP AT GROUP lv_travel_key INTO DATA(ls_supplements_result)
            GROUP BY ls_supplements_result-CurrencyCode INTO lv_curr.

        lv_total_supplem_price = 0.

        LOOP AT GROUP lv_curr INTO DATA(ls_supplement_line).
          lv_total_supplem_price += ls_supplement_line-Price.
        ENDLOOP.


        IF lv_curr EQ <ls_travel>-CurrencyCode.
          "Update price in the table travel
          <ls_travel>-TotalPrice += lv_total_supplem_price.

        ELSE.

          /dmo/cl_flight_amdp=>convert_currency(
            EXPORTING
              iv_amount               = lv_total_supplem_price
              iv_currency_code_source = lv_curr
              iv_currency_code_target = <ls_travel>-CurrencyCode
              iv_exchange_rate_date   = cl_abap_context_info=>get_system_date(  )
            IMPORTING
              ev_amount               = lv_amount_converted ).

          "Update price in the table travel
          <ls_travel>-TotalPrice += lv_amount_converted.

        ENDIF.

      ENDLOOP.

    ENDLOOP.


**********************************************************************
**********************************************************************
    MODIFY ENTITIES OF zi_travel_8712
        ENTITY Travel
        UPDATE FROM VALUE #( FOR ls_travel_bo IN lt_read_travel (
                                  TravelUuid = ls_travel_bo-TravelUuid
                                  TotalPrice = ls_travel_bo-TotalPrice
                                  %control-TotalPrice =   if_abap_behv=>mk-on
                            ) ).


  ENDMETHOD.

ENDCLASS.
