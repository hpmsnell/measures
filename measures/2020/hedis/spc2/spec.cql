library HEDIS_SPC2_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: SPC2
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// HEDIS value sets

valueset "HEDIS; Hospice": '2.16.840.1.113883.3.464.1004.1418'
valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Nonacute Inpatient": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; Acute Inpatient": '2.16.840.1.113883.3.464.1004.1017'
valueset "HEDIS; Inpatient Stay":
valueset "HEDIS; Telephone Visits":
valueset "HEDIS; Online Assessments":
valueset "HEDIS; IVD":
valueset "HEDIS; CABG":
valueset "HEDIS; PCI":
valueset "HEDIS; Other Revascularization":
valueset "HEDIS; Hospice":
valueset "HEDIS; ESRD":
valueset "HEDIS; Cirrhosis":
valueset "HEDIS; Pregnancy":
valueset "HEDIS; IVF":
valueset "HEDIS; MI":
valueset "HEDIS; Muscular Pain and Disease":
valueset "HEDIS; Frailty"
valueset "HEDIS; Advanced Illness"
valueset "HEDIS; Observation"
valueset "HEDIS; ED"

// NCQA value sets

valueset "NCQA; High and Moderate-Intensity Statin Medications"
valueset "NCQA; Estrogen Agonists Medications":

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Hospice":
  ["Intervention, Performed": "HEDIS; Hospice"]

define "Statin in Measurement Period":
  ["Medication, Order": "NCQA; High and Moderate-Intensity Statin Medications"] M
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

define "Denominator Exclusion: Frailty and Advanced Illness"
  /*
  * config_link_id: exclusion_3
  */
  "HEDIS SPC1: Denominator Exclusion: Frailty and Advanced Illness"

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
  and not "Denominator Exclusion: Frailty and Advanced Illness"
  and not "Numerator Performance Met"
