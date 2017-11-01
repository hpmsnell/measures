library MIPS_438Rate3_2017 version '1'

/*
 *
 * Source: MIPS
 * ID: 438Rate3
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 438 Encounter"
valueset "MIPS; Performance Met: G9664"
valueset "MIPS; Denominator Exception: G9781"
valueset "MIPS; Performance Not Met: G9665"
valueset "MIPS; MIPS 238 Diabetes"
valueset "MIPS; LDL 70-189 mg/dL"
valueset "MIPS; Pregnancy Exclusion"
valueset "MIPS; Breastfeeding Exclusion"
valueset "MIPS; Rhabdomyolysis Exclusion"
valueset "MIPS; MIPS Hospice Service"

// VSAC value sets

valueset "VSAC; LDL Test": '2.16.840.1.113883.3.464.1003.198.11.1029'
valueset "VSAC; Pregnancy Dx": '2.16.840.1.113883.3.600.1.1623'
valueset "VSAC; Breastfeeding": '2.16.840.1.113762.1.4.1047.73'
valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'
valueset "VSAC; Rhabdomyolysis": '2.16.840.1.113762.1.4.1047.102'
valueset "VSAC; Low intensity statin therapy": '2.16.840.1.113762.1.4.1047.107'
valueset "VSAC; Moderate intensity statin therapy": '2.16.840.1.113762.1.4.1047.98'
valueset "VSAC; High intensity statin therapy": '2.16.840.1.113762.1.4.1047.97'
valueset "VSAC; Statin Allergen": '2.16.840.1.113883.3.117.1.7.1.423'
valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'
valueset "VSAC; End Stage Renal Disease": '2.16.840.1.113883.3.526.3.353'
valueset "VSAC; Liver Disease": '2.16.840.1.113762.1.4.1047.42'
valueset "VSAC; Hepatitis A": '2.16.840.1.113883.3.464.1003.110.12.1024'
valueset "VSAC; Hepatitis B": '2.16.840.1.113883.3.67.1.101.1.269'

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 438 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ', 'GT'}
    with ["Diagnosis": "MIPS 428 Diabetes"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "LDL Lab Exists":
  exists(["Laboratory Test, Performed": "VSAC; LDL Test"] L
    where L.result >= 70
      and L.result <= 189
      and L.resultDateTime in Interval[2 years before start of "Measurement Period", end of "Measurement Period"]
  and not exists(["Laboratory Test, Performed": "VSAC; LDL Test"] L
    where L.result > 189
      and L.resultDateTime in Interval[2 years before start of "Measurement Period", end of "Measurement Period"]

define "LDL 70-189 Exists":
  exists(["Procedure, Performed": "MIPS: LDL 70-189 mg/dL"] P
    where P.relevantPeriod starts during "Denominator Period")
  or "LDL Lab Exists"

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
  AgeInYearsAt(start of "Measurement Period") >= 40
  and AgeInYearsAt(start of "Measurement Period") <= 75
  and exists("Denominator Encounter")
  and "LDL 70-189 Exists"

define "Denominator Exclusion: Pregnancy"
  /*
   * config_link_id: exclusion_1
   */
  exists("Pregnancy" D
    where D.prevalencePeriod overlaps "Measurement Period")
  or exists("Pregnancy Exclusion" P
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exclusion: Rhabdomyolysis"
  /*
   * config_link_id: exclusion_2
   */
  exists(["Diagnosis": "VSAC; Rhabdomyolysis"] D
    where D.prevalencePeriod overlaps "Measurement Period")
  or exists(["Procedure, Performed": "MIPS; Rhabdomyolysis Exclusion"] P
    where P.relevantPeriod starts during "Measurement Period")

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

define "Denominator Exception: G9783":
  /*
   * config_link_id: G9783
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9783"] P
    where P.relevantPeriod starts during "Measurement Period")
  or Last(["Laboratory Test, Performed": "VSAC; LDL Test"]).result < 70

define "Numerator Performance Not Met: G9665":
  /*
   * config_link_id: G9665
   */
  not "Denominator Exclusion: Pregnancy"
  and not "Denominator Exclusion: Rhabdomyolysis"
  and not "Numerator Performance Met: G9664"
  and not "Denominator Exception: G9781"
  and not "Denominator Exception: G9783"
