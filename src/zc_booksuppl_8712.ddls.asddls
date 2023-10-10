@EndUserText.label: 'Consumption - Booking Supplement'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_BOOKSUPPL_8712
  as projection on ZI_BOOKSUPPL_8712
{
  key BooksupplUuid,
  key RootUuid,
  key ParentUuid,
      BookingSupplementId,
      SupplementId,
     /* _SupplementText.Description: localized,*/
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,
      CurrencyCode,
      LocalLastChangedAt,
      /* Associations */
      _Travel  : redirected to ZC_TRAVEL_8712,
      _Booking : redirected to parent ZC_BOOKING_8713,
      _Supplement,
      _SupplementText
}
