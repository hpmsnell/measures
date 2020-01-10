library MIPS_112_2019 version '1'

/*
 * Source: MIPS
 * ID: 112
 * Year: 2019
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// Able Custom Value Sets

valueset "MIPS; MIPS 112 Encounter"
valueset "MIPS; History of Mastectomy: G9708"
valueset "MIPS; MIPS Hospice Service"
valueset "MIPS; Denominator Exclusion: G9898"
valueset "MIPS; Performance Met: G9899"
valueset "MIPS; Performance Not Met: G9900"

// VSAC Value Sets
valueset "VSAC; Status Post Left Mastectomy": '2.16.840.1.113883.3.464.1003.198.12.1069'
valueset "VSAC; Status Post Right Mastectomy": '2.16.840.1.113883.3.464.1003.198.12.1070'
valueset "VSAC; Bilateral Mastectomy": '2.16.840.1.113883.3.464.1003.198.12.1005'
valueset "VSAC; History of bilateral mastectomy": '2.16.840.1.113883.3.464.1003.198.12.1068'
valueset "VSAC; Mammography":'2.16.840.1.113883.3.464.1003.108.12.1018'
valueset "VSAC; Female": '2.16.840.1.113883.3.560.100.2'
valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'

// Able value Sets

valueset "Able; Mammogram"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Mammography":
  ["Diagnostic Study, Performed": "VSAC; Mammography"]
  union ["Diagnostic Study, Performed": "Able; Mammogram"]
  union ["Laboratory Test, Performed": "VSAC; Mammography"]
  union ["Laboratory Test, Performed": "Able; Mammogram"]

define "Denominator":
  AgeInYearsAt(start of "Measurement Period") >= 51
  and AgeInYearsAt(start of "Measurement Period") < 74
  and "Patient Characteristic Sex" = 'Female'
  and exists(["Encounter, Performed": "MIPS; MIPS 112 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period")
    and E.signingProvider.hasMeasureMembership = true
    and not E.placeOfService in {'32','33','34','54','56'}

define "Denominator Exclusion 1":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Procedure, Performed": "MIPS; History of Bilateral Mastectomy: G9708"] P
    where P.relevantPeriod starts before end "Measurement Period")
  or exists(["Procedure, Performed": "VSAC; Bilateral Mastectomy"] P
    where P.relevantPeriod starts before end "Measurement Period")
  or exists(["Procedure, Performed": "VSAC; History of bilateral mastectomy"] P
    where P.relevantPeriod starts before end "Measurement Period")
  or exists(["Diagnosis": "VSAC; History of bilateral mastectomy"] D
    where D.prevalencePeriod starts before end "Measurement Period")
  or (
     exists(["Procedure, Performed": "VSAC; Status Post Left Mastectomy"] P
      where P.relevantPeriod starts before end "Measurement Period")
     and exists(["Procedure, Performed": "VSAC; Status Post Right Mastectomy"] P
      where P.relevantPeriod starts before end "Measurement Period")
  )
   or (
     exists(["Diagnosis": "VSAC; Status Post Left Mastectomy"] D
      where D.prevalencePeriod starts before end "Measurement Period")
     and exists(["Diagnosis": "VSAC; Status Post Right Mastectomy"] D
      where D.prevalencePeriod starts before end "Measurement Period")
   )

define "Denominator Exclusion 2":
  /*
   * config_link_id: exclusion_2
   */
  exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Measurement Period")
  or exists(["Intervention, Performed": "MIPS; MIPS Hospice Service"] I
    where I.relevantPeriod overlaps "Measurement Period")

define "Denominator Exclusion 3":
 /*
  * config_link_id: exclusion_3
  */
 exists(["Procedure, Performed": "MIPS; Denominator Exclusion: G9898"] P
   where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: G9899":
  /*
   * config_link_id: G9899
   */
  exists("Mammography" D
    where D.relevantPeriod starts 27 months or less before end "Measurement Period")
  or exists(["Procedure, Performed": "MIPS; Performance Met: G9899"] P
    where P.relevantPeriod starts 27 months or less before end "Measurement Period")

define "Numerator Performance Not Met: G9900":
  /*
   * config_link_id: G9900
   */
  not "Denominator Exclusion 1"
  and not "Denominator Exclusion 2"
  and not "Denominator Exclusion 3"
  and not "Numerator Performance Met: G9899"
