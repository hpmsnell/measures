library MIPS_403_2019 version '1'

/*
 * Source: MIPS
 * ID: 403
 * Year: 2019
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 403 Encounter"
valueset "MIPS; ESRD"
valueset "MIPS; Patient Discontinued from Dialysis"
valueset "MIPS; Performance Met: G9524"
valueset "MIPS; Denominator Exception: G9525"
valueset "MIPS; Performance Not Met: G9526"
valueset "MIPS; MIPS Hospice Service"

// VSAC value sets

valueset "VSAC; Palliative Care"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 403 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true
      and AgeInYearsAt(start of E.relevantPeriod >= 18)
    with ["Diagnosis": "MIPS; ESRD"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Hospice":
  ["Procedure, Performed": "MIPS; Performance Met: G9524"]
  union ["Procedure, Performed": "MIPS; MIPS Hospice Service"]
  union ["Procedure, Performed": "VSAC; Palliative Care"]

// Populations

define "Denominator":
  exists("Denominator Encounter")
  and exists(["Procedure, Performed": "MIPS; Patient Discontinued from Dialysis"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: G9524":
  /*
   * config_link_id: G9524
   */
  exists("Hospice" P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: G9525":
  /*
   * config_link_id: G9525
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9525"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: G9526":
 /*
  * config_link_id: G9526
  */
 not "Numerator Performance Met: G9524"
 and not "Denominator Exception: G9525"
