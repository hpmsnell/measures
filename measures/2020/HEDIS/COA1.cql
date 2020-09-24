library HEDIS_COA1_2019 version '1'

/*
 *
 * Source: HEDIS
 * ID: COA1
 * Year: 2019
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

include "../shared/hedis_shared" version '1' called HedisShared

// HEDIS value sets

valueset "HEDIS; Advance Care Planning": '2.16.840.1.113883.3.464.1004.1020'
valueset "HEDIS; CPT CAT II Modifier": '2.16.840.1.113883.3.464.1004.1464'

// Able Value Sets

valueset "Able; Advance Directive"
valueset "Able; Advance Directive Discussed"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Advance Care Planning":
  ["Procedure, Performed": "HEDIS; Advance Care Planning"]
  union ["Diagnosis": "HEDIS; Advance Care Planning"]
  union ["Procedure, Performed": "Able; Advance Directive"]
  union ["Procedure, Performed": "Able; Advance Directive Discussed"]

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
  exists("Advance Care Planning" CarePlan
    where CarePlan.relevantPeriod starts during "Measurement Period"
      and CarePlan.placeOfService != '81'
      and CarePlan.code.modifiers not in "HEDIS; CPT CAT II Modifier")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
