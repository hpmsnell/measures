library MIPS_408_2017 version '1'

/*
 * Source: MIPS
 * ID: 408
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 408 Encounter"
valueset "MIPS; Opiates Prescribed for Longer than Six Weeks"
valueset "MIPS; Performance Met: G9562"
valueset "MIPS; Performance Not Met: G9563"

// VSAC Value Sets

valueset "VSAC; Opioids used for pain control": '1.3.6.1.4.1.6997.4.1.2.234.999.3.1'
valueset "VSAC; Functional Status Assessment for Knee Replacement": '2.16.840.1.113883.3.464.1003.118.11.1040'
valueset "VSAC; Functional Status Assessment for Hip Replacement": '2.16.840.1.113883.3.464.1003.118.11.1039'
valueset "VSAC; Standardized Pain Assessment Tool": '2.16.840.1.113883.3.526.3.1028'
valueset "VSAC; Pain Assessments": '2.16.840.1.113762.1.4.1047.152'

parameter "Measurement Period" Interval<DateTime>
parameter "Opioid Period" Interval[start of "Measurement Period", 90 days before end of "Measurement Period"]

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 408 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.pqrsProvider = true

define "Opioid":
  ["Medication, Order": "Opioids used for pain control"] M
    where M.relevantPeriod starts during "Measurement Period"

define "Opioid Procedure":
  ["Procedure Performed": "Opiates Prescribed for Longer than Six Weeks"] P
    where P. relevantPeriod starts during "Opioid Period"

define "Start of Opioid Prescription":
  "Opioid" M
    sort by start of M.relevantPeriod ASC
    return start of M.relevantPeriod

define "Duration of Opioid Prescription":
  sum("Opioid" M return M.days_supplied)

define "End of Opioid Prescription":
  "Duration of Opioid Prescription" after "Start of Opioid Prescription"

parameter "Opioid Precription" Interval["Start of Opioid Prescription", "End of Opioid Prescription"]

define "Functional Status Assessment":
  ["Assessment, Performed": "VSAC; Functional Status Assessment for Knee Replacement"]
  union ["Assessment, Performed": "VSAC; Functional Status Assessment for Hip Replacement"]

define "Pain Assessment":
  ["Assessment, Performed": "VSAC; Standardized Pain Assessment Tool"]
  union ["Assessment, Performed": "VSAC; Pain Assessments"]

define "Functional Status Assessment During Opioid Prescription":
  "Functional Status Assessment" A
    where A.authorDateTime during "Opioid Prescription"

define "Pain Assessment During Opioid Prescription":
  "Pain Assessment" A
    where A.authorDateTime during "Opioid Prescription"

define "Expected "

define "Denominator":
  exists("Denominator Encounter")
  and (
    "Duration of Opioid Prescription" > 42
    or exists("Opioid Procedure")
  )

define "Numerator Performance Met: G9562":
  /*
   * config_link_id: G9562
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9562"] P
    where P.relevantPeriod starts during "Measurement Period")
  or (
    count("Functional Status Assessment During Opioid Prescription") >= RoundDown("Duration of Opioid Prescription"/90)
    and count("Pain Assessment During Opioid Prescription") >= RoundDown("Duration of Opioid Prescription"/90)
  )

define "Numerator Performance Not Met: G9563":
  /*
   * config_link_id: G9563
   */
  not "Numerator Performance Met: G9562"
