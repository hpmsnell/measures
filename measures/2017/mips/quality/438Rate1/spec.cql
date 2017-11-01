library MIPS_438Rate1_2017 version '1'

/*
 *
 * Source: MIPS
 * ID: 438Rate1
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 438 Encounter"
valueset "MIPS; Clinical Atherosclerotic Cardiovascular Disease (ASCVD)"
valueset "MIPS; Performance Met: G9664"
valueset "MIPS; Denominator Exception: G9781"
valueset "MIPS; Performance Not Met: G9665"
valueset "MIPS; Pregnancy Exclusion"
valueset "MIPS; Breastfeeding Exclusion"
valueset "MIPS; Rhabdomyolysis Exclusion"
valueset "MIPS; MIPS Hospice Service"

// VSAC value sets

valueset "VSAC; PCI": '2.16.840.1.113762.1.4.1045.67'
valueset "VSAC; Carotid Intervention": '2.16.840.1.113883.3.117.1.7.1.204'
valueset "VSAC; CABG Surgeries": '2.16.840.1.113883.3.666.5.694'
valueset "VSAC; Myocardial Infarction": '2.16.840.1.113883.3.526.3.403'
valueset "VSAC; Ischemic heart disease or coronary occlusion, rupture, or thrombosis": '2.16.840.1.113762.1.4.1047.46'
valueset "VSAC; Stable and Unstable Angina": '2.16.840.1.113762.1.4.1047.47'
valueset "VSAC; Cerebrovascular disease, Stroke, TIA": '2.16.840.1.113762.1.4.1047.44'
valueset "VSAC; Atherosclerosis and Peripheral Arterial Disease": '2.16.840.1.113762.1.4.1047.21'
valueset "VSAC; Pregnancy Dx": '2.16.840.1.113883.3.600.1.1623'
valueset "VSAC; Breastfeeding": '2.16.840.1.113762.1.4.1047.73'
valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'
valueset "VSAC; Rhabdomyolysis": '2.16.840.1.113762.1.4.1047.102'
valueset "VSAC; Low intensity statin therapy": '2.16.840.1.113762.1.4.1047.107'
valueset "VSAC; Moderate intensity statin therapy": '2.16.840.1.113762.1.4.1047.98'
valueset "VSAC; High intensity statin therapy": '2.16.840.1.113762.1.4.1047.97'
valueset "VSAC; Statin Allergen": '2.16.840.1.113883.3.117.1.7.1.423'
valueset "VSAC; End Stage Renal Disease": '2.16.840.1.113883.3.526.3.353'
valueset "VSAC; Liver Disease": '2.16.840.1.113762.1.4.1047.42'
valueset "VSAC; Hepatitis A": '2.16.840.1.113883.3.464.1003.110.12.1024'
valueset "VSAC; Hepatitis B": '2.16.840.1.113883.3.67.1.101.1.269'

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "ASCVD":
  ["Procedure, Performed": "MIPS; Clinical Atherosclerotic Cardiovascular Disease (ASCVD)"]
  union ["Procedure, Performed": "VSAC; PCI"]
  union ["Procedure, Performed": "VSAC; Carotid Intervention"]
  union ["Procedure, Performed": "VSAC; CABG Surgeries"]
  union ["Diagnosis": "VSAC; Myocardial Infarction"]
  union ["Diagnosis": "VSAC; Ischemic heart disease or coronary occlusion, rupture, or thrombosis"]
  union ["Diagnosis": "VSAC; Stable and Unstable Angina"]
  union ["Diagnosis": "VSAC; Cerebrovascular disease, Stroke, TIA"]
  union ["Diagnosis": "VSAC; Atherosclerosis and Peripheral Arterial Disease"]

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 438 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ', 'GT'}
    with "ASCVD" D
      such that D.prevalencePeriod starts on or before end of E.relevantPeriod

define "Pregnancy":
  ["Diagnosis": "VSAC; Pregnancy Dx"]
  union ["Diagnosis": "VSAC; Breastfeeding"]

define "Pregnancy Exclusion":
  ["Procedure, Performed": "MIPS; Pregnancy Exclusion"]
  union ["Procedure, Performed": "MIPS; Breastfeeding Exclusion"]

define "Statin":
  ["Medication": "VSAC; Low intensity statin therapy"]
  union ["Medication": "VSAC; Moderate intensity statin therapy"]
  union ["Medication": "VSAC; High intensity statin therapy"]

define "Exception Diagnosis":
  union ["Diagnosis": "VSAC; End Stage Renal Disease"]
  union ["Diagnosis": "VSAC; Liver Disease"]
  union ["Diagnosis": "VSAC; Hepatitis A"]
  union ["Diagnosis": "VSAC; Hepatitis B"]

define "Denominator":
  AgeInYearsAt(start of "Measurment Period") >= 21
  exists("Denominator Encounter")

define "Denominator Exclusion: Pregnancy"
  /*
   * config_link_id: exclusion_1
   */
  exists("Pregnancy" D
    where D.prevalencePeriod overlaps "Denominator Period")
  or exists("Pregnancy Exclusion" P
    where P.relevantPeriod starts during "Denominator Period")

define "Denominator Exclusion: Rhabdomyolysis"
  /*
   * config_link_id: exclusion_2
   */
  exists(["Diagnosis": "VSAC; Rhabdomyolysis"] D
    where D.prevalencePeriod overlaps "Denominator Period")
  or exists(["Procedure, Performed": "MIPS; Rhabdomyolysis Exclusion"] P
    where P.relevantPeriod starts during "Denominator Period")

define "Numerator Performance Met: G9664":
  /*
   * config_link_id: G9664
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9664"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists("Statin" M
    where M.relevantPeriod overlaps "Measurement Period")

define "Denominator Exception: G9781":
  /*
   * config_link_id: G9781
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9781"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Allergy": "Statin Allergen"] A
    where A.prevalencePeriod overlaps "Measurement Period")
  or exists(["Procedure, Performed": "MIPS; MIPS Hospice Service"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Procedure, Performed": "VSAC; Palliative Care"] P
    where P.relevantPeriod overlaps "Measurement Period")
  or exists("Exception Diganosis" D
    where D.prevalencePeriod overlaps "Measurement Period")

define "Numerator Performance Not Met: G9665":
  /*
   * config_link_id: G9665
   */
  not "Denominator Exclusion: Pregnancy"
  and not "Denominator Exclusion: Rhabdomyolysis"
  and not "Numerator Performance Met: G9664"
  and not "Denominator Exception: G9781"
