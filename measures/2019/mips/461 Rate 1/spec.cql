library MIPS_461_RATE_1_2019 version '1'

/*
 *
 * Source: MIPS
 * ID: 461 Rate 1
 * Year: 2019
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 461 Procedure"
valueset "MIPS; Herniated Disc"
valueset "MIPS; Other Spine Procedure"
valueset "MIPS; Performance Met: G9947"
valueset "MIPS; Performance Not Met: G9949"

// Able value sets

valueset "Able; Other Spine Procedure"
valueset "Able; Leg Visual Analog Scale"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 461 Procedure"] E
    where E.relevantPeriod starts during [1 year before start of "Measurement Period", 1 year before end of "Measurement Period"]
      and AgeInYearsAt(1 year before start of "Measurement Period") >= 18
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Herniated Disc"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Leg Visual Analog Scale Exists":
  exists(["Procedure, Performed": "Able; Leg Visual Analog Scale"] A
    with "Denominator Encounter" E
      such that A.authorDateTime on or 3 months or less before start of E.relevantPeriod)
  and exists(["Procedure, Performed": "Able; Leg Visual Analog Scale"] A
    with "Denominator Encounter" E
      such that A.authorDateTime during [6 weeks after start of E.relevantPeriod, 20 weeks after start of E.relevantPeriod])

define "Denominator":
  "Denominator Encounter"

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Procedure, Performed": "MIPS; Other Spine Procedure"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during of E.relevantPeriod)
  exists(["Procedure, Performed": "Able; Other Spine Procedure"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during of E.relevantPeriod)

define "Numerator Performance Met: G9947":
  /*
   * config_link_id: G9947
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9947"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 20 weeks or less after start of E.relevantPeriod)
  or "Leg Visual Analog Scale Exists"

define "Numerator Performance Not Met: G9949":
  /*
   * config_link_id: G9949
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met: G9947"
