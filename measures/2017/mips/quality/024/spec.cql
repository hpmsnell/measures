library MIPS_024_2017 version '1'

/*
 * Source: MIPS
 * ID: 024
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 024 Encounter"
valueset "MIPS; MIPS 024 Procedure"
valueset "MIPS; Fracture"
valueset "MIPS; MIPS Hospice Service"
valueset "MIPS; Performance Met: 5015F"
valueset "MIPS; Performance Not Met: 5015F-8P"

// VSAC value Sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Encounter or Procedure":
  ["Encounter, Performed": "MIPS; MIPS 024 Encounter"]
  union ["Procedure, Performed": "MIPS; MIPS 024 Procedure"]

define "Denominator Encounter":
  "Denominator Encounter or Procedure" E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 50
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Fracture"] D
      such that D.prevalencePeriod starts during E.relevantPeriod

define "Denominator":
  "Denominator Encounter"

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion
   */
  exists(["Intervention, Performed": "MIPS; MIPS Hospice Service"] I
    where I.relevantPeriod starts during "Denominator Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Denominator Period")

define "Numerator Performance Met: 5015F":
  /*
   * config_link_id: 5015F
   */
  "Denominator Encounter" E
    with ["Encounter, Performed": "MIPS; Performance Met: 5015F"] P
      such that P.relevantPeriod starts at or 7 or days or less after start of E.relevantPeriod

define "Numerator Performance Not Met: 5015F-8P":
  /*
   * config_link_id: 5015F-8P
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met: 5015F"
