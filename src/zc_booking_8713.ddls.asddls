@EndUserText.label: 'Consumption  - Booking'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity ZC_BOOKING_8713 as projection on ZI_BOOKING_8712
{
  key BookingUuid,
  key ParentUuid,
      @Search.defaultSearchElement: true
      BookingId,
      BookingDate,
      CustomerId,
      CarrierId,
      ConnectionId,
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      CurrencyCode,
      BookingStatus,
      LocalLastChangedAt,
      /* Associations */
      _Travel : redirected to parent ZC_TRAVEL_8712,
      _BookingSupplement: redirected to composition child ZC_BOOKSUPPL_8712,
      _Customer,
      _Carrier,
      _Connection
}
