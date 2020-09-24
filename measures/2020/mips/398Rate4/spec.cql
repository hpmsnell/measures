library MIPS_398Rate4_2020 version '1'

/*
 * Source: MIPS
 * ID: 398Rate4
 * Year: 2020
 * Version: 1
 * Author: Patrick Clark
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 398 Encounter":
valueset "MIPS; Asthma":
valueset "MIPS; Competing Conditions for Persistent Asthma"
valueset "MIPS; Only Urgent Care Visits M0121":
valueset "MIPS; Hospice Service":
valueset "MIPS; Performance Met: G9521":
valueset "MIPS; MIPS Hospice Service":
valueset "VSAC; Palliative Care":
// Able value sets

valueset "Able; Expired"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Patient Age at Encounter":
  ["Encounter, Performed": "MIPS; MIPS 398 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and AgeInYearsAt(start of E.relevantPeriod) < 50
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Asthma"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod
    with ["Encounter, Performed"] E2
      such that E2.relevantPeriod overlaps E.relevantPeriod

// Populations

define "Denominator":
    "Patient Age at Encounter"

define "Denominator Exclusion: Patient Died"
  /*
   * config_link_id: exclusion_patientdied
   */
  exists(["Diagnosis": "Able; Expired"] D
    where D.prevalencePeriod starts before end of "Measurement Period")


define "Denominator Exclusion: Long Term Care"
    /*
     * config_link_id: exclusion_longterm
     */
      FrailtyLTIShared."Long Term Care Periods During Measurement Period"


define "Denominator Exclusion: Hospice":
  /*
   * config_link_id: exclusion_hospice
   */
  exists(["Procedure, Performed": "MIPS; MIPS Hospice Service"] P
    where P.relevantPeriod starts during "Denominator Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Denominator Period")


define "Denominator Exclusion: Competing Diagnoses"
  /*
  * config_link_id: competing_diagnosis
  */
  exists(["Diagnosis": "MIPS; Competing Conditions for Persistent Asthma"] D
    where D.prevalencePeriod starts before end of "Denominator Period")


define "Denominator Exclusion: Only Urgent Care Visits"
  /*
  * config_link_id: M0121
  */
  exists(["Procedure, Performed": "MIPS; Only Urgent Care Visits M0121" ] P
    where P.relevantPeriod starts during "Denominator Period")

define "Numerator Performance Met: G9521":
  /*
   * config_link_id: G9521
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9521"] P
    where P.relevantPeriod starts during "Measurement Period")


define "Numerator Performance Not Met: G9522":
  /*
   * config_link_id: G9522
   */
  not "Denominator Exclusion: Patient Died"
  and not "Denominator Exclusion: Long Term Care"
  and not "Denominator Exclusion: Hospice"
  and not "Denominator Exclusion: Competing Diagnoses"
  and not "Denominator Exclusion: Only Urgent Care Visits"
  and not "Numerator Performance Met: G9521"
