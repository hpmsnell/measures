library HEDIS_W34_2020

/*
 *
 * Source: HEDIS
 * ID: WCV
 * Year: 2020
 * Version: 1
 * Author: Patrick Clark
 *
  */

using ADM v1

include "../shared/hedis_shared"  called HedisShared

// HEDIS value sets

valueset "HEDIS; WELL_CARE": '2.16.840.1.113883.3.464.1004.1262'


parameter "Measurement Period" Interval<DateTime>

context Patient

/*
At least one well-child visit (Well-Care Value Set) with a PCP during the measurement year.
The well-child visit must occur with a PCP, but the PCP does not have to be the practitioner assigned to the child.

NOTE: Despite the logic saying "well-child visit," it includes procedures and diagnoses
      For Well-Care diagnoses and procedure, we will NOT have a PCP. NCQA states that we can date-corelated
      the well-care dx/proc w/ an encounter w/ a PCP for this to count - that's why we're joining to visit
*/


//Populations

define "Initial Population":
  AgeInYearsAt(end of "Measurement Period") >= 3
  and AgeInYearsAt(end of "Measurement Period") < 21

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
  exists "Qualifying Encounter during Measurement Period"


define "Numerator Performance Not Met":
  /*
   * Option ID: performance_not_met
   */
  not "Numerator Performance Met"

define "Qualifying Encounter during Measurement Period":
  (
    //well-care encounter
    ["Clinical Activity": "HEDIS; WELL_CARE"]
    //union ["Diagnosis, Performed": "HEDIS; WELL_CARE"]
    union (
        //well-care dx or well-care procedure to ANY encounter, NOT just well-care visit
        (["Clinical Activity"]) AnyVisit //NOTE: NOT valid CQL, but ANY ENCOUNTER counts here
        with (["Diagnosis": "HEDIS; WELL_CARE"]
          union ["Clinical Activity": "HEDIS; WELL_CARE"]) QualifyingEvent
        such that AnyVisit.start_date same day as QualifyingEvent.start_date
        where QualifyingEvent.place_of_service != '81'
      )
  ) QualifyingEncounter
  where QualifyingEncounter.start_date during "Measurement Period"
  and QualifyingEncounter.signingProvider.primaryCareProvider = true //plcedit
  and QualifyingEncounter.place_of_service != '81'
