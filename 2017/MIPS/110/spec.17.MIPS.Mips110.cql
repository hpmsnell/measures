library MIPS_001_2017 version '1'

/*
 * Source: MIPS
 * ID: 001
 * Year: 2017
 */

using QDM

// Able custom value sets

valueset "MIPS; MIPS 110 Encounter A"
valueset "MIPS; MIPS 110 Encounter B"

// CMS created VSACs

valueset "VSAC; Allergy to Eggs" '2.16.840.1.113883.3.526.3.1253'
valueset "VSAC; Allergy to Influenza Vaccine" '2.16.840.1.113883.3.526.3.1256'
valueset "VSAC; Intolerance to Influenza Vaccine" '2.16.840.1.113883.3.526.3.1257'
valueset "VSAC; Not Done: Medical Reason" '2.16.840.1.113883.3.526.3.1007'
valueset "VSAC; Not Done: Patient Reason" '2.16.840.1.113883.3.526.3.100'
valueset "VSAC; Not Done: System Reason" '2.16.840.1.113883.3.526.3.1009'
valueset "VSAC; Influenza Vaccine" '2.16.840.1.113883.3.526.3.1254'
valueset "VSAC; Influenza Vaccine" '2.16.840.1.113883.3.526.3.1254'

define "Measurement Interval A": Interval[@2017-01-01T00:00:00.0, @2017-03-31T00:00:00.0]
define "Measurement Interval B": Interval[@2016-10-01T00:00:00.0, @2016-12-31T00:00:00.0]

define "Measurement Period" default Interval

context Population

define "Denominator":
  AgeInMonthsAt(start of "Measurement Period") >= 6
  where D.prevalencePeriod overlaps "Measurement Period")
    and exists ([Encounter, Performed: "MIPS; MIPS 110 Encounter A"] during "Measurement Interval A")
      or exists ([Encounter, Performed: "MIPS; MIPS 110 Encounter A"] during "Measurement Interval B")
    and not ([Encounter, Performe: "Telemedicine GC Modifier"])
    OR
  where D.prevelancePeriod overlaps "Measurement Period")
    and exists ([Encounter, Performed: "MIPS; MIPS 110 Encounter B"] during "Measurement Interval A")
      or exists ([Encounter, Performed: "MIPS; MIPS 110 Encoutner B"] during "Measurement Interval B")
    and not (["Encounter, Performed: Telemedicne GC Modifier")

define "Numerator Performance Met: G8482":
/*
* config_link_id: G8482
*/
  exists ([Medication, Administered: "VSAC; Influenza Vaccine"] during "Measurement Period")

define "Numerator Performance Not Met: G8484":
/*
* config_link_id: G8484
*/
  not exists([Medication, Administered: "VSAC; Influenza Vaccine"] overlaps "Measurement Period")

define "Denominator Exception 1: G8483":
/*
* config_link_id: G8483
*/
  exists([VSAC; Diagnosis, Active: "VSAC; Allergy to Eggs"] D
    or exists([Diagnosis, Active: "VSAC; Allergy to Influenza Vaccine"] D
    or exists([Diagnosis, Active: "VSAC; Intolerance to Influenza Vaccine"] D
    where D.prevelancePeriod overlaps "Measurement Period")

define "Denominator Exception 2: G8483":
/*
* config_link_id: G8483
*/
  exists


, Allergy: Influenza Vaccine" <= 89 day(s) ends after start of "Measurement Period"
define "Denominator Exclusion":
  /*
   * config_link_id: exclusion
   */
  exists([Intervention, Performed: "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Measurement Period")
  or exists([Intervention, Performed: "MIPS; Hospice Service: G9687"] I
    where I.relevantPeriod overlaps "Measurement Period")

define "Numerator Performance Met: 3046F":
  /*
   * config_link_id: 3046F
   */
  Last([Laboratory Test, Performed: "VSAC; HbA1c Laboratory Test"] L
    where L.resultDateTime during "Measurement Period").result.value > 9 //Note that this is verifying the result of the last test
  or exists([Procedure, Performed: "MIPS; Performance Met: 3046F"] P
    where P.relevantPeriod starts during "Measurement Period")
  )

define "Numerator Performance Met: 3046-8P":
  /*
   * config_link_id: 3046F-8P
   */
  not exists(Laboratory Test, Performed: "VSAC; HbA1c Laboratory Test"] L
    where L.resultDateTime during "Measurement Period")
  or exists([Procedure, Performed: "MIPS; Performance Met: 3046F-8P"] P
    where P.relevantPeriod starts during "Measurement Period")
  )

define "Numerator Performance Not Met: 3044F":
  /*
   * config_link_id: 3044F
   */
  Last([Laboratory Test, Performed: "VSAC; HbA1c Laboratory Test"] L
    where L.resultDateTime during "Measurement Period").result.value < 7
  or exists([Procedure, Performed: "MIPS; Performance Not Met: 3044F"] P
    where P.relevantPeriod starts during "Measurement Period")
  )

define "Numerator Performance Not Met: 3045F":
  /*
   * config_link_id: 3045F
   */
  not "Numerator Performance Met: 3046F"
  and not "Numerator Performance Met: 3046-8P"
  and not "Numerator Performance Not Met: 3044F"
