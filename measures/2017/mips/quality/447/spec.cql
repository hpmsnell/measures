library MIPS_447_2017 version '1'

/*
 * Source: MIPS
 * ID: 447
 * Year: 2017
 * Version: 1
 * Written By: Steve Daniels
 * Reviewed By: Rachel Katz
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 447 Encounter"
valueset "MIPS; Sexual Activity"
valueset "MIPS; MIPS Hospice Service"
valueset "MIPS; Performance Met: G9820"
valueset "MIPS; Performance Not Met: G9821"

// VSAC Value Sets

valueset "VSAC; Female": '2.16.840.1.113883.3.560.100.2'
valueset "VSAC; Other Female Reproductive Conditions": '2.16.840.1.113883.3.464.1003.111.12.1006'
valueset "VSAC; Genital Herpes": '2.16.840.1.113883.3.464.1003.110.12.1049'
valueset "VSAC; Gonococcal Infections and Venereal Diseases": '2.16.840.1.113883.3.464.1003.112.12.1001'
valueset "VSAC; Contraceptive Medications": '2.16.840.1.113883.3.464.1003.196.12.1080'
valueset "VSAC; Inflammatory Diseases of Female Reproductive Organs": '2.16.840.1.113883.3.464.1003.112.12.1004'
valueset "VSAC; Chlamydia": '2.16.840.1.113883.3.464.1003.112.12.1003'
valueset "VSAC; HIV": '2.16.840.1.113883.3.464.1003.120.12.1003'
valueset "VSAC; Syphilis": '2.16.840.1.113883.3.464.1003.112.12.1002'
valueset "VSAC; Complications of Pregnancy, Childbirth and the Puerperium": '2.16.840.1.113883.3.464.1003.111.12.1012'
valueset "VSAC; Pregnancy Test": '2.16.840.1.113883.3.464.1003.111.12.1011'
valueset "VSAC; Pap Test": '2.16.840.1.113883.3.464.1003.108.12.1017'
valueset "VSAC; Delivery Live Births": '2.16.840.1.113883.3.464.1003.111.12.1015'
valueset "VSAC; Lab Tests During Pregnancy": '2.16.840.1.113883.3.464.1003.111.12.1007'
valueset "VSAC; Lab Tests for Sexually Transmitted Infections": '2.16.840.1.113883.3.464.1003.110.12.1051'
valueset "VSAC; Diagnostic Studies During Pregnancy": '2.16.840.1.113883.3.464.1003.111.12.1008'
valueset "VSAC; Procedures During Pregnancy": '2.16.840.1.113883.3.464.1003.111.12.1009'
valueset "VSAC; Procedures Involving Contraceptive Devices": '2.16.840.1.113883.3.464.1003.111.12.1010'
valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'
valueset "VSAC; Chlamydia Screening": '2.16.840.1.113883.3.464.1003.110.12.1052'

// Able Value Sets

valueset "Able; Chlamydia Medication"
valueset "Able; STI Referral"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Prior Year": Interval[12 months before start of "Measurement Period", 12 months before end of "Measurement Period")

define "Denominator Encounter in Measurement Year":
  ["Encounter, Performed": "MIPS; MIPS 447 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true

define "Denominator Encounter in Prior Year":
  ["Encounter, Performed": "MIPS; MIPS 447 Encounter"] E
    where E.relevantPeriod starts during "Prior Year"
      and E.signingProvider.hasMeasureMembership = true

define "Sexual Activity Exists":
  exists("Sexual Activity Medication" P
    where P.relevantPeriod overlaps "Measurement Period")
  or exists("Sexual Activity Procedure" E
    where E.relevantPeriod starts during "Measurement Period")
  or exists("Sexual Activity Lab Test" E
    where E.resultDateTime during "Measurement Period")

define "Sexual Activity Medication":
  ["Medication, Active": "VSAC; Contraceptive Medications"]

define "Sexual Activity Diagnosis":
  union ["Diagnosis": "VSAC; Other Female Reproductive Conditions"]
  union ["Diagnosis": "VSAC; Genital Herpes"]
  union ["Diagnosis": "VSAC; Gonococcal Infections and Venereal Diseases"]
  union ["Diagnosis": "VSAC; Inflammatory Diseases of Female Reproductive Organs"]
  union ["Diagnosis": "VSAC; Chlamydia"]
  union ["Diagnosis": "VSAC; HIV"]
  union ["Diagnosis": "VSAC; Syphilis"]
  union ["Diagnosis": "VSAC; Complications of Pregnancy, Childbirth and the Puerperium"]

define "Sexual Activity Procedure":
  ["Procedure, Performed": "MIPS; Sexual Activity"]
  union ["Procedure, Performed": "VSAC; Delivery Live Births"]
  union ["Procedure, Performed": "VSAC; Procedures Involving Contraceptive Devices"]
  union ["Diagnostic Study, Performed": "VSAC; Diagnostic Studies During Pregnancy"]
  union ["Laboratory Test, Performed": "VSAC; Procedures During Pregnancy"]

define "Sexual Activity Lab Test":
  ["Laboratory Test, Performed": "VSAC; Pregnancy Test"]
  union ["Laboratory Test, Performed": "VSAC; Pap Test"]
  union ["Laboratory Test, Performed": "VSAC; Lab Tests During Pregnancy"]
  union ["Laboratory Test, Performed": "VSAC; Lab Tests for Sexually Transmitted Infections"]

define "Positive Chlamydia Screening with Follow-Up Exists":
  exists("Positive Chlamydia Screening":)
  and "Chlamydia Follow-Up Exists"

define "Chlamydia Screening":
  ["Laboratory Test, Performed": "VSAC; Chlamydia Screening"] L
    where L.resultDateTime starts during "Measurement Period"

define "Positive Chlamydia Screening":
  ["Laboratory Test, Performed": "VSAC; Chlamydia Screening"] L
    where L.resultDateTime starts during "Measurement Period"
      and L.result = 'positive'

define "Chlamydia Follow-Up Exists":
  exists("Chlamydia Screening" L2
    with "Positive Chlamydia Screening" L1
      such that L2.resultDateTime 30 days or less after L1.resultDateTime)
  or exists(["Medication": "Able; Chlamydia Medication"] M
    with "Positive Chlamydia Screening" L
      such that M.relevantPeriod starts 30 days or less after L.resultDateTime)
  or exists(["Procedure, Performed": "Able; STI Referral"] P
    with "Positive Chlamydia Screening" L
      such that P.relevantPeriod starts 30 days or less after L.resultDateTime)

define "Denominator":
  exists("Denominator Encounter in Measurement Year")
  and exists("Denominator Encounter in Prior Year")
  and AgeInYearsAt(end of "Measurement Period") = 16
  and "Patient Characteristic Sex" in "VSAC; Female"
  and "Sexual Activity Exists"

define "Denominator Exclusion":
/*
 * config_link_id: exclusion
 */
exists(["Procedure, Performed": "MIPS; MIPS Hospice Service"] P
  where P.relevantPeriod starts during "Measurement Period")
or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
  where I.relevantPeriod overlaps "Measurement Period")

define "Numerator Performance Met: G9820":
  /*
   * config_link_id: G9820
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9820"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Laboratory Test, Performed": "VSAC; Chlamydia Screening"] L
    where L.resultDateTime starts during "Measurement Period"
      and L.result = 'negative')
  or "Positive Chlamydia Screening with Follow-Up Exists"

define "Numerator Performance Not Met: G9821":
  /*
   * config_link_id: G9821
   */
   not "Numerator Performance Met: G9820"
