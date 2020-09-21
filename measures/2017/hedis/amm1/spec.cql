library HEDIS_AMM1`_2018 version '1'

/*
 *
 * Source: HEDIS
 * ID: AMM1`
 * Year: 2018
 * Version: 2
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS Hospice Service"

// HEDIS value sets

valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; Inpatient Stay"
valueset "HEDIS; AMM Visits"
valueset "HEDIS; AMM Standalone Visits"
valueset "HEDIS; Telephone Visits"
valueset "HEDIS; Major Depression"
valueset "HEDIS; Antidepressant Medications"

// VSAC value sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Medication in Index Period"
  ["Medication, Dispensed": "HEDIS; Antidepressant Medications"] M
    where M.relevantPeriod starts during [8 months before start of "Measurement Period", 8 months before end of "Measurement Period"]

define "First Medication in Index Period":
  First("Medication in Index Period" M
    sort by M.relevantPeriod ASC)

define "Encounter":
  ["Encounter, Performed": "HEDIS: ED"]
  union ["Encounter, Performed": "HEDIS: Inpatient Stay"]
  union ["Encounter, Performed": "HEDIS: AMM Standalone Visits"]
  union ["Encounter, Performed": "HEDIS: Telephone Visits"]
  union ["Encounter, Performed": "HEDIS: AMM Visits"] E
    where E.placeOfService in ['02', '03', '05', '07', '09', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '22', '24', '33', '49', '50', '52', '53', '71', '72']

define "Encounter with Depression Prior to First Medication in Index Period":
  "Encounter" E
    with ["Diagnosis": "HEDIS; Major Depression"] D
      such that D.prevalencePeriod starts during E.relevantPeriod
    with "First Medication in Index Period" M
      such that E.relevantPeriod starts during [60 days before before start of M.relevantPeriod, 60 days before after start of M.relevantPeriod]

define "Medication Prior to First Medication in Index Period":
  ["Medication, Dispensed": "HEDIS; Antidepressant Medications"] M1
    with "First Medication in Index Period" M2
      such that M1.relevantPeriod starts 105 days or less before before start of M.relevantPeriod

define "First Medication Start Date":
  "First Medication in Index Period" M
    return start of M.relevantPeriod

define "Medication Start Date":
  "Medication in Index Period" M
    return start of M.relevantPeriod

define "Medication End Date":
  "Medication in Index Period" M
    return end of M.relevantPeriod

define "Medication End Date or End of Medication Period":
  Lower(["Medication End Date", 114 days after start of "First Medication Start Date"])

define "Medication Duration":
  "Medication End Date or End of Medication Period" - "Medication Start Date"

/* Populations */

define "Denominator":
  AgeInYearsAt(8 months before end of "Measurement Period") >= 18
  and exists("Medication in Index Period")
  and not exists("Hospice" I
    where I.relevantPeriod starts during "Measurement Period")

define "Denominator Exclusion: No Depression":
  /*
   * config_link_id: exclusion_1
   */
  not exists ("Encounter with Depression Prior to First Medication in Index Period")

define "Denominator Exclusion: Prior Medication":
  /*
   * config_link_id: exclusion_2
   */
  exists("Medication Prior to First Medication in Index Period")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  Sum("Medication Duration") >= 84

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion: No Depression"
  and not "Denominator Exclusion: Prior Medication"
  and not "Numerator Performance Met"
