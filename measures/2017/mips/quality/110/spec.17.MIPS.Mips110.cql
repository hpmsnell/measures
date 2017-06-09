library MIPS_110_2017 version '1'

/*
 * Source: MIPS
 * ID: 110
 * Year: 2017
 * Written By: Steve Daniels
 * Reviewed By: Rachel Katz
 */

using QDM

// Able custom value sets

valueset "MIPS; MIPS 110 Encounter"
valueset "MIPS; MIPS 110 Preventive Encounter"
valueset "MIPS; Denominator Exception: G8483"
valueset "MIPS; Performance Met: G8482"
valueset "MIPS; Performance Not Met: G8484"
valueset "MIPS; Telehealth Modifier"

// VSAC value sets
valueset "VSAC; Allergy to Eggs" '2.16.840.1.113883.3.526.3.1253'
valueset "VSAC; Allergy to Influenza Vaccine" '2.16.840.1.113883.3.526.3.1256'
valueset "VSAC; Intolerance to Influenza Vaccine" '2.16.840.1.113883.3.526.3.1257'
valueset "VSAC; Influenza Vaccination" '2.16.840.1.113883.3.526.3.402'
valueset "VSAC; Influenza Vaccine" '2.16.840.1.113883.3.526.2.1351'
valueset "VSAC; Previous Receipt of Influenza Vaccine" '2.16.840.1.113883.3.526.3.1185'
valueset "VSAC; Influenza Vaccination Declined" '2.16.840.1.113883.3.526.3.1255'

parameter "Measurement Period" Interval<DateTime>

context Population

define "Encounter Interval A": Interval[start of "Measurement Period", 3 months after start of "Measurement Period")
define "Encounter Interval B": Interval[3 months before end "Measurement Period", end "Measurement Period")
define "Encounter Bad Interval": Interval[3 months after start of "Measurement Period", 5 months before end "Measurement Period")
define "Administration Interval A": Interval[5 months before start of "Measurement Period", 3 months after start of "Measurement Period"]
define "Administration Interval B": Interval[5 months before end "Measurement Period", end "Measurement Period"]

define "110 Encounters During Influenza Intervals":
  ["Encounter, Performed": "MIPS; 110 Encounter"] E
    where E.relevantPeriod starts during "Encounter Interval A"
      or E.relevantPeriod starts during "Encounter Interval B"
      and AgeInYearsAt(start of E.relevantPeriod) >= 6 months
      and E.signingProvider.pqrsProvider = true
      and not E.code.modifier in "MIPS; Telehealth Modifier"

define "110 Encounters During Non-Influenza Interval":
  ["Encounter, Performed": "MIPS; 110 Encounter"] E
    where E.relevantPeriod starts during "Encounter Bad Interval"
      and AgeInYearsAt(start of E.relevantPeriod) >= 6 months
      and E.signingProvider.pqrsProvider = true
      and not E.code.modifier in "MIPS; Telehealth Modifier"

define "110 Encounters During Interval A":
  ["Encounter, Performed": "MIPS; 110 Encounter"] E
    where E.relevantPeriod starts during "Encounter Interval A"
      and AgeInYearsAt(start of E.relevantPeriod) >= 6 months
      and E.signingProvider.pqrsProvider = true
      and not E.code.modifier in "MIPS; Telehealth Modifier"

define "110 Encounters During Interval B":
  ["Encounter, Performed": "MIPS; 110 Encounter"] E
    where E.relevantPeriod starts during "Encounter Interval B"
      and AgeInYearsAt(start of E.relevantPeriod) >= 6 months
      and E.signingProvider.pqrsProvider = true
      and not E.code.modifier in "MIPS; Telehealth Modifier"

define "Preventive Encounters During Influenza Intervals":
  ["Encounter, Performed": "MIPS; 110 Preventive Encounter"] E
    where E.relevantPeriod starts during "Encounter Interval A"
      or E.relevantPeriod starts during "Encounter Interval B"
      and AgeInYearsAt(start of E.relevantPeriod) >= 6 months
      and E.signingProvider.pqrsProvider = true
      and not E.code.modifier in "MIPS; Telehealth Modifier"

define "Preventive Encounters During Interval A":
  ["Encounter, Performed": "MIPS; 110 Preventive Encounter"] E
    where E.relevantPeriod starts during "Encounter Interval A"
      and AgeInYearsAt(start of E.relevantPeriod) >= 6 months
      and E.signingProvider.pqrsProvider = true
      and not E.code.modifier in "MIPS; Telehealth Modifier"

define "Preventive Encounters During Interval B":
  ["Encounter, Performed": "MIPS; 110 Preventive Encounter"] E
    where E.relevantPeriod starts during "Encounter Interval B"
      and AgeInYearsAt(start of E.relevantPeriod) >= 6 months
      and E.signingProvider.pqrsProvider = true
      and not E.code.modifier in "MIPS; Telehealth Modifier"

define "2 110 Encounters Exist":
  count("110 Encounters During Influenza Intervals") >= 2
  or (
    exists("110 Encounters During Influenza Intervals")
    and exists("110 Encounters During Non-Influenza Interval")
  )

define "1 Preventive Encounter Exists":
  exists("Preventive Encounters During Influenza Intervals")

define "Encounter During Interval A Exists":
  (
    "2 110 Encounters Exist"
    and exists("110 Encounters During Interval A")
  ) or (
    exists("Preventive Encounters During Interval A")
  )

define "Encounter During Interval B":
  (
    "2 110 Encounters Exist"
    and exists("110 Encounters During Interval B")
  ) or exists("Preventive Encounters During Interval B")

define "Influenza Vaccines":
  ["Medication, Administered": "Influenza Vaccine"]
  union ["Procedure, Performed": "Influenza Vaccination"]
  union ["Communication: From Patient to Provider": "Previous Receipt of Influenza Vaccine"]

define "Denominator":
  "2 110 Encounters Exist"
  or "1 Preventive Encounter Exists"

define "Numerator Performance Met: G8482":
  /*
  * config_link_id: G8482
  */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8482"] P
    where P.relevantPeriod during "Measurement Period")
  or (
    "Encounter During Interval A Exists"
    and exists("Influenza Vaccines" M
      where M.relevantPeriod starts during "Administration Interval A")
  )
  or (
    "Encounter During Interval B"
    and exists("Influenza Vaccines" M
      where M.relevantPeriod starts during "Administration Interval B")
  )

define "Denominator Exception: G8483":
  /*
  * config_link_id: G8483
  */
  exists (["Diagnosis": "VSAC; Allergy to Influenza Vaccine"] D
    where D.prevelancePeriod overlaps "Measurement Period")
  or exists (["Diagnosis": "VSAC; Intolerance to Influenza Vaccine"] D
    where D.prevlancePeriod overlaps "Measurement Period")
  or exists (["Diagnosis": "VSAC; Allergy to Eggs"] D
    where D.prevelancePeriod overlaps "Measurement Period")
  or exists(["Allergy": "VSAC; Influenza Vaccine"] A
    where A.prevelancePeriod overlaps "Measurement Period")
  or exists (["Procedure, Performed": "MIPS; Denominator Exception: G8483"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists (["Procedure, Performed": "VSAC; Influenza Vaccine Declined"] P
    where P.relevantPeriod starts during "Administration Interval A"
      or P.relevantPeriod starts during "Administration Interval B")

define "Numerator Performace Not Met: G8484":
  /*
  * config_link_id: G8484
  */
  not "Numerator Performance Met: G8482"
  and not "Denominator Exception 1: G8483"
  and not "Denominator Exception 2: G8483"
  and not "Denominator Exception 3: G8483"
