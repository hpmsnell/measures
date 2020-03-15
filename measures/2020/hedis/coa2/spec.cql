library HEDIS_COA2_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: COA2
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// VSAC value sets

valueset "VSAC; Current Medications Documented SNMD"

// HEDIS value sets

valueset "HEDIS; Hospice": '2.16.840.1.113883.3.464.1004.1418'
valueset "HEDIS; Medication Review": '2.16.840.1.113883.3.464.1004.1175'
valueset "HEDIS; Medication List": '2.16.840.1.113883.3.464.1004.1173'
valueset "HEDIS; Transitional Care Management Services": '2.16.840.1.113883.3.464.1004.1462'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Medication List":
  (["Procedure, Performed": "HEDIS; Medication List"]
  union ["Procedure, Performed": "VSAC; Current Medications Documented SNMD"]) MedList
    where MedList.relevantPeriod starts during "Measurement Period"
      and MedList.signingProvider.prescribing = true

define "Medication Review":
  ["Procedure, Performed": "HEDIS; Medication Review"] MedReview
    where MedReview.relevantPeriod starts during "Measurement Period"
      and MedReview.signingProvider.prescribing = true

define "Hospice":
  ["Intervention, Performed": "HEDIS; Hospice"]

/* Populations */

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 66
  and not exists("Hospice" I
    where I.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  "Medication Review" MedReview
    with "Medication List" MedList
      such that MedReview.claimId = MedList.claimId

  or exists(["Procedure, Performed": "HEDIS; Transitional Care Management Sercices"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"
