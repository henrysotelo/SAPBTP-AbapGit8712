@EndUserText.label: 'Consumption  - Booking Approval'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_ABOOKING_8713 
    as projection on ZI_BOOKING_8712
{
  key BookingUuid,
  key ParentUuid,
      BookingId,
      BookingDate,
      CustomerId,
      CarrierId,
      _Carrier.Name as CarrierName,
      ConnectionId,
      FlightDate,
      FlightPrice,
      CurrencyCode,
      BookingStatus,
      LocalLastChangedAt,
      /* Associations */
      _Travel : redirected to parent ZC_ATRAVEL_8712,
      _Customer,
      _Carrier
}
