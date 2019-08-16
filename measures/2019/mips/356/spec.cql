library MIPS_356_2019 version '1'

/*
 * Source: MIPS
 * ID: 356
 * Year: 2019
 * Version: 2
 * Written By: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 356 Procedure"
valueset "MIPS; Performance Met: G9310"
valueset "MIPS; Performance Not Met: G9309"

// VSAC value sets

valueset "VSAC; Hospital Inpatient Visit - Initial": '2.16.840.1.113883.3.464.1003.101.12.1004'
valueset "VSAC; Hospital Inpatient Visit - Subsequent": '2.16.840.1.113883.3.464.1003.101.11.1025'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Encounter Interval":
  Interval[start of "Measurement Period", end of "Measurement Period" - 1 month]

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 356 Procedure"] P
    where P.relevantPeriod starts during "Encounter Interval"
      and P.code.modifier not in ['51', '80']
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true

define "Readmission":
  ["Procedure, Performed": "MIPS; Performance Met: G9310"]
  union ["Encounter, Performed": "VSAC; Hospital Inpatient Visit - Initial"]
  union ["Encounter, Performed": "VSAC; Hospital Inpatient Visit - Subsequent"]

define "Denominator":
  "Denominator Procedure"

define "Numerator Performance Met: G9310":
  /*
   * config_link_id: G9310
   */
  exists("Readmission" E
    where not E.code.modifier in ['24','57']
    with "Denominator Procedure" P
      where E.relevantPeriod starts during [2 days after start of P.relevantPeriod, 30 days after start of P.relevantPeriod])

define "Numerator Performance Not Met: G9309":
  /*
   * config_link_id: G9309
   */
   not "Numerator Performance Met: G9310"
