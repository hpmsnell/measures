library MIPS_459_RATE_1_2019 version '1'

/*
 *
 * Source: MIPS
 * ID: 459 Rate 1
 * Year: 2019
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 459 Procedure"
valueset "MIPS; Herniated Disc"
valueset "MIPS; Other Spine Procedure"
valueset "MIPS; Performance Met: G9941"
valueset "MIPS; Performance Not Met: G9943"

// Able value sets

valueset "Able; Other Spine Procedure"
valueset "Able; Back Visual Analog Scale"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 459 Procedure"] E
    where E.relevantPeriod starts during [1 year before start of "Measurement Period", 1 year before end of "Measurement Period"]
      and AgeInYearsAt(1 year before start of "Measurement Period") >= 18
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Herniated Disc"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Back Visual Analog Scale Exists":
  exists(["Procedure, Performed": "Able; Back Visual Analog Scale"] A
    with "Denominator Encounter" E
      such that A.authorDateTime on or 3 months or less before start of E.relevantPeriod)
  and exists(["Procedure, Performed": "Able; Back Visual Analog Scale"] A
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

define "Numerator Performance Met: G9941":
  /*
   * config_link_id: G9941
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9941"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 20 weeks or less after start of E.relevantPeriod)
  or "Back Visual Analog Scale Exists"

define "Numerator Performance Not Met: G9943":
  /*
   * config_link_id: G9943
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met: G9941"
