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
**********************************************************************
**********************************************************************
CLASS lsc_supplement DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PUBLIC SECTION.
    CONSTANTS: create TYPE string VALUE 'C',
               update TYPE string VALUE 'U',
               delete TYPE string VALUE 'D'.

  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_supplement IMPLEMENTATION.

  METHOD save_modified.

    DATA: lt_supplements TYPE STANDARD TABLE OF ztb_booksul_8712,
          lv_op_type     TYPE zde_flag,
          lv_updated     TYPE zde_flag.

    IF NOT create-supplement IS INITIAL.

      lt_supplements
        = CORRESPONDING #( create-supplement
                           MAPPING booksuppl_uuid           = BooksupplUuid
                                   parent_uuid              = ParentUuid
                                   root_uuid                = RootUuid
                                   booking_supplement_id    = BookingSupplementId
                                   supplement_id            = SupplementId
                                   price                    = Price
                                   currency_code            = CurrencyCode
                                   local_last_changed_at    = LocalLastChangedAt ).

      lv_op_type     = lsc_supplement=>create.

    ENDIF.


    IF NOT update-supplement IS INITIAL.

      lt_supplements
        = CORRESPONDING #( update-supplement
                           MAPPING booksuppl_uuid           = BooksupplUuid
                                   parent_uuid              = ParentUuid
                                   root_uuid                = RootUuid
                                   booking_supplement_id    = BookingSupplementId
                                   supplement_id            = SupplementId
                                   price                    = Price
                                   currency_code            = CurrencyCode
                                   local_last_changed_at    = LocalLastChangedAt ).

      lv_op_type = lsc_supplement=>update.

    ENDIF.

    IF NOT delete-supplement IS INITIAL.

      lt_supplements
        = CORRESPONDING #( delete-supplement
                           MAPPING booksuppl_uuid           = BooksupplUuid
                                   parent_uuid              = ParentUuid
                                   root_uuid                = RootUuid ).

      lv_op_type = lsc_supplement=>delete.

    ENDIF.


    IF NOT lt_supplements IS INITIAL.

      CALL FUNCTION 'Z_SUPPL_8712'
        EXPORTING
          it_supplements = lt_supplements
          iv_op_type     = lv_op_type
        IMPORTING
          ev_updated     = lv_updated.

      IF lv_updated EQ abap_true.
*          reported-supplement
      ENDIF.

    ENDIF.

  ENDMETHOD.

ENDCLASS.
