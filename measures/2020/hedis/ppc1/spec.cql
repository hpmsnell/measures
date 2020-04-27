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
    without "Live Delivery" D
      such that D.relevantPeriod starts during PreNatBund.relevantPeriod

define "Complete Prenatal Service":
  "Prenatal Bundle Not Delivery"
  union ["Encounter, Performed": "HEDIS; Stand Alone Prenatal Visits"]
  union ((["Encounter, Performed": "HEDIS; Prenatal Visits"])PNV
    with (["Diagnosis": "HEDIS; Pregnancy Diagnosis"])PregDx
      such that PregDx.prevalencePeriod overlaps PNV.relevantPeriod)

// Populations

define "Denominator":

  "Live Delivery" LD1
    without "Live Delivery" LD2
      such that LD1.relevantPeriod ends within 6 months of LD2.relevantPeriod
    where exists (["Patient Characteristic Sex": "Female"])

define "Exclusion: Hospice":
   /*
   * config_link_id: exclusion_required_hospice
   */
   exists("Hospice During Period"("Measurement Period"))

define "Numerator Performance Met":
  /*
   * config_link_id: single
   */
  "Live Delivery" P
    with "Complete Prenatal Service" E
     such that E.relevantPeriod during Interval [end of P.relevantPeriod - 280 days, end of P.relevantPeriod - 176 days]

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
