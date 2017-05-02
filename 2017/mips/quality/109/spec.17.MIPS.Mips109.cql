library MIPS_109_2017 version '1'

/*
 * Source: MIPS
 * ID: 109
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// Able Custom Value Sets

valueset "MIPS; MIPS 109 Encounter"
valueset "MIPS; Osteoarthritis"
valueset "MIPS; Performance Met: 1006F"
valueset "MIPS; Performance Not Met: 1006F-8P"

// VSAC Value Sets

valueset "VSAC; Functional Status Assessment for Knee Replacement": '2.16.840.1.113883.3.464.1003.118.11.1040'
valueset "VSAC; Functional Status Assessment for Hip Replacement": '2.16.840.1.113883.3.464.1003.118.11.1039'
valueset "VSAC; Standardized Pain Assessment Tool": '2.16.840.1.113883.3.526.3.1028'
valueset "VSAC; Pain Assessments": '2.16.840.1.113762.1.4.1047.152'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 109 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 21
      and E.signingProvider.pqrsProvider = true
    with ["Diagnosis": "MIPS; Osteoarthritis"] D
      such that D.prevalencePeriod starts during E.relevantPeriod

define "Functional Status Assessment":
  ["Assessment, Performed": "VSAC; Functional Status Assessment for Knee Replacement"]
  union ["Assessment, Performed": "VSAC; Functional Status Assessment for Hip Replacement"]

define "Pain Assessment":
  ["Assessment, Performed": "VSAC; Standardized Pain Assessment Tool"]
  union ["Assessment, Performed": "VSAC; Pain Assessments"]

define "Denominator":
  "Denominator Encounter"

define "Numerator Performance Met: 1006F":
  /*
   * config_link_id: 1006F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 1006F"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)
  or (
    exists("Pain Assessment" A
      with "Denominator Encounter" E
        such that A.relevantPeriod starts during E.relevantPeriod)
    and exists("Functional Status Assessment" A
      with "Denominator Encounter" E
        such that A.relevantPeriod starts during E.relevantPeriod)
  )

define "Numerator Performance Not Met: 1006F-8P":
  /*
   * config_link_id: 1006F-8P
   */
  not "Numerator Performance Met: 1006F"
