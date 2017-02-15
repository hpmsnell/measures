library MIPS_110_2017 version '1'

/*
 * Source: MIPS
 * ID: 110
 * Year: 2017\
 */

using QDM

// Able custom value sets

valueset "MIPS; MIPS 110 Encounter"
valueset "MIPS; MIPS 110 Preventive Encounter"
valueset "MIPS; Denominator Exception: G8483"
valueset "MIPS; Performance Met: G8482"
valueset "MIPS; Performance Not Met: G8484"
valueset "MIPS; Telemedicine Modifier"

// CMS created VSACs
valueset "VSAC; Allergy to Eggs" '2.16.840.1.113883.3.526.3.1253'
valueset "VSAC; Allergy to Influenza Vaccine" '2.16.840.1.113883.3.526.3.1256'
valueset "VSAC; Intolerance to Influenza Vaccine" '2.16.840.1.113883.3.526.3.1257'
valueset "VSAC; Influenza Vaccine" '2.16.840.1.113883.3.526.2.1351'

parameter "Measurement Period" Interval<DateTime>

context Population

define "Encounter Interval A": Interval[start "Measurement Period", 3 months after start "Measurement Period")
define "Encounter Interval B": Interval[10 months after start "Measurement Period", end "Measurement Period")
define "Administration Interval A": Interval[4 months before start "Measurement Period", 3 months after start "Measurement Period"]
define "Administration Interval B": Interval[8 months after start "Measurement Period", end "Measurement Period"]

define "110 Encounters During Measurement Period":
  ["Encounter, Performed": "MIPS; 110 Encounter"] E
    where E.relevantPeriod starts during "Encounter Interval A"
      or E.relevantPeriod starts during "Encounter Interval B"
      and E.signingProvider.pqrsProvider = true
      and not E.code.modifier in "MIPS; Telehealth Modifier"
    sort by start of E.relevantPeriod DESC

define "110 Encounters During Interval A":
  ["Encounter, Performed": "MIPS; 110 Encounter"] E
    where E.relevantPeriod starts during "Encounter Interval A"
      and E.signingProvider.pqrsProvider = true
      and not E.code.modifier in "MIPS; Telehealth Modifier"
    sort by start of E.relevantPeriod DESC

define "110 Encounters During Interval B":
  ["Encounter, Performed": "MIPS; 110 Encounter"] E
    where E.relevantPeriod starts during "Encounter Interval B"
      and E.signingProvider.pqrsProvider = true
      and not E.code.modifier in "MIPS; Telehealth Modifier"
    sort by start of E.relevantPeriod DESC

define "Preventive Encounters During Measurement Period":
  ["Encounter, Performed": "MIPS; 110 Preventive Encounter"] E
    where E.relevantPeriod starts during "Encounter Interval A"
      or E.relevantPeriod starts during "Encounter Interval B"
      and E.signingProvider.pqrsProvider = true
      and not E.code.modifier in "MIPS; Telehealth Modifier"

define "Preventive Encounters During Interval A":
  ["Encounter, Performed": "MIPS; 110 Preventive Encounter"] E
      or E.relevantPeriod starts during "Encounter Interval A"
      and E.signingProvider.pqrsProvider = true
      and not E.code.modifier in "MIPS; Telehealth Modifier"

define "Preventive Encounters During Interval B":
  ["Encounter, Performed": "MIPS; 110 Preventive Encounter"] E
      or E.relevantPeriod starts during "Encounter Interval B"
      and E.signingProvider.pqrsProvider = true
      and not E.code.modifier in "MIPS; Telehealth Modifier"

define "Patient of Age at 2 110 Encounters":
  AgeInYearsAt("110 Encounters During Measurement Period"[0]) >= 6 months
  and AgeInYearsAt("110 Encounters During Measurement Period"[1]) >= 6 months

define "Patient of Age at Encounter During Period A":
  (
    "Patient of Age at 2 110 Encounters"
    and AgeInYearsAt("110 Encounters During Period A") >= 6 months
  ) or (
    AgeInYearsAt("Preventive Encounters During Period A") >= 6 months
  )

define "Patient of Age at Encounter During Period B":
  (
    "Patient of Age at 2 110 Encounters"
    and AgeInYearsAt("110 Encounters During Period B") >= 6 months
  ) or (
    AgeInYearsAt("Preventive Encounters During Period B") >= 6 months
  )

define "Denominator":
  "Patient of Age at 2 110 Encounters"
  or "Patient of Age at 1 Preventive Encounter"

define "Numerator Performance Met 1: G8482":
  /*
  * config_link_id: G8482_1
  * Immunization administered during 2016 or 2017 flu season
  */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8482"] P
    where P.relevantPeriod during "Measurement Period")

define "Numerator Performance Met 2: G8482":
  /*
  * config_link_id: G8482_2
  * Immunization administered during 2016 flu season
  */
  "Patient of Age at Encounter in Period A"
  and exists(["Medication, Administered": "VSAC; Influenza Vaccine"] M
    where M.relevantPeriod starts during "Administration Interval A")

define "Numerator Performance Met 3: G8482":
  /*
  * config_link_id: G8482_3
  * Immunization administered during 2017 flu season
  */
  "Patient of Age at Encounter in Period B"
  and exists(["Medication, Administered": "VSAC; Influenza Vaccine"] M
    where M.relevantPeriod starts during "Administration Interval B")

define "Denominator Exception 1: G8483":
  /*
  * config_link_id: G8483_1
  * Exception due to an allergy or intolerance
  */
  exists (["Diagnosis": "VSAC; Allergy to Influenza Vaccine"] D
    where D.prevelancePeriod overlaps "Measurement Period")
  or exists (["Diagnosis": "VSAC; Intolerance to Influenza Vaccine"] D
    where D.prevlancePeriod overlaps "Measurement Period")
  or exists (["Diagnosis": "VSAC; Allergy to Eggs"] D
    where D.prevelancePeriod overlaps "Measurement Period")


define "Denominator Exception 2: G8483":
  /*
  * config_link_id: G8483_2
  * Exception due to a medical, patient or system reason or other non-specified reason
  */
  exists (["Procedure, Performed": "MIPS; Denominator Exception: G8483"] P
      where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performace Not Met: G8484":
  /*
  * config_link_id: G8484
  * Immunization not administered for an unspecified reason
  */
  not "Numerator Performance Met: G8482"
  and not "Denominator Exception 1: G8483"
  and not "Denominator Exception 2: G8483"
  and not "Denominator Exception 3: G8483"
