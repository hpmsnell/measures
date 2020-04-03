library HEDIS_PPC2_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: PPC2
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// HEDIS value sets

valueset "HEDIS; Hospice Encounter": '2.16.840.1.113883.3.464.1004.1761'
valueset "HEDIS; Hospice Intervention": '2.16.840.1.113883.3.464.1004.1762'
valueset "HEDIS; Acute Inpatient": '2.16.840.1.113883.3.464.1004.1810'
valueset "HEDIS; Acute Inpatient POS": '2.16.840.1.113883.3.464.1004.1027'
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

define "Cervical Cytology with Results":
  ["Procedure, Performed": "HEDIS; Cervical Cytology Lab Test"]
  union ["Laboratory Test, Performed": "HEDIS; Cervical Cytology Lab Test"]
  union ["Laboratory Test, Performed": "HEDIS; Cervical Cytology Result or Finding"]

define "Postpartum Bundle Not Delivery":
  ["Procedure, Performed": "HEDIS; Postpartum Bundled Services"] PPBundle
    without "Live Delivery" Delivered
      such that Delivered.relevantPeriod during PPBundle.relevantPeriod

define "Acute Inpatient":
  ["Encounter, Performed": "HEDIS; Acute Inpatient"]
  union ["Encounter, Performed": "HEDIS; Acute Inpatient POS"]

define "Postpartum Visit":
  ("Postpartum Bundle Not Delivery"
  union "Cervical Cytology with Results"
  union ["Encounter, Performed": "HEDIS; Postpartum Visits"]
  union ["Diagnosis": "HEDIS; Postpartum Visits"])PPVisits
    without "Acute Inpatient" AcuteIP
      such that PPVisits.relevantPeriod during AcuteIP.relevantPeriod


// Populations

define "Denominator":
  "Live Delivery" LD1
    without "Live Delivery" LD2
      such that LD1.relevantPeriod ends within 6 months of LD2.relevantPeriod
    where not exists "Hospice"
    //exists (["Patient Characteristic Sex": "Female"])

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  "Live Delivery" Delivery
    with "Postpartum Visit" PPVisit
      such that Delivery.relevantPeriod during Interval [end of Delivery.relevantPeriod + 7 days, end of Delivery.relevantPeriod + 84 days]

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
