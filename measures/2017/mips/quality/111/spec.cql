library MIPS_111_2017 version '1'

/*
 * Source: MIPS
 * ID: 111
 * Year: 2017
 * Version: 1
 * Written By: Steve Daniels
 * Reviewed By: Rachel Katz
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 111 Encounter"
valueset "MIPS; MIPS Hospice Service"
valueset "MIPS; Performance Met: 4040F"
valueset "MIPS; Performance Not Met: 4040F-8P"

// VSAC Value Sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'
valueset "VSAC; Pneumococcal Vaccine": '2.16.840.1.113883.3.464.1003.110.12.1027'
valueset "VSAC; Pneumococcal Vaccine Administered": '2.16.840.1.113883.3.464.1003.110.12.1034'
valueset "VSAC; History of Pneumococcal Vaccine": '2.16.840.1.113883.3.464.1003.110.12.1028'

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 111 Encounter"] E
    where E.relevantPeriod starts during "E.relevantPeriod starts during "Denominator Period" Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 65
      and E.signingProvider.hasMeasureMembership = true

define "Denominator":
  exists("Denominator Encounter")

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Intervention, Performed": "MIPS; MIPS Hospice Service"] I
    where I.relevantPeriod starts during "Denominator Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Denominator Period")

define "Numerator Performance Met: 4040F":
  /*
   * config_link_id: 4040F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 4040F"] P
    where P.relevantPeriod starts before end of "Measurement Period")
  or exists(["Immunization, Administered": "VSAC; Pneumococcal Vaccine"] I
    where I.authorDateTime before end of "Measurement Period")
  or exists(["Procedure, Performed": "VSAC; Pneumococcal Vaccine Administered"] P
    where P.relevantPeriod starts before end of "Measurement Period")
  or exists(["Assessment, Performed": "VSAC; History of Pneumococcal Vaccine"] A
    where A.authorDateTime before end of "Measurement Period")

define "Numerator Performance Not Met: 4040F-8P":
  /*
   * config_link_id: 4040F-8P
   */
   not "Denominator Exclusion"
   and not "Numerator Performance Met: 4040F"
