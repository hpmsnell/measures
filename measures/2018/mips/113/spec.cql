library MIPS_113_2018 version '1'

/*
 * Source: MIPS
 * ID: 113
 * Year: 2018
 * Version: 1
 */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 113 Encounter"
valueset "MIPS; MIPS Hospice Service"
valueset "MIPS; History of Total Colectomy or Colorectal Cancer: G9711"
valueset "MIPS; Institutional Exclusion"
valueset "MIPS; Performance Met: 3017F"
valueset "MIPS; Performance Not Met: 3017F-8P"

// VSAC value sets

valueset "VSAC; Malignant Neoplasm of Colon": '2.16.840.1.113883.3.464.1003.108.12.1001'
valueset "VSAC; Fecal Occult Blood Test (FOBT)": '2.16.840.1.113883.3.464.1003.198.12.1011'
valueset "VSAC; Colonoscopy": '2.16.840.1.113883.3.464.1003.108.12.1020'
valueset "VSAC; Flexible Sigmoidoscopy": '2.16.840.1.113883.3.464.1003.198.12.1010'
valueset "VSAC; CT Colonography"
valueset "VSAC; FIT-DNA"
valueset "VSAC; Total Colectomy": '2.16.840.1.113883.3.464.1003.198.12.1019'
valueset "VSAC; Palliative Care" '2.16.840.1.113883.3.600.1.1579'

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator":
  exists(["Encounter, Performed": "MIPS; MIPS 113 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period")
      and AgeInYearsAt(start of E.relevantPeriod) >= 50
      and AgeInYearsAt(start of E.relevantPeriod) < 75
      and E.signingProvider.hasMeasureMembership = true

define "Denominator Exclusion 1":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Diagnosis": "VSAC; Malignant Neoplasm of Colon"] D
    where D.prevalencePeriod starts before end of "Denominator Period")
  or exists(["Procedure, Performed": "VSAC; Total Colectomy"] P
    where P.relevantPeriod starts before end of "Denominator Period")
  or exists (["Procedure, Performed": "MIPS; History of Total Colectomy or Colorectal Cancer: G9711"] P
    where P.relevantPeriod starts before end of "Denominator Period")

define "Denominator Exclusion 2":
  /*
   * config_link_id: exclusion_2
   */
  exists(["Intervention, Performed": "MIPS; MIPS Hospice Service"] I //Updated to Intervention, Performed
    where I.relevantPeriod starts during "Denominator Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I //New value set added
    where I.relevantPeriod starts during "Denominator Period")

define "Denominator Exclusion 3":
  /*
   * config_link_id: exclusion_3
   */
  exists(["Procedure, Performed": "MIPS; Institutional Exclusion"] P
    where P.relevantPeriod starts during "Measurement Period"
      and AgeInyearsAt(start of P.relevantPeriod) >= 65)
  or exists(["Procedure, Performed": "VSAC; Care Services in Long-Term Residential Facility"] P
    where P.relevantPeriod starts during "Measurement Period"
      and AgeInyearsAt(start of P.relevantPeriod) >= 65)

define "Numerator Performance Met: 3017F":
  /*
   * config_link_id: 3017F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 3017F"] P where P.relevantPeriod starts during "Measurement Period")
  or exists(["Procedure, Performed": "VSAC; Colonoscopy"] P where P.relevantPeriod starts 10 years or less before end "Measurement Period")
  or exists(["Procedure, Performed": "VSAC; Flexible Sigmoidoscopy"] P where P.relevantPeriod starts 5 years or less before end "Measurement Period")
  or exists(["Laboratory Test, Performed": "VSAC; Fecal Occult Blood Test (FOBT)"] L where L.resultDateTime during "Measurement Period")
  or exists(["Procedure, Performed": "VSAC; Fecal Occult Blood Test (FOBT)"] L where L.relevantPeriod starts during "Measurement Period")
  or exists(["Laboratory Test, Performed": "VSAC; FIT-DNA"] L where L.resultDateTime 3 years or less before end of "Measurement Period")
  or exists(["Procedure, Performed": "VSAC; FIT-DNA"] L where L.relevantPeriod starts 3 years or less before end of "Measurement Period")
  or exists(["Procedure, Performed": "VSAC; CT Colonography"] L where L.relevantPeriod starts 5 years or less before end of "Measurement Period")

define "Numerator Performance Not Met: 3017F-8P":
  /*
   * config_link_id: 3017F-8P
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met: 3017F"
