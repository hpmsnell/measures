library MIPS_268_2020 version '1'

/*
 * Source: MIPS
 * ID: 268
 * Year: 2020
 * Version: 1
 * Author: Patrick Clark
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 268 Encounter"
valueset "MIPS; Epilepsy"
valueset "MIPS; Performance Met: 4340F"
valueset "MIPS; Performance Not Met: 4340F-8P"
valueset "MIPS; Denominator Exclusion: M1016"

// VSAC value sets

valueset "VSAC; Absence of Cervix"

// Able value sets

valueset "Able; Post-Menopausal"
valueset "Able; Female Surgical Sterilization"
valueset "Able; Dyslexia"
valueset "Able; Genetic Neurodevelopmental Disorder"
valueset "Able; Encephalopathy"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 268 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 12
      and not E.code.modifier in {'GQ','GT','95'}
      and not E.placeOfService in {'02'}
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Epilepsy"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

/* POPULATIONS */

define "Denominator":
  "Patient Characteristic Sex" = 'Female'
  and exists("Denominator Encounter")

define "Denominator Exclusion: M1016":
  /*
   * config_link_id: M1016
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exclusion: M1016"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Diagnosis": "VSAC; Absence of Cervix"] D
    where D.prevalencePeriod starts before end of "Measurement Period")
  or exists(["Procedure, Performed": "VSAC; Absence of Cervix"] P
    where P.relevantPeriod starts before end of "Measurement Period")
  or exists(["Diagnosis": "Able; Post-Menopausal"] D
    where D.prevalencePeriod starts before end of "Measurement Period")
  or exists(["Procedure, Performed": "VSAC; Female Surgical Sterilization"] P
    where P.relevantPeriod starts before end of "Measurement Period")
  or exists(["Diagnosis": "Able; Female Surgical Sterilization"] D
    where D.prevalencePeriod starts before end of "Measurement Period")

define "Numerator Performance Met: 4340F":
  /*
   * config_link_id: 4340F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 4340F"] P
    where P.relevantPeriod starts during "Measurement Period")



define "Numerator Performance Not Met: 4340F-8P":
 /*
  * config_link_id: 4340F-8P
  */
 not "Denominator Exclusion: M1016"
 and not "Numerator Performance Met: 4340F"
