@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface  - Booking Supplement'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_BOOKSUPPL_8712 as 
    select from ztb_booksul_8712 as BookingSupplement
    association to parent ZI_BOOKING_8712 as _Booking on $projection.ParentUuid = _Booking.BookingUuid
                                                     and $projection.RootUuid   = _Booking.ParentUuid
    association [1..1] to ZI_TRAVEL_8712 as _Travel on $projection.RootUuid = _Travel.TravelUuid
    association [1..1] to /DMO/I_Supplement as _Supplement on $projection.SupplementId = _Supplement.SupplementID
    association [1..*] to /DMO/I_SupplementText as _SupplementText  on $projection.SupplementId = _SupplementText.SupplementID
{
  key booksuppl_uuid        as BooksupplUuid,
  key root_uuid             as RootUuid,
  key parent_uuid           as ParentUuid,
      booking_supplement_id as BookingSupplementId,
      supplement_id         as SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,
      local_last_changed_at as LocalLastChangedAt,
      _Travel,
      _Booking,
      _Supplement,
      _SupplementText 
}
