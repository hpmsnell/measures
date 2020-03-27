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

include "../shared/hedis_shared" version '1' called HedisShared

// VSAC value sets

valueset "VSAC; Current Medications Documented SNMD"

// HEDIS value sets

valueset "HEDIS; Medication Review": '2.16.840.1.113883.3.464.1004.1175'
valueset "HEDIS; Medication List": '2.16.840.1.113883.3.464.1004.1173'
valueset "HEDIS; Transitional Care Management Services": '2.16.840.1.113883.3.464.1004.1462'
valueset "HEDIS; CPT CAT II Modifier": '2.16.840.1.113883.3.464.1004.1464'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Medication List":
  (["Procedure, Performed": "HEDIS; Medication List"]
  union ["Procedure, Performed": "VSAC; Current Medications Documented SNMD"]) MedList
    where MedList.relevantPeriod starts during "Measurement Period"
      and MedList.signingProvider.prescribing = true
      and MedList.placeOfService != '81'
      and MedList.code.modifiers not in "HEDIS; CPT CAT II Modifier"

define "Medication Review":
  ["Procedure, Performed": "HEDIS; Medication Review"] MedReview
    where MedReview.relevantPeriod starts during "Measurement Period"
      and MedReview.signingProvider.prescribing = true
      and MedReview.placeOfService != '81'
      and MedReview.code.modifiers not in "HEDIS; CPT CAT II Modifier"

/* Populations */

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 66

define "Exclusion: Hospice":
  /*
   * config_link_id: exclusion_required_hospice
   */
   exists("Hospice During Period"("Measurement Period"))

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  "Medication Review" MedReview
    with "Medication List" MedList
      such that MedReview.claimId = MedList.claimId
  or exists(["Procedure, Performed": "HEDIS; Transitional Care Management Sercices"] Trans
    where Trans.relevantPeriod starts during "Measurement Period"
      and Trans.placeOfService != '81'
      and Trans.code.modifiers not in "HEDIS; CPT CAT II Modifier")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"
