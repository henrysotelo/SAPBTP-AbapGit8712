CLASS zcl_8712_data_generator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_8712_data_generator IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    out->write( |Delete   -> Travel ztb_travel_8712a| ).
    DELETE FROM ztb_travel_8712a.

    out->write('|Insert   -> Travel ztb_travel_8712a|').
    INSERT ztb_travel_8712a
        FROM (
        SELECT FROM /dmo/travel FIELDS
        " client
        uuid( ) AS travel_uuid,
        travel_id,
        agency_id,
        customer_id,
        begin_date,
        end_date,
        booking_fee,
        total_price,
        currency_code,
        description,
        CASE status WHEN 'B' THEN 'A'
                    WHEN 'P' THEN 'O'
                    WHEN 'N' THEN 'O'
                    ELSE 'X' END AS overall_status,
        createdby AS local_created_by,
        createdat AS local_created_at,
        lastchangedby AS local_last_changed_by,
        lastchangedat AS local_last_changed_at,
        lastchangedat AS last_changed_at
       WHERE travel_id BETWEEN '00000001' AND '00000025' ).

    IF sy-subrc EQ 0.
      out->write( |Travel entries inserted:  { sy-dbcnt }| ).
    ENDIF.

*    "bookings

    out->write( |Delete   -> Travel ztb_booking_8712| ).
    delete from ztb_booking_8712.                         "#EC CI_NOWHERE

    out->write( |Insert ----> Bookings ztb_booking_8712| ).
    insert ztb_booking_8712 from (
        select
          from /dmo/booking
            join ztb_travel_8712a on /dmo/booking~travel_id = ztb_travel_8712a~travel_id
            join /dmo/travel on /dmo/travel~travel_id = /dmo/booking~travel_id
          fields  "client,
                  uuid( ) as booking_uuid,
                  ztb_travel_8712a~travel_uuid as parent_uuid,
                  /dmo/booking~booking_id,
                  /dmo/booking~booking_date,
                  /dmo/booking~customer_id,
                  /dmo/booking~carrier_id,
                  /dmo/booking~connection_id,
                  /dmo/booking~flight_date,
                  /dmo/booking~flight_price,
                  /dmo/booking~currency_code,
                  case /dmo/travel~status when 'P' then 'N'
                                                   else /dmo/travel~status end as booking_status,
                  ztb_travel_8712a~last_changed_at as local_last_changed_at
    ).

    if sy-subrc eq 0.
      out->write( |Booking entries inserted:  { sy-dbcnt }| ).
    endif.


 " supplements
    out->write( |Delete   -> Travel ztb_booksul_8712| ).
    delete from ztb_booksul_8712.                         "#EC CI_NOWHERE

    out->write( |----> Bookings ztb_booksul_8712| ).
    insert ztb_booksul_8712 from (
      select from /dmo/book_suppl    as supp
               join ztb_travel_8712a  as trvl on trvl~travel_id = supp~travel_id
               join ztb_booking_8712 as book on book~parent_uuid = trvl~travel_uuid
                                          and book~booking_id = supp~booking_id

        fields
          " client
          uuid( )                 as booksuppl_uuid,
          trvl~travel_uuid        as root_uuid,
          book~booking_uuid       as parent_uuid,
          supp~booking_supplement_id,
          supp~supplement_id,
          supp~price,
          supp~currency_code,
          trvl~last_changed_at    as local_last_changed_at
    ).

    if sy-subrc eq 0.
      out->write( |Supplements entries inserted:  { sy-dbcnt }| ).
    endif.

  ENDMETHOD.

ENDCLASS.
