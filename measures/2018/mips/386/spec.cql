library MIPS_386_2017 version '1'

/*
 * Source: MIPS
 * ID: 386
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// Able Custom Value Sets

valueset "MIPS; MIPS 386 Encounter"
valueset "MIPS; Amyotrophic Lateral Sclerosis"
valueset "MIPS; Performance Met: G9380"
valueset "MIPS; Performance Not Met: G9382"

// VSAC Value Sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'

// Able Value Sets

valueset "Able; End of Life Planning"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 386 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and not E.code.modifier in {'GQ','GT','95'}
      and not E.placeOfService in {'02'}
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Amyotrophic Lateral Sclerosis"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Hospice":
  ["Intervention, Performed": "MIPS; MIPS Hospice Service"]
  union ["Intervention, Performed": "VSAC; Palliative Care"]

define "End of Life Planning":
  ["Procedure, Performed": "MIPS; Performance Met: G9380"]
  union ["Procedure, Performed": "Able; End of Life Planning"]

/* Populations */

define "Denominator":
  exists("Denominator Encounter")

define "Denominator Exclusion":
  /*
   * config_link_id: G9380
   */
  exists("Hospice" I
    where I.authorDateTime during "Measurement Period")

define "Numerator Performance Met: G9380":
  /*
   * config_link_id: G9380
   */
  exists("End of Life Planning" P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: G9382":
  /*
   * config_link_id: G9382
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met: G9380"
