library HEDIS_AMM1_2019 version '1'

/*
 *
 * Source: HEDIS
 * ID: AMM1`
 * Year: 2019
 * Version: 1
 * Author: CDQS
 *
  */

using QDM

include "../shared/hedis_shared" version '1' called HedisShared

// HEDIS value sets

valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; ED POS": '2.16.840.1.113883.3.464.1004.1087'
valueset "HEDIS; Nonacute Inpatient": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; Community Mental Health Center POS": '2.16.840.1.113883.3.464.1004.1484'
valueset "HEDIS; Electroconvulsive Therapy": '2.16.840.1.113883.3.464.1004.1294'
valueset "HEDIS; Hospice Enconter": '2.16.840.1.113883.3.464.1004.1761'
valueset "HEDIS; Hospice Intervention": '2.16.840.1.113883.3.464.1004.1762'
valueset "HEDIS; Inpatient Stay": '2.16.840.1.113883.3.464.1004.1395'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'
valueset "HEDIS; Outpatient POS": '2.16.840.1.113883.3.464.1004.1443'
valueset "HEDIS; Partial Hospitalization or Intensive Outpatient": '2.16.840.1.113883.3.464.1004.1492'
valueset "HEDIS; Partial Hospitalization POS": '2.16.840.1.113883.3.464.1004.1491'
valueset "HEDIS; Telehealth POS": '2.16.840.1.113883.3.464.1004.1460'
valueset "HEDIS; Telephone Visits": '2.16.840.1.113883.3.464.1004.1246'
valueset "HEDIS; Transcranial Magnetic Stimulation": '2.16.840.1.113883.3.464.1004.1486'
valueset "HEDIS; Visit Setting Unspecified": '2.16.840.1.113883.3.464.1004.1493'
valueset "HEDIS; BH Outpatient": '2.16.840.1.113883.3.464.1004.1481'
valueset "HEDIS; Major Depression": '2.16.840.1.113883.3.464.1004.1166'
valueset "HEDIS; Acute Inpatient": '2.16.840.1.113883.3.464.1004.1810'

// NCQA medication list value sets

valueset "NCQA; Antidepressant Medications": ''

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Medication in Index Period":
  ["Medication, Dispensed": "NCQA; Antidepressant Medications"] Medication
    where Medication.relevantDatetime starts 8 months or less before start of "Measurement Period"
      or Medication.relevantDatetime starts 4 months or less after start of "Measurement Period"

define "First Medication in Index Period":
  First("Medication in Index Period" FirstDispensed
    sort by FirstDispensed.relevantDatetime
  )

define "Encounter":
  ["Encounter, Performed": "HEDIS; ED"]
  union ["Encounter, Performed": "HEDIS; Inpatient Stay"]
  union ["Encounter, Performed": "HEDIS; Acute Inpatient"]
  union ["Encounter, Performed": "HEDIS; Nonacute Inpatient"]
  union ["Encounter, Performed": "HEDIS; Visit Setting Unspecified"] VisitUnspec
    where VisitUnspec.placeOfService in "HEDIS; Outpatient POS"
      union "HEDIS; Partial Hospitalization POS"
      union "HEDIS; Community Mental Health Center POS"
      union "HEDIS; Telehealth POS"
      union "HEDIS; ED POS"
  union ["Encounter, Performed": "HEDIS; BH Outpatient"]
  union ["Encounter, Performed": "HEDIS; Partial Hospitalization or Intensive Outpatient"]
  union ["Encounter, Performed": "HEDIS; Electroconvulsive Therapy"]
  union ["Encounter, Performed": "HEDIS; Transcranial Magnetic Stimulation"]
  union ["Encounter, Performed": "HEDIS; Telephone Visits"]

define "Encounter with Depression Prior to First Medication in Index Period":
  "Encounter" E
    with ["Diagnosis": "HEDIS; Major Depression"] D
      such that D.prevalencePeriod starts during E.relevantPeriod
    with "First Medication in Index Period" MedIndex
      such that E.relevantPeriod starts 60 days or less before MedIndex.relevantDatetime - 60 days
        or E.relevantPeriod starts 60 days or less after MedIndex.relevantDatetime + 60 days

define "Medication Prior to First Medication in Index Period":
  ["Medication, Dispensed": "NCQA; Antidepressant Medications"] M1
    with "First Medication in Index Period" M2
      such that M1.relevantPeriod starts 105 days or less before start of M2.relevantPeriod

define "Antidepressant within 114 Days":
//let means that you are doing an interim calculation starting with the first medication in the index period (is the earlier of date discontinued or dispensed date + 114 - date medication was dispensed to patient);
//There may be multiple medications in the record so if they are in the NCQA medication VS, you'll return all of the qualifying antidepressant medication relevant periods which started from index period through 114 days.
//e.g. would return the following relevantPeriods: First Index medication 01/01/2019 - 02/29/2019 + new medication 03/16/2019-4/16/20

  ["Medication, Active": "NCQA; Antidepressant Medications"] ActiveAntidepressant
    let FirstDispensed: "First Medication in Index Period"
    where ActiveAntidepressant.relevantPeriod starts 114 days or less on or after day of FirstDispensed.relevantDatetime
    return ActiveAntidepressant.relevantPeriod
      intersect Interval[FirstDispensed.relevantDatetime, FirstDispensed.relevantDatetime + 114 days]

define "Cumulative Medication Duration Greater than or Equal to 84 Days":
//CMD = Sum of each calculated interval returned based on relevantPeriod in "Antidepressant within 114 Days"
//e.g., First Index medication 01/01/2019 - 02/29/2019 + refill 03/16/2019-4/16/20, this example would = 91days and should return true

  "Cumulative Medication Duration"("Antidepressant within 114 Days")>= 84

/* Populations */

define "Denominator":
  AgeInYearsAt(end of "Measurement Period" - 8 months) >= 18
  and exists("Medication in Index Period")

define "Exclusion: Hospice":
	   /*
	   * config_link_id: exclusion_required_hospice
	   */
	   exists("Hospice During Period"("Measurement Period"))

define "Denominator Exclusion: No Depression":
  /*
   * config_link_id: exclusion_required_depression
   */
  not exists ("Encounter with Depression Prior to First Medication in Index Period")

define "Denominator Exclusion: Prior Medication":
  /*
   * config_link_id: exclusion_required_medication
   */
  exists("Medication Prior to First Medication in Index Period")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists("Cumulative Medication Duration Greater than or Equal to 84 Days")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion: No Depression"
  and not "Denominator Exclusion: Prior Medication"
  and not "Numerator Performance Met"
