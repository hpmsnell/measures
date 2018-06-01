library MIPS_110_Rate1_2018 version '1'

/*
 * Source: MIPS
 * ID: 110 Rate 1
 * Year: 2018
 * Written By: Steve Daniels
 */

using QDM

// Able custom value sets

valueset "MIPS; MIPS 110 Encounter"
valueset "MIPS; Denominator Exception: G8483"
valueset "MIPS; Performance Met: G8482"
valueset "MIPS; Performance Not Met: G8484"

// VSAC value sets
valueset "VSAC; Allergy to Eggs" '2.16.840.1.113883.3.526.3.1253'
valueset "VSAC; Allergy to Influenza Vaccine" '2.16.840.1.113883.3.526.3.1256'
valueset "VSAC; Intolerance to Influenza Vaccine" '2.16.840.1.113883.3.526.3.1257'
valueset "VSAC; Influenza Vaccination" '2.16.840.1.113883.3.526.3.402'
valueset "VSAC; Influenza Vaccine" '2.16.840.1.113883.3.526.2.1351'
valueset "VSAC; Previous Receipt of Influenza Vaccine" '2.16.840.1.113883.3.526.3.1185'
valueset "VSAC; Influenza Vaccination Declined" '2.16.840.1.113883.3.526.3.1255'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; 110 Encounter"] E
    where E.relevantPeriod starts during [start of "Measurement Period", 3 months after start of "Measurement Period"]
      and AgeInYearsAt(start of E.relevantPeriod) >= 6 months
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ', 'GT', '95'}
      and not E.placeOfService in {'02'}

define "Influenza Vaccine":
  ["Procedure, Performed": "MIPS; Performance Met: G8482"]
  union ["Medication, Administered": "Influenza Vaccine"]
  union ["Procedure, Performed": "Influenza Vaccination"]
  union ["Communication: From Patient to Provider": "Previous Receipt of Influenza Vaccine"]

define "Exception Allergy":
  ["Diagnosis": "VSAC; Allergy to Influenza Vaccine"]
  union ["Diagnosis": "VSAC; Intolerance to Influenza Vaccine"]
  union ["Diagnosis": "VSAC; Allergy to Eggs"]
  union ["Allergy": "VSAC; Influenza Vaccine"]

define "Exception Procedure":
  ["Procedure, Performed": "VSAC; Influenza Vaccine Declined"]
  union ["Procedure, Performed": "MIPS; Denominator Exception: G8483"]

/* Populations */

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: G8482":
  /*
  * config_link_id: G8482
  */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8482"] P
    where P.relevantPeriod during [5 months before start of "Measurement Period", 3 months after start of "Measurement Period"])

define "Denominator Exception: G8483":
  /*
  * config_link_id: G8483
  */
  exists("Denominator Encounter" E
    with "Exception Allergy" A
      such that A.prevalencePeriod overlaps E.relevantPeriod)
  or exists("Denominator Encounter" E
    with "Exception Procedure" P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performace Not Met: G8484":
  /*
  * config_link_id: G8484
  */
  not "Numerator Performance Met: G8482"
  and not "Denominator Exception: G8483"
