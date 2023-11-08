@EndUserText.label: 'Consumption - Travel 8712'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_TRAVEL_8712
  provider contract transactional_query
  as projection on ZI_TRAVEL_8712
{
  key     TravelUuid,
          TravelId,
          @ObjectModel.text.element: [ 'AgencyId' ]
          AgencyId,
          _Agency.Name as AgencyName,
          @ObjectModel.text.element: [ 'CustomerId' ]
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
          @Semantics.amount.currencyCode: 'CurrencyCode'
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRT_ELEM_8712'
  virtual DiscounPrice : /dmo/total_price,
          /* Associations */
          _Booking : redirected to composition child ZC_BOOKING_8713,
          _Agency,
          _Currency,
          _Customer
}
