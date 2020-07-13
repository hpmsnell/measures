library HEDIS_ART_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: ART
 * Year: 2020
 * Version: 1
 * Author: Jonathan Sams
 *
  */

using QDM

include "../shared/hedis_shared" version '1' called HedisShared

// HEDIS value sets

valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Nonacute Inpatient": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; Inpatient Stay": '2.16.840.1.113883.3.464.1004.1395'
valueset "HEDIS; Rheumatoid Arthritis": '2.16.840.1.113883.3.464.1004.1229'
valueset "HEDIS; HIV": '2.16.840.1.113883.3.464.1004.1110'
valueset "HEDIS; HIV Type 2": '2.16.840.1.113883.3.464.1004.1406'
valueset "HEDIS; DMARD": '2.16.840.1.113883.3.464.1004.1070'
valueset "HEDIS; Telephone Visits": '2.16.840.1.113883.3.464.1004.1246'
valueset "HEDIS; Online Assessments": '2.16.840.1.113883.3.464.1004.1446'
valueset "HEDIS; Telehealth Modifier": '2.16.840.1.113883.3.464.1004.1445'
valueset "HEDIS; Telehealth POS": '2.16.840.1.113883.3.464.1004.1460'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Distinct Dates of Telehealth Encounters with Arthritis":
   distinct(((
     (
       /*
       •	A telephone visit (Telephone Visits Value Set) with any diagnosis of arthritis (Arthritis Value Set).
       •	An online assessment (Online Assessments Value Set) with any diagnosis of arthritis (Arthritis Value Set).
       */
       //telephone visits or online assessments
      ((["Encounter, Performed": "HEDIS; Telephone Visits"]
	     union ["Encounter, Performed": "HEDIS; Online Assessments"]
      ) TelephoneOrOnlineEncounters
      with ["HEDIS; Rheumatoid Arthritis"] D
        such that D.claimId = TelephoneOrOnlineEncounters.claimId // not sure this is necessary
      where TelephoneOrOnlineEncounters.relevantPeriod starts during [start of "Measurement Period", 1 month before end of "Measurement Period"]
        and E.placeOfService != 81
        and E.supplemental = false
        and D.placeOfService != 81
        and D.supplemental = false
        //NOTE: not sure if we need to filter by telehealth pos/modifier here as well - leaving be for now
      )

      /*
        Identify outpatient telehealth visits by the presence of
          - a telehealth modifier (Telehealth Modifier Value Set)
          - or the presence of a telehealth POS code (Telehealth POS Value Set)
        associated with the outpatient visit
      */
      //outpatient telehealth
      union (["Encounter, Performed": "HEDIS; Outpatient"] E
        with ["Diagnosis": "HEDIS; Rheumatoid Arthritis"] D
          such that D.claimId = E.claimId // not sure this is necessary
        where E.relevantPeriod during [start of "Measurement Period", 1 month before end of "Measurement Period"]
          and E.supplemental = false
          and (
              //MUST BE either telehealth POS or modifier
              E.placeOfService in "HEDIS; Telehealth POS"
              or E.code.modifier in "HEDIS; Telehealth Modifier"
            )
          and E.placeOfService != 81
          and E.supplemental = false
          and D.placeOfService != 81
          and D.supplemental = false
      )

      ).relevantPeriod) start) date)

/*
  we need to count the DISTINCT DATES of service for the following criteria
*/
define "Distinct Dates of Non-Telehealth Encounters with Rheumatoid Arthritis":
    distinct(((
      ( ["Encounter, Performed": "HEDIS; Outpatient"] E
	      with ["Diagnosis": "HEDIS; Rheumatoid Arthritis"] D
	        such that D.claimId = E.claimId
        where E.relevantPeriod during [start of "Measurement Period", 1 month before end of "Measurement Period"]
          and D.placeOfService != 81
          and E.supplemental = false
          and not E.placeOfService in {81, "HEDIS; Telehealth POS"} //DO NOT INCLUDE telehealth or lab
          and not E.code.modifier in "HEDIS; Telehealth Modifier" //DO NOT INCLUDE telehealth

        /*
          Identify nonacute inpatient discharges with any diagnosis of rheumatoid arthritis on the discharge claim
          with associated nonacute care based on the presence of a nonacute code on the claim
        */
        union ["Encounter, Performed": "HEDIS; Inpatient Stay"] E1
            where E1.relevantPeriod starts during [start of "Measurement Period", 1 month before end of "Measurement Period"]
            with ["Encounter, Performed": "Nonacute Inpatient Stay"] E2
              such that E2.relevantPeriod starts during E1.relevantPeriod
                  such that D.claimId = E.claimId
            with ["Diagnosis": "Rheumatoid Arthritis"] D
              such that D.prevalencePeriod starts during E1.relevantPeriod


      ).relevantPeriod) start) date)

define "Count of Visits with Rheumatoid Arthritis Diagnosis":
    //we only allow a max of ONE telehealth over the period - and we need to make sure it doesn't intersect with non-telehealth
    //we're going to count the # of telehealth encounters REMOVING the non-telehealth encounters - taking the FIRST element and then converting it to a list
    Count(
    	{First("Distinct Dates of Telehealth Encounters with Rheumatoid Arthritis" except "Distinct Dates of Non-Telehealth Encounters with Rheumatoid Arthritis")}
    	union "Distinct Dates of Non-Telehealth Encounters with Rheumatoid Arthritis"
    )

define "HIV":
  ["Diagnosis": "HEDIS; HIV"]
  union ["Diagnosis": "HEDIS; HIV Type 2"]

/* Populations */

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 18
  and "Count of Visits with Rheumatoid Arthritis Diagnosis" >= 2

define "Exclusion: Hospice":
   /*
   * config_link_id: exclusion_required_hospice
   */
   exists("Hospice During Period"("Measurement Period"))

define "Denominator Exclusion: Frailty or Advanced Illness":
  /*
   * config_link_id: exclusion_required_frailty
   */
   AgeInYearsAt(end of "Measurement Period") >= 66
   and (
      "LTI During Period"("Measurement Period")
      or "SNP"
      or ("Advanced Illness"("Measurement Period and Year Prior")
           and ("Frailty: Claim During Period"("Measurement Period")))
   )

define "Denominator Exclusion: HIV":
  /*
   * config_link_id: exclusion_1
   */
  exists("HIV" D
    where D.prevalencePeriod starts before end of "Measurement Period")

define "Denominator Exclusion: Pregnancy":
  /*
   * config_link_id: exclusion_2
   */
  exists(["Diagnosis"; "HEDIS; Pregnancy"] D
    where D.prevalencePeriod overlaps "Measurement Period")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists(["Intervention, Performed": "HEDIS; DMARD"] I
    where I.relevantPeriod starts during "Measurement Period")
  or exists(["Medication, Dispensed": "NCQA; DMARD Medications"] M
    where M.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion: HIV"
  and not "Denominator Exclusion: Pregnancy"
  and not "Numerator Performance Met"
