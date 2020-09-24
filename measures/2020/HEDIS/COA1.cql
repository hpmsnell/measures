library HEDIS_COA1_2020

/*
 *
 * Source: HEDIS
 * ID: COA1
 * Year: 2020
 * Version: 1
 * Author: Patrick Clark
 *
  */

using ADM v1

include "../shared/hedis_shared" version '1' called HedisShared

// HEDIS value sets

valueset "HEDIS; ADVANCE_CARE_PLANNING": '2.16.840.1.113883.3.464.1004.1020'
valueset "HEDIS; CPT_CAT_II_MODIFIER": '2.16.840.1.113883.3.464.1004.1464'

// Able Value Sets

valueset "Able; ADVANCE_DIRECTIVE"
valueset "Able; ADVANCE_DIRECTIVE_DISCUSSED"

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
  exists("Advance Care Planning" CarePlan
    where CarePlan.start_date during "Measurement Period"
      and CarePlan.place_of_service != '81'
      and CarePlan.code_modifiers not in "HEDIS; CPT_CAT_II_MODIFIER")

define "Numerator Performance Not Met":
  /*
   * Option ID: performance_not_met
   */
  not "Numerator Performance Met"
// Definitions

define "Advance Care Planning":
  ["Clinical Activity": "HEDIS; ADVANCE_CARE_PLANNING"]
  union ["Diagnosis": "HEDIS; ADVANCE_CARE_PLANNING"]
  union ["Clinical Activity": "Able; ADVANCE_DIRECTIVE"]
  union ["Clinical Activity": "Able; ADVANCE_DIRECTIVE_DISCUSSED"]
