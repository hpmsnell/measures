library HEDIS_COA3_2020

/*
 *
 * Source: HEDIS
 * ID: COA3
 * Year: 2020
 * Version: 1
 * Author: Patrick Clark
 *
  */

using ADM v1

include "../shared/hedis_shared" called HedisShared

// HEDIS value sets

valueset "HEDIS; FUNCTIONAL_STATUS_ASSESSMENT": '2.16.840.1.113883.3.464.1004.1104'
valueset "HEDIS; ACUTE_INPATIENT_POS"
valueset "HEDIS; ACUTE_INPATIENT"
valueset "HEDIS; CPT_CAT_II_MODIFIER": '2.16.840.1.113883.3.464.1004.1464'


parameter "Measurement Period" Interval<DateTime>

context Patient

/* Populations */

define "Initial Population":
  AgeInYearsAt(end of "Measurement Period") >= 66

define "Denominator":
  "Initial Population"

define "Exclusion: Hospice":
  /*
   * Option ID: exclusion_required_hospice
   */
   exists("Hospice During Period"("Measurement Period"))

define "Numerator Performance Met":
  /*
   * Option ID: performance_met
   */
  exists("Functional Status Assessment" FSA
    where FSA.start_date during "Measurement Period"
      and FSA.place_of_service not in "HEDIS; ACUTE_INPATIENT_POS"
      and FSA.place_of_service != '81'
      and FSA.code_modifiers not in "HEDIS; CPT_CAT_II_MODIFIER"
    without ["Clinical Activity": "HEDIS; ACUTE_INPATIENT"] Inpatient
      such that (
        (
          FSA.claim_id != null
          and FSA.claim_id = Inpatient.claim_id
        )
        or (
          FSA.claim_id == null
          and FSA.start_date = Inpatient.start_date

        )
      )
    )

define "Numerator Performance Not Met":
  /*
   * Option ID: performance_not_met
   */


// Definitions

define "Functional Status Assessment":
  ["Clinical Activity": "HEDIS; FUNCTIONAL_STATUS_ASSESSMENT"]
