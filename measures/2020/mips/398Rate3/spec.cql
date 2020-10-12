library MIPS_398Rate3_2020 version '1'

/*
 * Source: MIPS
 * ID: 398Rate3
 * Year: 2020
 * Version: 1
 * Author: Patrick Clark
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 398 Encounter":
valueset "MIPS; Asthma":
valueset "MIPS; MIPS 398 Competing Conditions for Persistent Asthma"
valueset "MIPS; Only Urgent Care Visits M0121":
valueset "MIPS; Hospice Service":
valueset "MIPS; Performance Met: G9432":
valueset "MIPS; Performance Met: G9521":
valueset "MIPS; MIPS Hospice Service":
valueset "VSAC; Palliative Care Encounter":
// Able value sets

valueset "Able; Expired"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 398 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and AgeInYearsAt(start of E.relevantPeriod) < 50
      and E.signingProvider.hasMeasureMembership = true

// Populations

define "Denominator":
    exists("Denominator Encounter")
    and exists(["Diagnosis": "MIPS; Asthma"] D
      where D.prevalencePeriod overlaps "Measurement Period"
        or D.prevalencePeriod starts during [1 year before start of "Measurement Period", end of "Measurement Period"])

define "Denominator Exclusion: Patient Died"
  /*
   * config_link_id: exclusion_patientdied
   */
  exists(["Diagnosis": "Able; Expired"] D
    where D.prevalencePeriod starts on or before end of "Measurement Period")


define "Denominator Exclusion: Long Term Care"
  /*
   * config_link_id: exclusion_longterm
   */
      exists (FrailtyLTIShared."Long Term Care Periods During Measurement Period")


define "Denominator Exclusion: Hospice":
  /*
   * config_link_id: exclusion_hospice
   */
  exists(["Procedure, Performed": "MIPS; MIPS Hospice Service"] P
    where P.relevantPeriod starts during "Measurement Period")
  and exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Measurement Period")


define "Denominator Exclusion: Competing Diagnoses"
  /*
  * config_link_id: competing_diagnosis
  */
  exists(["Diagnosis": "MIPS; MIPS 398 Competing Conditions for Persistent Asthma"] D
    where D.prevalencePeriod starts on or before end of "Measurement Period")


define "Denominator Exclusion: Only Urgent Care Visits"
  /*
  * config_link_id: M0121
  */
  exists(["Procedure, Performed": "MIPS; Only Urgent Care Visits M0121" ] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: G9521_G9432":
  /*
   * config_link_id: G9521_G9432
   */
   exists(["Procedure, Performed": "MIPS; Performance Met: G9521"] P
     where P.relevantPeriod starts during "Measurement Period")
   or exists(["Procedure, Performed": "MIPS; Performance Met: G9432"] P
         where P.relevantPeriod starts during "Measurement Period")


define "Numerator Performance Not Met: G9434":
  /*
   * config_link_id: G9434
   */
  not "Denominator Exclusion: Patient Died"
  and not "Denominator Exclusion: Long Term Care"
  and not "Denominator Exclusion: Hospice"
  and not "Denominator Exclusion: Competing Diagnoses"
  and not "Denominator Exclusion: Only Urgent Care Visits"
  and not "Numerator Performance Met: G9521_G9432"
