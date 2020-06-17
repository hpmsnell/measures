library MIPS_113_2020 version '1'

/*
 * Source: MIPS
 * ID: 113
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 */

using QDM

include "../shared/frailty_lti_shared" version '1' called FrailtyLTIShared

// MIPS value sets

valueset "MIPS; MIPS 113 Encounter"
valueset "MIPS; Performance Met: 3017F"
valueset "MIPS; Performance Not Met: 3017F-8P"
valueset "MIPS; History of Total Colectomy or Colorectal Cancer: G9711"
valueset "MIPS; Institutional Exclusion"
valueset "MIPS; MIPS Hospice Service"
valueset "MIPS; LTI"
valueset "MIPS; Frailty and Dementia Medication"
valueset "MIPS; Frailty and Advanced Illness"

// VSAC value sets

valueset "VSAC; Malignant Neoplasm of Colon": '2.16.840.1.113883.3.464.1003.108.12.1001'
valueset "VSAC; Colonoscopy": '2.16.840.1.113883.3.464.1003.108.12.1020'
valueset "VSAC; Flexible Sigmoidoscopy": '2.16.840.1.113883.3.464.1003.198.12.1010'
valueset "VSAC; Total Colectomy": '2.16.840.1.113883.3.464.1003.198.12.1019'
valueset "VSAC; Fecal Occult Blood Test (FOBT)": '2.16.840.1.113883.3.464.1003.198.12.1011'
valueset "VSAC; Palliative Care" '2.16.840.1.113883.3.600.1.1579'
valueset "VSAC; Acute Inpatient": '2.16.840.1.113883.3.464.1003.101.12.1083'
valueset "VSAC; Advanced Illness": '2.16.840.1.113883.3.464.1003.110.12.1082'
valueset "VSAC; Care Services in Long-Term Residential Facility": '2.16.840.1.113883.3.464.1003.101.12.1014'
valueset "VSAC; Dementia Medications": '2.16.840.1.113883.3.464.1003.196.12.1510'
valueset "VSAC; Encounter Inpatient": '2.16.840.1.113883.3.666.5.307'
valueset "VSAC; Frailty Diagnosis": '2.16.840.1.113883.3.464.1003.113.12.1074'
valueset "VSAC; Frailty Encounter": '2.16.840.1.113883.3.464.1003.101.12.1088'
valueset "VSAC; Nonacute Inpatient": '2.16.840.1.113883.3.464.1003.101.12.1084'
valueset "VSAC; Nursing Facility Visit": '2.16.840.1.113883.3.464.1003.101.12.1012'
valueset "VSAC; Observation": '2.16.840.1.113883.3.464.1003.101.12.1086'
valueset "VSAC; Outpatient": '2.16.840.1.113883.3.464.1003.101.12.1087'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator":
  exists(["Encounter, Performed": "MIPS; MIPS 113 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period")
      and AgeInYearsAt(start of E.relevantPeriod) >= 50
      and AgeInYearsAt(start of E.relevantPeriod) < 75
      and E.signingProvider.hasMeasureMembership = true
      and not E.placeOfService in {'32','33','34','54','56'}

define "Denominator Exclusion: Cancer":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Diagnosis": "VSAC; Malignant Neoplasm of Colon"] D
    where D.prevalencePeriod starts before end "Measurement Period")
  or exists(["Procedure, Performed": "VSAC; Total Colectomy"] P
    where P.relevantPeriod starts before end "Measurement Period")
  or exists (["Procedure, Performed": "MIPS; History of Total Colectomy or Colorectal Cancer: G9711"] P
    where P.relevantPeriod starts before end "Measurement Period")

define "Denominator Exclusion: Hospice":
  /*
   * config_link_id: exclusion_2
   */
  exists(["Intervention, Performed": "MIPS; MIPS Hospice Service"] I //Updated to Intervention, Performed
    where I.relevantPeriod starts during "Measurement Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I //New value set added
    where I.relevantPeriod starts during "Measurement Period")

define "Denominator Exclusion: Frailty/LTI":
  /*
   * config_link_id: exclusion_frailty_lti
   */
  FrailtyLTIShared."Frailty/LTI Exclusion Exists"

define "Numerator Performance Met: 3017F":
  /*
   * config_link_id: 3017F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 3017F"] P where P.relevantPeriod starts during "Measurement Period") //New addition
  or exists(["Procedure, Performed": "VSAC; Colonoscopy"] P where P.relevantPeriod starts 9 years or less before end "Measurement Period")
  or exists(["Procedure, Performed": "VSAC; Flexible Sigmoidoscopy"] P where P.relevantPeriod starts 4 years or less before end "Measurement Period")
  or exists(["Laboratory Test, Performed": "VSAC; Fecal Occult Blood Test (FOBT)"] L where L.resultDateTime during "Measurement Period")
  or exists(["Procedure, Performed": "VSAC; Fecal Occult Blood Test (FOBT)"] L where L.relevantPeriod starts during "Measurement Period")
  or exists(["Laboratory Test, Performed": "VSAC; Fecal Occult Blood Test (FOBT)"] L where L.resultDateTime during "Measurement Period")
  or exists(["Procedure, Performed": "VSAC; FIT DNA"] L where L.relevantPeriod starts 3 years or less before end of "Measurement Period")
  or exists(["Laboratory Test, Performed": "VSAC; FIT DNA"] L where L.resultDateTime 3 years or less before end of "Measurement Period")
  or exists(["Procedure, Performed": "VSAC; CT Colonography"] L where L.relevantPeriod starts 5 years or less before end of "Measurement Period")


define "Numerator Performance Not Met: 3017F-8P":
  /*
   * config_link_id: 3017F-8P
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met: 3017F"
