FUNCTION z_suppl_8712.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_SUPPLEMENTS) TYPE  ZTT_SUPPLE_8712
*"     REFERENCE(IV_OP_TYPE) TYPE  ZDE_FLAG_8712
*"  EXPORTING
*"     REFERENCE(EV_UPDATED) TYPE  ZDE_FLAG_8712
*"----------------------------------------------------------------------
  CHECK NOT it_supplements IS INITIAL.

  CASE iv_op_type.
    WHEN 'C'.
      INSERT ztb_booksul_8712 FROM TABLE @it_supplements.

    WHEN 'U'.
      UPDATE ztb_booksul_8712 FROM TABLE @it_supplements.

    WHEN 'D'.
      DELETE ztb_booksul_8712 FROM TABLE @it_supplements.

  ENDCASE.

  IF sy-subrc EQ 0.
    ev_updated = abap_true.
  ENDIF.

ENDFUNCTION.
