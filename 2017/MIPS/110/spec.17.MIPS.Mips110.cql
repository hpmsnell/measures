library MIPS_110_2017 version '1'

/*
 * Source: MIPS
 * ID: 110
 * Year: 2017\
 */

using QDM

// Able custom value sets

valueset "MIPS; MIPS 110 Encounter A"
valueset "MIPS; MIPS 110 Encounter B"
valueset "MIPS; Performance Exception: G8483"
valueset "MIPS; Performance Met: G8482"
valueset "MIPS; Performance Not Met: G8484"

// CMS created VSACs
valueset "VSAC; Allergy to Eggs" '2.16.840.1.113883.3.526.3.1253'
valueset "VSAC; Allergy to Influenza Vaccine" '2.16.840.1.113883.3.526.3.1256'
valueset "VSAC; Intolerance to Influenza Vaccine" '2.16.840.1.113883.3.526.3.1257'
valueset "VSAC; Not Done: Medical Reason" '2.16.840.1.113883.3.526.3.1007'
valueset "VSAC; Not Done: Patient Reason" '2.16.840.1.113883.3.526.3.100'
valueset "VSAC; Not Done: System Reason" '2.16.840.1.113883.3.526.3.1009'
valueset "VSAC; Influenza Vaccine" '2.16.840.1.113883.3.526.3.1254'

define "Measurement Interval A": Interval[@2017-01-01T00:00:00.0, @2017-03-31T00:00:00.0]
define "Measurement Interval B": Interval[@2016-10-01T00:00:00.0, @2016-12-31T00:00:00.0]

define "Measurement Period" default Interval

context Population

define "Denominator":
/*
* config_link_id: denominator
*/
  exists AgeInMonthsAt(start of "Measurement Period") >= 6
    where D.prevalencePeriod overlaps "Measurement Period")
  and exists (["Encounter, Performed": "MIPS; MIPS 110 Encounter A"] during "Measurement Interval A")
      or exists (["Encounter, Performed": "MIPS; MIPS 110 Encounter A"] during "Measurement Interval B")
    and not ([Encounter, Performe": "Telemedicine GC Modifier"])
    OR
  where D.prevelancePeriod overlaps "Measurement Period")
    and exists (["Encounter, Performed": "MIPS; MIPS 110 Encounter B"] during "Measurement Interval A")
      or exists (["Encounter, Performed": "MIPS; MIPS 110 Encoutner B"] during "Measurement Interval B")
    and not (["Encounter, Performed": Telemedicne GC Modifier")

define "Numerator Performance Met 1: G8482":
/*
* config_link_id: numerator_1
*/
  exists (["Medication, Administered": "VSAC; Influenza Vaccine"] during "Measurement Period" M
    where M.prevlancePeriod overlaps "Measurement Period")

define "Numerator Performance Met 2: G8482"
/*
* config_link_id: numerator_2
*/
  exists(["Procedure, Performed": "MIPS; Performance Met: G8482"] during "Measurement Period" M
    where M.prevelancePeriod overlaps "Measurement Period")

define "Denominator Exception 1: G8483":
/*
* config_link_id: exception_1
* Exception due to a influenza allergy or intolerance
*/
  or exists (["Diagnosis, Active": "VSAC; Allergy to Influenza Vaccine"] D
    where D.prevelancePeriod overlaps "Measurement Period"
  or exists (["Diagnosis, Active": "VSAC; Intolerance to Influenza Vaccine"] D
    where D.prevlancePeriod overlaps "Measurement Period")

define "Denominator Exception 2: G8483":
/*
* config_link_id: exception_2
* Exception due to an egg ellergy
*/
  or exists (["Diagnosis, Active": "VSAC; Allergy to Eggs"] D
    where D.prevelancePeriod overlaps "Measurement Period")


define "Denominator Exception 3: G8483":
/*
* config_link_id: exception_3
* Exception due to a medical, patient or system reason or other non-specified reason
*/
  exists (["Diagnosis, Active": "VSAC; Not Done: Medical Reason"] D
    where D.prevlancePeriod overlaps "Measurement Period"
  or exists (["Diagnosis, Active": "VSAC; Not Done: Patient Reason"] D
    where D.prevlancePeriod overlaps "Measurement Period"
  or exists (["Diagnosis, Active": "VSAC; Not Done: System Reason"] D
    where D.prevlancePeriod overlaps "Measurement Period")
  or exists (["Procedure, Performed": "MIPS; Performance Exception: G8483"] D
      where D.prevlancePeriod overlaps "Measurement Period")

define "Numerator Performace Not Met: G8484":
/*
* config_link_id: G8484
* Immunization not administered for an unspecified reason
*/
  exists "denominator"
  not "Numerator Performance Met: G8482"
  and not "Denominator Exception 1 G8483"
  and not "Denominator Exception 2 G8483"
