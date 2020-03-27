library HEDIS_W34_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: W34
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

include "../shared/hedis_shared" version '1' called HedisShared

// HEDIS value sets

valueset "HEDIS; Well-Care": '2.16.840.1.113883.3.464.1004.1262'
valueset "HEDIS; Telehealth POS": '2.16.840.1.113883.3.464.1004.1460'
valueset "HEDIS; Telehealth Modifier": '2.16.840.1.113883.3.464.1004.1445'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Qualifying Encounter during Measurement Period":
  ((["Encounter, Performed": "HEDIS; Well-Care"]
  union ["Diagnosis": "HEDIS; Well-Care"]
  union ["Physical Exam, Performed": "HEDIS; Well-Care"])QualifyingEncounter
  where QualifyingEncounter.relevantPeriod starts during "Measurement Period"
    and QualifyingEncounter.signingProvider.primaryCareProvider = true
    and not QualifyingEncounter.placeOfService in "HEDIS; Telehealth POS"
    and not QualifyingEncounter.code.modifier in "HEDIS; Telehealth Modifier")

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 3
  and AgeInYearsAt(end of "Measurement Period") < 7

define "Exclusion: Hospice":
	   /*
	   * config_link_id: exclusion_required_hospice
	   */
	   exists("Hospice During Period"("Measurement Period"))

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists "Qualifying Encounter during Measurement Period"


define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
