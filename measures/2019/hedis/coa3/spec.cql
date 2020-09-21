library HEDIS_COA3_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: COA3
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

include "../shared/hedis_shared" version '1' called HedisShared

// HEDIS value sets

valueset "HEDIS; Functional Status Assessment": '2.16.840.1.113883.3.464.1004.1104'
valueset "HEDIS; Acute Inpatient POS"
valueset "HEDIS; Acute Inpatient"
valueset "HEDIS; CPT CAT II Modifier": '2.16.840.1.113883.3.464.1004.1464'

// Able value sets

valueset "Able; Functional Status Assessment"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Functional Status Assessment":
  ["Procedure, Performed": "HEDIS; Functional Status Assessment"]
  union ["Procedure, Performed": "Able; Functional Status Assessment"]

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
  exists("Functional Status Assessment" FSA
    where FSA.relevantPeriod starts during "Measurement Period"
      and FSA.code.placeOfService not in "HEDIS; Acute Inpatient POS"
      and FSA.placeOfService != '81'
      and FSA.code.modifiers not in "HEDIS; CPT CAT II Modifier"
    without ["Procedure, Performed": "HEDIS; Acute Inpatient"] Inpatient
      such that (
        (
          FSA.claimId != null
          and FSA.claimId = Inpatient.claimId
        )
        or (
          FSA.claimId == null
          and FSA.startDate = Inpatient.startDate

        )
      )
    )

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"
