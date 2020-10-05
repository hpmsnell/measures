library HEDIS_W34_2019 version '1'

/*
 *
 * Source: HEDIS
 * ID: W34
 * Year: 2019
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

/*
At least one well-child visit (Well-Care Value Set) with a PCP during the measurement year.
Do not count visits billed with a telehealth modifier (Telehealth Modifier Value Set)
  or billed with a telehealth POS code (Telehealth POS Value Set).
The well-child visit must occur with a PCP, but the PCP does not have to be the practitioner assigned to the child.

NOTE: Despite the logic saying "well-child visit," it includes procedures and diagnoses
      For Well-Care diagnoses and procedure, we will NOT have a PCP. NCQA states that we can date-corelated
      the well-care dx/proc w/ an encounter w/ a PCP for this to count - that's why we're joining to visit
*/
define "Qualifying Encounter during Measurement Period":
  (
    //well-care encounter
    ["Physical Exam, Performed": "HEDIS; Well-Care"]
    union ["Diagnosis, Performed": "HEDIS; Well-Care"]
    union (
        //well-care dx or well-care procedure to ANY encounter, NOT just well-care visit
        (["Encounter, Performed"]) AnyVisit //NOTE: NOT valid CQL, but ANY ENCOUNTER counts here
        with (["Diagnosis": "HEDIS; Well-Care"]
          union ["Physical Exam, Performed": "HEDIS; Well-Care"]) QualifyingEvent
        such that AnyVisit.relevantPeriod starts same day as start of QualifyingEvent.relevantPeriod
        where QualifyingEvent.placeOfService != '81' //just in case place of service says lab, filter it out
      )
  ) QualifyingEncounter
  where QualifyingEncounter.relevantPeriod starts during "Measurement Period"
  and QualifyingEncounter.signingProvider.primaryCareProvider = true
  and not QualifyingEncounter.placeOfService in "HEDIS; Telehealth POS"
  and not QualifyingEncounter.code.modifier in "HEDIS; Telehealth Modifier"
  and QualifyingEncounter.placeOfService != '81'

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
