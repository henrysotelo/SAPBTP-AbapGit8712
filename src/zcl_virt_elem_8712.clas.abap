CLASS zcl_virt_elem_8712 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_virt_elem_8712 IMPLEMENTATION.

  METHOD if_sadl_exit_calc_element_read~calculate.

    DATA:
    lt_original_data TYPE STANDARD TABLE OF zc_travel_8712 WITH DEFAULT KEY.



    lt_original_data = CORRESPONDING #( it_original_data ).

    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<ls_original_data>).

      <ls_original_data>-DiscounPrice
          = <ls_original_data>-TotalPrice - ( <ls_original_data>-TotalPrice * ( 1 / 10 ) ).

    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_original_data  ).

  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

    IF iv_entity = 'ZC_TRAVEL_8712'.
      LOOP AT it_requested_calc_elements INTO DATA(ls_calc_elements).

        IF ls_calc_elements = 'DISCOUNPRICE'.

          APPEND 'TOTALPRICE' TO et_requested_orig_elements.

        ENDIF.

      ENDLOOP.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
