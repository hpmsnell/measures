library MIPS_421_2020 version '1'

/*
 *
 * Source: MIPS
 * ID: 421
 * Year: 2020
 * Version: 1
 * Author: Patrick Clark
 *
  */

using QDM

include "../shared/frailty_lti_shared" version '1' called FrailtyLTIShared

// MIPS value sets

valueset "MIPS; MIPS 421 Procedure: 37191"
valueset "MIPS; MIPS 421 Intent For Removal: G9539"
valueset "MIPS; MIPS 421 Patient Alive 3 Months Post Procedure: G95040"
valueset "MIPS; Performance Met: IVF Removed"
valueset "MIPS; Performance Met: G9541"
valueset "MIPS; Performance Met: G9542"
valueset "MIPS; Performance Met: G9543"
valueset "MIPS; Performance Not Met: G9544"

parameter "Measurement Period" Interval<DateTime>

context Patient

/* Populations */

define "Denominator":
  ["Procedure, Performed": "MIPS; MIPS 421 Procedure: 37191"] P1
      where P1.relevantPeriod starts during Interval[start of "Measurement Period", 3 months before end "Measurement Period"]
      with ["Procedure, Performed": "MIPS; MIPS 421 Intent For Removal: G9539"] P2
          such that P2.relevantPeriod overlaps P1.relevantPeriod
      with ["Procedure, Performed": "MIPS; MIPS 421 Patient Alive 3 Months Post Procedure: G95040"] P3
          such that P3.prevalencePeriod overlaps P1.relevantPeriod

define "Numerator Performance Met: G9541":
  /*
   * config_link_id: G9541
   */
  exists("Denominator Encounter" E
     with ["Procedure, Performed": "MIPS; Performance Met: G9541"] P
       such that P.relevantPeriod starts before 3 months after start of E.relevantPeriod)
  or exists ("Denominator Encounter"E
      with ["Procedure, Performed": "MIPS; Performance Met: IVF Removed"] P1
        such that P.relevantPeriod starts before 3 months after start of E.relevantPeriod)


define "Numerator Performance Met: G9542":
 /*
  * config_link_id: G9542
  */
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: G9542"] P
      such that P.relevantPeriod starts before 3 months after start of E.relevantPeriod)

define "Numerator Performance Met: G9543":
 /*
  * config_link_id: G9543
  */
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: G9543"] P
      such that P.relevantPeriod starts before 3 months after start of E.relevantPeriod)


define "Numerator Performance Not Met: G9544":
  /*
   * config_link_id: G9544
   */
  not "Numerator Performance Met: G9541"
  and not "Numerator Performance Met: G9542"
  and not "Numerator Performance Met: G9543"
