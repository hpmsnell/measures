library HEDIS_SPC2_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: SPC2
 * Year: 2020
 * Version: 1
 * Author: Patrick Clark
 *
  */

using QDM

include "../shared/hedis_shared" version '1' called HedisShared

// HEDIS value sets

valueset "HEDIS; CABG": '2.16.840.1.113883.3.464.1004.1048'
valueset "HEDIS; Cirrhosis": '2.16.840.1.113883.3.464.1004.1379'
valueset "HEDIS; Dialysis Procedure": '2.16.840.1.113883.3.464.1004.1952'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; ESRD Diagnosis": '2.16.840.1.113883.3.464.1004.1747'
valueset "HEDIS; Inpatient Stay": '2.16.840.1.113883.3.464.1004.1395'
valueset "HEDIS; IVD": '2.16.840.1.113883.3.464.1004.1137'
valueset "HEDIS; IVF": '2.16.840.1.113883.3.464.1004.1392'
valueset "HEDIS; MI": '2.16.840.1.113883.3.464.1004.1157'
valueset "HEDIS; Muscular Pain and Disease": '2.16.840.1.113883.3.464.1004.1381'
valueset "HEDIS; Nonacute Inpatient": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; Nonacute Inpatient Stay": '2.16.840.1.113883.3.464.1004.1398'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'
valueset "HEDIS; Online Assessments": '2.16.840.1.113883.3.464.1004.1446'
valueset "HEDIS; Other Revascularization": '2.16.840.1.113883.3.464.1004.1388'
valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; PCI": '2.16.840.1.113883.3.464.1004.1204'
valueset "HEDIS; Pregnancy": '2.16.840.1.113883.3.464.1004.1219'
valueset "HEDIS; Telehealth Modifier": '2.16.840.1.113883.3.464.1004.1445'
valueset "HEDIS; Telehealth POS": '2.16.840.1.113883.3.464.1004.1460'
valueset "HEDIS; Telephone Visits": '2.16.840.1.113883.3.464.1004.1246'



// NCQA medication list value sets

valueset "NCQA; High and Moderate-Intensity Statin Medications"
valueset "NCQA; Estrogen Agonists Medications":

parameter "Measurement Period" Interval<DateTime>

context Patient


define "Statin in Measurement Period":
  ["Medication, Dispensed": "NCQA; High and Moderate-Intensity Statin Medications"] M
    where M.relevantPeriod starts during "Measurement Period"

define "Prescription Start Date":
  "Statin in Measurement Period" M
    return start of M.relevantPeriod

define "Prescription Stop Date":
  "Statin in Measurement Period" M
    return end of M.relevantPeriod

define "Prescription Duration":
  Min(
    {
      days between "Prescription Start Date" and "Prescription Stop Date",
      days between "Prescription Start Date" and end of "Measurement Period" // Default to this if Stop Date is null
    }
  )

define "Sum of Prescription Durations":
  Sum("Prescription Duration")

define "First Prescription Start Date":
  First("Prescription Start Date")

define "Treatment Period":
  days between "First Prescription Start Date" and end of "Measurement Period"

/* Populations */

define "Denominator":
  "HEDIS SPC1: Performance Met"

define "Denominator Exclusion: Condition"
  /*
  * config_link_id: exclusion_1
  */
  "HEDIS SPC1: Denominator Exclusion: Condition"

define "Denominator Exclusion: Pregnancy"
  /*
  * config_link_id: exclusion_2
  */
  "HEDIS SPC1: Denominator Exclusion: Pregnancy"

define "Exclusion: Hospice":
   /*
   * config_link_id: exclusion_required_hospice
   */
   exists("Hospice During Period"("Measurement Period"))

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  "Sum of Prescription Durations" / "Treatment Period" >= 0.8

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion: Condition"
  and not "Denominator Exclusion: Pregnancy"
  and not "Exclusion: Hospice"
  and not "Numerator Performance Met"
