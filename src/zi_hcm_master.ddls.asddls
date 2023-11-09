@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'HCM - Master'
define root view entity ZI_HCM_MASTER
  as select from zhc_master_8712 as HCMMaster
{
  key e_number,
      e_name,
      e_department,
      status,
      job_title,
      start_date,
      end_date,
      email,
      m_number,
      m_name,
      m_department,
      crea_date_time,
      crea_uname,
      lchg_date_time,
      lchg_uname
}
