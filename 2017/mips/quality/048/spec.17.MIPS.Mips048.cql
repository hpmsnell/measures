library MIPS_048_2017 version '1'

/*
 * Source: MIPS
 * ID: 048
 * Year: 2017
 * Version: 1
 * Clinical Lead: Calvin Newman
 * Engineer: TBD
 * Q/A Reviewer: TBD
 *
 * Status = Prototype
 * Clinical Validation:
 *
  */

using QDM

// Able Custom Value Sets

valueset "MIPS; MIPS 049 Encounter"
valueset "MIPS; MIPS Hospice Service"
valueset "MIPS; Performance Met: 1090F"
valueset "MIPS; Performance Not Met: 1090F-8P"

// VSAC Value Sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Patient Age at Encounter":
  ["Encounter, Performed": "MIPS; MIPS 048 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 65
      and E.signingProvider.pqrsProvider = true

define "Denominator":
  exists("Denominator Encounter")

define "Denominator Exclusion":
  /*
   * config_link_id: denominator_exclusion
   */
  exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Measurement Period")
  or exists(["Intervention, Performed": "MIPS; MIPS Hospice Service"] I
    where I.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: 1090F":
  /*
   * config_link_id: 1090F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 1090F"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Assessment, Performed": "Able; Urinary Incontinence Assessment"] P
    where P.authorDateTime during "Measurement Period")

define "Numerator Performance Not Met: 1090F-8P":
  /*
   * config_link_id: 1090F-8P
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met: 1090F"
