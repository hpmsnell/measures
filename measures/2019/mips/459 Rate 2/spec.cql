library MIPS_459_RATE_2_2019 version '1'

/*
 *
 * Source: MIPS
 * ID: 459 Rate 2
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

define "Spine Procedure":
  ["Procedure, Performed": "MIPS; Other Spine Procedure"]
  union ["Procedure, Performed": "Able; Other Spine Procedure"]

define "Preoperative Result":
  ["Assessment, Performed": "Able; Back Visual Analog Scale"] A
    with "Denominator Encounter" E
      such that A.authorDateTime on or 3 months or less before start of E.relevantPeriod
    return A.result

define "Postoperative Result":
  ["Assessment, Performed": "Able; Back Visual Analog Scale"] A
    with "Denominator Encounter" E
      such that A.authorDateTime during [6 weeks after start of E.relevantPeriod, 20 weeks after start of E.relevantPeriod]
    return A.result

define "Average Preoperative Result":
  Average("Preoperative Result")

define "Average Postoperative Result":
  Average("Postoperative Result")

/* Populations */

define "Denominator":
  "Denominator Encounter" E
    with ["Assessment, Performed": "Able; Back Visual Analog Scale"] A1
      such that A1.authorDateTime on or 3 months or less before start of E.relevantPeriod
    with ["Assessment, Performed": "Able; Back Visual Analog Scale"] A2
      such that A.authorDateTime during [6 weeks after start of E.relevantPeriod, 20 weeks after start of E.relevantPeriod]
    without "Spine Procedure" P
      such that P.relevantPeriod starts during of E.relevantPeriod
  union "Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: G9941"] P
      such that P.relevantPeriod starts on or 20 weeks or less after start of E.relevantPeriod)
    without "Spine Procedure" P
      such that P.relevantPeriod starts during of E.relevantPeriod

define "Numerator":
  /*
   * config_link_id: numerator
   */
  "Average Postoperative Result" - "Average Preoperative Result"
