library HEDIS_PPC1_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: PPC1
 * Year: 2020
 * Version: 1
 * Author: Chana West
 *
  */

using QDM

// HEDIS value sets

valueset "HEDIS; Hospice Encounter": '2.16.840.1.113883.3.464.1004.1761'
valueset "HEDIS; Hospice Intervention": '2.16.840.1.113883.3.464.1004.1762'
valueset "HEDIS; Cervical Cytology Lab Test": '2.16.840.1.113883.3.464.1004.1525'
valueset "HEDIS; Cervical Cytology Result or Finding": '2.16.840.1.113883.3.464.1004.1524'
valueset "HEDIS; Postpartum Bundled Services": '2.16.840.1.113883.3.464.1004.1217'
valueset "HEDIS; Postpartum Visits": '2.16.840.1.113883.3.464.1004.1218'
valueset "HEDIS; Deliveries": '2.16.840.1.113883.3.464.1004.1072'
valueset "HEDIS; Non-Live Births": '2.16.840.1.113883.3.464.1004.1187'
valueset "HEDIS; Prenatal Bundled Services": '2.16.840.1.113883.3.464.1004.1223'
valueset "HEDIS; Stand Alone Prenatal Visits": '2.16.840.1.113883.3.464.1004.1240'
valueset "HEDIS; Prenatal Visits": '2.16.840.1.113883.3.464.1004.1225'
valueset "HEDIS; Pregnancy Diagnosis": '2.16.840.1.113883.3.464.1004.1220'

// VSAC value sets



parameter "Measurement Period" Interval<DateTime>

context Patient

define "Live Delivery":
  ["Procedure, Performed": "HEDIS; Deliveries"] Delivery
    where Delivery.relevantPeriod starts 85 days or less before start of "Measurement Period"
      and Delivery.relevantPeriod ends 86 days or less before end of "Measurement Period"
  and not exists ["Diagnosis": "HEDIS; Non-Live Births"] Nonlive
      where Nonlive.prevalencePeriod starts during Delivery.relevantPeriod

define "Hospice":
  (["Intervention, Performed": "HEDIS; Hospice Intervention"]
  union ["Encounter, Performed": "HEDIS; Hospice Encounter"])Hospice
    where Hospice.relevantPeriod overlaps "Measurement Period"

define "Prenatal Bundle Not Delivery":
  ["Procedure, Performed": "HEDIS; Prenatal Bundled Services"] PreNatBund
    where not exists ( "Live Delivery" D
      where D.relevantPeriod starts during PreNatBund.relevantPeriod
  )

define "Complete Prenatal Service":
  "Prenatal Bundle Not Delivery"
  union ["Encounter, Performed": "HEDIS; Stand Alone Prenatal Visits"]
  union ((["Encounter, Performed": "HEDIS; Prenatal Visits"])PNV
    with (["Diagnosis": "HEDIS; Pregnancy Diagnosis"])PregDx
      such that PregDx.prevalencePeriod overlaps PNV.relevantPeriod)

// Populations

define "Denominator":
  "Patient Characteristic Sex" = 'Female'
  and exists "Live Delivery" LD1
  and not exists" Live Delivery" LD2
   where LD1.relevantPeriod ends within 6 months of P2.relevantPeriod
  and not exists "Hospice"

define "Numerator Performance Met":
  /*
   * config_link_id: single
   */
  "Live Delivery" P
  and exists "Complete Prenatal Service" E
   where E.relevantPeriod in Interval [end of P.relevantPeriod - 280 days, end of P.relevantPeriod - 176 days]

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
