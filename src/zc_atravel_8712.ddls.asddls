@EndUserText.label: 'Consumption - Travel Approval'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_ATRAVEL_8712
    as projection on ZI_TRAVEL_8712
{
  key TravelUuid,
      TravelId,
      AgencyId,
      CustomerId,
      BeginDate,
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      CurrencyCode,
      Description,
      TravelStatus,
      LastChangedAt,
      /* Associations */
      _Booking : redirected to composition child ZC_ABOOKING_8713,
      _Customer,
      _Agency
}
