library MIPS_166_2017 version '1'

/*
 * Source: MIPS
 * ID: 166
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 166 Procedure"
valueset "MIPS; Performance Met: G8573"
valueset "MIPS; Performance Not Met: G8574"

// VSAC value sets

valueset "VSAC; Cerebrovascular disease, Stroke, TIA": '2.16.840.1.113762.1.4.1047.44'

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 166 Procedure"] E
    where AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.relevantPeriod starts during "Denominator Period"
      and E.signingProvider.hasMeasureMembership = true

define "Denominator":
  "Denominator Procedure"

define "Numerator Performance Met: G8573":
  /*
   * config_link_id: G8573
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8573"] P1
    with "Denominator Procedure" P2
      such that P1.relevantPeriod starts on or 1 day or less after start of P2.relevantPeriod)
  or exists(["Diagnosis"; "VSAC; Cerebrovascular disease, Stroke, TIA"] D
    with ["Denominator Procedure"] P
      such that D.prevalencePeriod starts on or 1 day or less after start of P.relevantPeriod)

define "Numerator Performance Not Met: G8574":
  /*
   * config_link_id: G8574
   */
  not "Numerator Performance Met: G8573"
