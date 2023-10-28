@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface  - Booking'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_BOOKING_8712
  as select from ztb_booking_8712 
  association to parent ZI_TRAVEL_8712 as _Travel on $projection.ParentUuid =  _Travel.TravelUuid
  
  composition [0..*] of ZI_BOOKSUPPL_8712 as _BookingSupplement
 
  association [1..1] to /DMO/I_Customer as _Customer
                        on $projection.CustomerId = _Customer.CustomerID
  association [1..1] to /DMO/I_Carrier as _Carrier
                        on $projection.CarrierId = _Carrier.AirlineID                   
  association [1..*] to /DMO/I_Connection as _Connection
                        on $projection.ConnectionId = _Connection.ConnectionID                   
  
{
  key booking_uuid          as BookingUuid,
  key parent_uuid           as ParentUuid,
      booking_id            as BookingId,
      booking_date          as BookingDate,
      customer_id           as CustomerId,
      carrier_id            as CarrierId,
      connection_id         as ConnectionId,
      flight_date           as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price          as FlightPrice,
      currency_code         as CurrencyCode,
      booking_status        as BookingStatus,
      local_last_changed_at as LocalLastChangedAt,
      _Travel,
      _BookingSupplement,
      _Customer,
      _Carrier,
      _Connection
} 
