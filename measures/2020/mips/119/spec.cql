library MIPS_119_2020 version '1'

/*
 * Source: MIPS
 * ID: 119
 * Year: 2017
 * Version: 1
 * Written By: Patrick Clark
 * Reviewed By:
 *
  */

using QDM

include "../shared/frailty_lti_shared" version '1' called FrailtyLTIShared

// Able Custom Value Sets

valueset "ABLE; Microalbumin Test": '2.16.840.1.113883.3.464.1003.109.12.1005'

// MIPS Value Sets

valueset "MIPS; MIPS 119 Encounter"
valueset "MIPS; Diabetes"
valueset "MIPS; MIPS Hospice Service"
valueset "MIPS; Performance Met: 3060F"
valueset "MIPS; Performance Met: 3061F"
valueset "MIPS; Performance Met: 3062F"
valueset "MIPS; Performance Met: 3066F"
valueset "MIPS; Performance Met: G8506"
valueset "MIPS; Performance Not Met: 3060F-8P"
valueset "MIPS; Performance Not Met: 3061F-8P"
valueset "MIPS; Performance Not Met: 3062F-8P"

// VSAC Value Sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'
valueset "VSAC; Urine Protein Tests": '2.16.840.1.113883.3.464.1003.109.12.1024'
valueset "VSAC; Macroalbumin Test": '2.16.840.1.113883.3.464.1003.109.12.1019'
valueset "VSAC; ESRD Monthly Outpatient Services": '2.16.840.1.113883.3.464.1003.109.12.1014'
valueset "VSAC; Dialysis Education": '2.16.840.1.113883.3.464.1003.109.12.1016'
valueset "VSAC; Other Services Related to Dialysis": '2.16.840.1.113883.3.464.1003.109.12.1015'
valueset "VSAC; Dialysis Services": '2.16.840.1.113883.3.464.1003.109.12.1013'
valueset "VSAC; Kidney Transplant": '2.16.840.1.113883.3.464.1003.109.12.1012'
valueset "VSAC; Vascular Access for Dialysis": '2.16.840.1.113883.3.464.1003.109.12.1011'
valueset "VSAC; ACE Inhibitor or ARB": '2.16.840.1.113883.3.526.3.1139'
valueset "VSAC; Diabetic Nephropathy": '2.16.840.1.113883.3.464.1003.109.12.1004'
valueset "VSAC; Glomerulonephritis and Nephrotic Syndrome": '2.16.840.1.113883.3.464.1003.109.12.1018'
valueset "VSAC; Hypertensive Chronic Kidney Disease": '2.16.840.1.113883.3.464.1003.109.12.1017'
valueset "VSAC; Kidney Failure": '2.16.840.1.113883.3.464.1003.109.12.1028'
valueset "VSAC; Proteinuria": '2.16.840.1.113883.3.526.3.1003'

// NCQA value sets

valueset "NCQA; ACE Inhibitor/ARB Medications"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 119 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and AgeInYearsAt(start of E.relevantPeriod) < 75
      and E.signingProvider.hasMeasureMembership = true

define "Denominator":
  exists("Denominator Encounter")
  and exists(["Diagnosis": "MIPS; Diabetes"] D
    where D.prevalencePeriod overlaps "Denominator Period")

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Procedure, Performed": "MIPS; MIPS Hospice Service"] P
    where P.relevantPeriod starts during "Denominator Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Denominator Period")

define "Microalbumin Tests": //Ranges can be found here: https://www.mayoclinic.org/tests-procedures/microalbumin/about/pac-20384640
  ["Laboratory Test, Performed": "ABLE; Microalbumin Test"]
  union ["Laboratory Test, Performed": "VSAC; Urine Protein Tests"]
  union ["Laboratory Test, Performed": "VSAC; Macroalbumin Test"]

define "Eligible Nephropathy Treatments":
  ["Procedure, Performed": "VSAC; Kidney Transplant"]
  union ["Procedure, Performed": "Vascular Access for Dialysis"]
  union ["Procedure, Performed": "Dialysis Services"]
  union ["Intervention, Performed": "Other Services Related to Dialysis"]
  union ["Intervention, Performed": "Dialysis Education"]
  union ["Encounter, Performed": "ESRD Monthly Outpatient Services"]

define "Nephropathy Diagnoses":
  ["Diagnosis": "VSAC; Diabetic Nephropathy"]
  union ["Diagnosis": "VSAC; Glomerulonephritis and Nephrotic Syndrome"]
  union ["Diagnosis": "VSAC; Hypertensive Chronic Kidney Disease"]
  union ["Diagnosis": "VSAC; Kidney Failure"]
  union ["Diagnosis": "VSAC; Proteinuria"]

define "Numerator Performance Met: 3060F":
  /*
   * config_link_id: 3060F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 3060F"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists("Microalbumin Tests" L
    where L.resultDateTime during "Measurement Period"
      and L.result < 30)

define "Numerator Performance Met: 3061F":
  /*
   * config_link_id: 3061F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 3061F"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists("Microalbumin Tests" L
    where L.resultDateTime during "Measurement Period"
      and L.result >= 30
      and L.result <= 300)

define "Numerator Performance Met: 3062F":
  /*
   * config_link_id: 3062F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 3062F"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists("Microalbumin Tests" L
    where L.resultDateTime during "Measurement Period"
      and L.result > 300)

define "Numerator Performance Met: 3066F":
  /*
   * config_link_id: 3066F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 3066F"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists("Eligible Nephropathy Treatments" T
    where T.relevantPeriod starts during "Measurement Period")
  or exists("Nephrology Diagnoses" D
    where D.prevalencePeriod overlaps "Measurement Period")

define "Numerator Performance Met: G8506":
  /*
   * config_link_id: G8506
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8506"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists (["Medication": "VSAC; ACE Inhibitor or ARB"] M
      where M.relevantPeriod overlaps "Measurement Period")
  or exists (["Medication": "NCQA; ACE Inhibitor/ARB Medications"] M
      where M.relevantPeriod overlaps "Measurement Period")

define "Numerator Performance Not Met: 3060F-8P":
  /*
  * config_link_id: 3060F-8P
  */
  exists(["Procedure, Performed": "MIPS; Performance Not Met: 3060F-8P"] P
   where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: 3061F-8P":
  /*
  * config_link_id: 3061F-8P
  */
  exists(["Procedure, Performed": "MIPS; Performance Not Met: 3061F-8P"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exclusion: Frailty/LTI":
  /*
   * config_link_id: exclusion_frailty_lti
   */
  FrailtyLTIShared."Frailty/LTI Exclusion Exists"



define "Numerator Performance Not Met: 3062F-8P":
  /*
   * config_link_id: 3062F-8P
   */
   not "Denominator Exclusion"
   and not "Numerator Performance Met: 3060F"
   and not "Numerator Performance Met: 3061F"
   and not "Numerator Performance Met: 3062F"
   and not "Numerator Performance Met: 3066F"
   and not "Numerator Performance Met: G8506"
   and not "Numerator Performance Not Met: 3060F-8P"
   and not "Numerator Performance Not Met: 3061F-8P"
   and not "Denominator Exclusion: Frailty/LTI"
