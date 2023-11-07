CLASS lhc_supplement DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculatetotalsupplimprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR supplement~calculatetotalsupplimprice.

ENDCLASS.

CLASS lhc_supplement IMPLEMENTATION.

  METHOD calculatetotalsupplimprice.


     IF NOT keys IS INITIAL.

      zcl_aux_travel_det_8712=>calculate_price( it_travel_uuid
                              = VALUE #( FOR GROUPS <booking_suppl> OF booking_key IN keys
                                GROUP BY booking_key-ParentUuid WITHOUT MEMBERS ( <booking_suppl> ) ) ).
    ENDIF.



  ENDMETHOD.

ENDCLASS.
