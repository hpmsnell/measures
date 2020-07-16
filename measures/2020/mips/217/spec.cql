library MIPS_217_2020 version '1'

/*
 *
 * Source: MIPS
 * ID: 217
 * Rate: 1
 * Year: 2020
 * Version: 1
 * Written by: Patrick Clark
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 217 Encounter"
valueset "MIPS; MIPS 217 Knee Impairment Functional Deficit"
valueset "MIPS; MIPS 217 Discharge Documented: M1009"
valueset "MIPS; MIPS 217 Neuro Diagnosis M1107"
valueset "MIPS; MIPS 217 Patient Inability G9727"
valueset "MIPS; Performance Met: G8647"
valueset "MIPS; Performance Not Met: G8648"
valueset "MIPS; Denominator Exception: G9726"
valueset "MIPS; Denominator Exception: M1108"
valueset "MIPS; Denominator Exception: M1109"
valueset "MIPS; Denominator Exception: M1110"
valueset "MIPS; Denominator Exception: G9726"
valueset "MIPS; Performance Not Met: G8650"

parameter "Measurement Period" Interval<DateTime>

context Patient


define "Denominator Episode":
  ["Encounter, Performed": "MIPS; MIPS 217 Discharge Documented: M1009"] E1
    where E1.relevantPeriod starts during "Measurement Period"
      and  E1.signingProvider.hasMeasureMembership = true
    with ["Encounter, Performed": "MIPS; MIPS 217 Encounter"] E2
      where E2.relevantPeriod starts during "Measurement Period"
        and E2.relevantPeriod starts on or before start of E1.relevantPeriod
        and AgeInYearsAt(start of E1.relevantPeriod) >= 14
    with ["Diagnosis": "MIPS; MIPS 217 Knee Impairment Functional Deficit"] D
      such that D.prevalencePeriod overlaps E2.relevantPeriod


// Populations

define "Denominator":

  "Denominator Episode"

define "Denominator Exclusion: Patient Diagnosis of Neuro Condition M1107":
  // config_link_id: M1107
  exists("Denominator Episode" E

    with ["Procedure, Performed": "MIPS; MIPS 217 Neuro Diagnosis M1107"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Denominator Exclusion: Patient Inability G9727":

  // config_link_id: G9727
  exists("Denominator Episode" E
    with ["Procedure, Performed": "MIPS; MIPS 217 Patient Inability G9727"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Met: G8647":
  // config_link_id: G8647

  exists("Denominator Episode" E
    with ["Procedure, Performed": "MIPS; Performance Met: G8647"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: G8648":
  // config_link_id: G8648

  exists("Denominator Episode" E
    with ["Procedure, Performed": "MIPS; Performance Not Met: G8648"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Denominator Exception: Care Not Indicated M1108":
  // config_link_id: M1108

  exists("Denominator Episode" E
    with ["Procedure, Performed": "MIPS; Denominator Exception: M1108"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Denominator Exception: Patient Discharged Medical Event M1109":
  // config_link_id: M1109
  exists("Denominator Episode" E
    with ["Procedure, Performed": "MIPS; Denominator Exception: M1109"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Denominator Exception: Patient Self Discharge M1110":
  // config_link_id: M1110

  exists("Denominator Episode" E
    with ["Procedure, Performed": "MIPS; Denominator Exception: M1110"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Denominator Exception: Patient Refused G9726":
  // config_link_id: G9726
  exists("Denominator Episode" E
    with ["Procedure, Performed": "MIPS; Denominator Exception: G9726"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: G8650":
  // config_link_id: G8650
  not "Denominator Exclusion: Patient Diagnosis of Neuro Condition M1107"
  and not "Denominator Exclusion: Patient Inability G9727"
  and not "Numerator Performance Not Met: G8648"
  and not "Denominator Exception: Care Not Indicated M1108"
  and not "Denominator Exception: Patient Discharged Medical Event M1109"
  and not "Denominator Exception: Patient Self Discharge M1110"
  and not "Denominator Exception: Patient Refused G9726"
