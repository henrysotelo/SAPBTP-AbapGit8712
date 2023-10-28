CLASS lhc_booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculatetotalflightprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR booking~calculatetotalflightprice.

    METHODS calculatetotalsupplimprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR booking~calculatetotalsupplimprice.

    METHODS validatestatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR booking~validatestatus.

ENDCLASS.

CLASS lhc_booking IMPLEMENTATION.

  METHOD calculatetotalflightprice.
  ENDMETHOD.

  METHOD calculatetotalsupplimprice.
  ENDMETHOD.

  METHOD validatestatus.
  ENDMETHOD.

ENDCLASS.
