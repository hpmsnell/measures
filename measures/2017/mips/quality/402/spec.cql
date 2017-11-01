library MIPS_402_2017 version '1'

/*
 * Source: MIPS
 * ID: 402
 * Year: 2017
 * Version: 1
 * Written By: Steve Daniels
 * Reviewed By:
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 402 Encounter"
valueset "MIPS; Performance Met: G9458"
valueset "MIPS; Performance Met: G9459"
valueset "MIPS; Performance Not Met: G9460"

// VSAC Value Sets

valueset "VSAC; Tobacco Non-User": '2.16.840.1.113883.3.526.3.1189'
valueset "VSAC; Tobacco User": '2.16.840.1.113883.3.526.3.1170'
valueset "VSAC; Tobacco Use Cessation Counseling": '2.16.840.1.113883.3.526.3.509'

// Able Value Sets

valueset "Able; Never Tobacco User"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Tobacco Interval": Interval[18 months before end "Measurement Period", end "Measurement Period")

define "Denominator Encounter"
  ["Encounter, Performed": "MIPS; MIPS 402 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 12
        and AgeInYearsAt(start of E.relevantPeriod) < 20
      and E.signingProvider.hasMeasureMembership = true

define "Tobacco User":
  ["Diagnosis": "VSAC; Tobacco User"]
  union ["Assessment, Performed": "VSAC; Tobacco User"]

define "Tobacco Non-User":
  ["Diagnosis": "VSAC; Tobacco Non-User"]
  union ["Assessment, Performed": "VSAC; Tobacco Non-User"]
  union ["Diagnosis": "Able; Never Tobacco User"]
  union ["Assessment, Performed": "Able; Never Tobacco User"]

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: G9458":
  /*
   * config_link_id: G9458
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9458"] P
    where P.relevantPeriod starts during "Measurement Period")
  or (
    exists("Tobacco User" D
      where D.prevalencePeriod starts during "Tobacco Interval")
    and exists(["Intervention, Performed": "VSAC; Tobacco Use Cessation Counseling"] I
      where I.relevantPeriod starts during "Tobacco Interval")
  )

define "Numerator Performance Met: G9459":
  /*
   * config_link_id: G9459
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9459"] P
    where P.relevantPeriod starts during "Measurement Period")
  exists(["Diagnosis": "VSAC; Tobacco Non-User"] D
    where D.prevalencePeriod starts during "Tobacco Interval")

define "Numerator Performance Not Met: G9460":
  /*
   * config_link_id: G9460
   */
   not "Numerator Performance Met: G9458"
   and not "Numerator Performance Met: G9459"
