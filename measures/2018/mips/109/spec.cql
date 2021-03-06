library MIPS_109_2018 version '1'

/*
 * Source: MIPS
 * ID: 109
 * Year: 2018
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 109 Encounter"
valueset "MIPS; Osteoarthritis"
valueset "MIPS; Performance Met: 1006F"
valueset "MIPS; Performance Not Met: 1006F-8P"

// VSAC Value Sets

valueset "VSAC; Functional Status Assessment for Knee Replacement": '2.16.840.1.113883.3.464.1003.118.11.1040'
valueset "VSAC; Functional Status Assessment for Hip Replacement": '2.16.840.1.113883.3.464.1003.118.11.1039'
valueset "VSAC; Standardized Pain Assessment Tool": '2.16.840.1.113883.3.526.3.1028'
valueset "VSAC; Pain Assessments": '2.16.840.1.113762.1.4.1047.152'

// Able Value Sets

valueset "Able; Functional Status Assessment"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 109 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 21
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Osteoarthritis"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Functional Status and Pain Assessment":
  ["Procedure, Performed": "MIPS; Performance Met: 1006F"]
  union ["Assessment, Performed": "VSAC; Functional Status Assessment for Knee Replacement"]
  union ["Assessment, Performed": "VSAC; Functional Status Assessment for Hip Replacement"]

define "Pain Assessment":
  ["Assessment, Performed": "VSAC; Standardized Pain Assessment Tool"]
  union ["Assessment, Performed": "VSAC; Pain Assessments"]

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: 1006F":
  /*
   * config_link_id: 1006F
   */
  exists("Functional Status and Pain Assessment" A
    where A.authorDateTime starts during "Measurement Period")
  or (
    exists("Pain Assessment" A
      where A.authorDateTime starts during "Measurement Period")
    and exists(["Assessment, Performed": "Able; Functional Status Assessment"] A
      where A.authorDateTime starts during "Measurement Period")
  )

define "Numerator Performance Not Met: 1006F-8P":
  /*
   * config_link_id: 1006F-8P
   */
  not "Numerator Performance Met: 1006F"
