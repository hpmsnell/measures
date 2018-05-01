library MIPS_051_2017 version '1'

/*
 * Source: MIPS
 * ID: 051
 * Year: 2017
 * Version: 1
 * Written By: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 051 Encounter"
valueset "MIPS; COPD"
valueset "MIPS; Performance Met: 3023F"
valueset "MIPS; Denominator Exception: 3023F-1P"
valueset "MIPS; Denominator Exception: 3023F-2P"
valueset "MIPS; Denominator Exception: 3023F-3P"
valueset "MIPS; Performance Not Met: 3023F-8P"

// Able Value Sets

valueset "Able; Spirometry"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 051 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {GQ, GT}
    with ["Diagnosis": "MIPS; COPD"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: 3023F":
  /*
   * config_link_id: 3023F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 3023F"] P
    where P.relevantPeriod starts before end of "Measurement Period")
  or exists(["Procedure, Performed": "Able; Spirometry"] P
    where P.relevantPeriod starts before end of "Measurement Period")

define "Denominator Exception: 3023F-1P":
  /*
   * config_link_id: 3023F-1P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 3023F-1P"] P
    with ["Encounter, Performed": "MIPS; MIPS 051 Encounter"] E
      such that P.relevantPeriod starts during E.relevantPeriod

define "Denominator Exception: 3023F-2P":
  /*
   * config_link_id: 3023F-2P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 3023F-2P"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod

define "Denominator Exception: 3023F-3P":
  /*
   * config_link_id: 3023F-3P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 3023F-3P"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Not Met: 3023F-8P":
  /*
   * config_link_id: 3023F-8P
   */
   not "Numerator Performance Met: 3023F"
   and not "Denominator Exception: 3023F-1P"
   and not "Denominator Exception: 3023F-2P"
   and not "Denominator Exception: 3023F-3P"
