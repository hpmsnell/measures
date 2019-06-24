library MIPS_474_2019 version '1'

/*
 * Source: MIPS
 * ID: 474
 * Year: 2019
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 474 Procedure"
valueset "MIPS; Atrial Fibrillation"
valueset "MIPS; Performance Met: M1064"
valueset "Denominator Exception: M1065"
valueset "MIPS; Performance Not Met: M1066"

// Able value sets

valueset "Able; Shingrix Vaccine"

// VSAC value sets

valueset "VSAC; Pregnancy Dx"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 474 Procedure"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 50
      and not E.code.modifier in ['GQ', 'GT', '95']
      and not E.placeOfService = '02'
      and E.signingProvider.hasMeasureMembership = true

define "Shingrix Vaccine":
  ["Immunization": "Able; Shingrix Vaccine"] I
    where I.authorDateTime before end of "Measurement Period"

define "2 Shingrix Doses Exist":
  exists("Shingrix Vaccine" I1
    with "Shingrix Vaccine" I2
      such that I2.authorDateTime 2 months or more after I1.authorDateTime
        and I2.authorDateTime 6 months or less after I1.authorDateTime)

/* POPULATIONS */

define "Denominator":
  exists("Denominator Procedure")

define "Denominator Exclusion: Pregnancy":
  /*
   * config_link_id: M1061
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exclusion: M1061"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Diagnosis": "VSAC; Pregnancy Dx"] D
    where D.prevalencePeriod overlaps "Measurement Period")

define "Denominator Exclusion: Immunocompromised":
  /*
   * config_link_id: M1062
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exclusion: M1062"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Diagnosis": "Able; Immunodeficient Conditions"] D
    where D.prevalencePeriod overlaps "Measurement Period")

define "Denominator Exclusion: Immunosuppressive Therapy":
  /*
   * config_link_id: M1063
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exclusion: M1063"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: M1064":
  /*
   * config_link_id: M1064
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: M1064"] P
    where P.relevantPeriod starts during "Measurement Period"
  or "2 Shingrix Doses Exist"

define "Denominator Exception: M1065":
  /*
   * config_link_id: M1065
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: M1065"] P
    where P.relevantPeriod starts before end of "Measurement Period"
  or exists(["Allergy": "Able; Shingrix Vaccine"] A
    where A.prevalencePeriod starts overlaps "Measurement Period")
  or exists("Shingrix Vaccine" I
    where I.authorDateTime during [3 months before end of "Measurement Period", end of "Measurement Period"])

define "Numerator Performance Not Met: M1066":
 /*
  * config_link_id: M1066
  */
 not "Denominator Exclusion: Pregnancy"
 and not "Denominator Exclusion: Immunocompromised"
 and not "Denominator Exclusion: immmunocompressive Therapy"
 and not "Numerator Performance Met: M1064"
 and not "Denominator Exception: M1065"
