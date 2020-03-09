library HEDIS_COL_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: COL
 * Year: 2020
 * Version: 1
 * Author: Chana West
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; History of Total Colectomy or Colorectal Cancer"
valueset "MIPS; Performance Met: 3017F"

// HEDIS value sets

valueset "HEDIS; Hospice": '2.16.840.1.113883.3.464.1004.1418'
valueset "HEDIS; Colorectal Cancer": '2.16.840.1.113883.3.464.1004.1065'
valueset "HEDIS; Total Colectomy": '2.16.840.1.113883.3.464.1004.1250'
valueset "HEDIS; Colonoscopy": '2.16.840.1.113883.3.464.1004.1064'
valueset "HEDIS; History of Colonoscopy": '2.16.840.1.113883.3.464.1004.1910'
valueset "HEDIS; History of Flexible Sigmoidoscopy": '2.16.840.1.113883.3.464.1004.1911'
valueset "HEDIS; History of Total Colectomy": '2.16.840.1.113883.3.464.1004.1912'
valueset "HEDIS; Flexible Sigmoidoscopy": '2.16.840.1.113883.3.464.1004.1102'
valueset "HEDIS; FOBT Lab Test": '2.16.840.1.113883.3.464.1004.1959'
valueset "HEDIS; FOBT Test Result or Finding": '2.16.840.1.113883.3.464.1004.1960'
valueset "HEDIS; CT Colonography": '2.16.840.1.113883.3.464.1004.1421'
valueset "HEDIS; FIT-DNA Lab Test": '2.16.840.1.113883.3.464.1004.1749'
valueset "HEDIS; FIT-DNA Test Result or Finding": '2.16.840.1.113883.3.464.1004.1750'
valueset "HEDIS; Frailty Device": '2.16.840.1.113883.3.464.1004.1530'
valueset "HEDIS; Frailty Diagnosis": '2.16.840.1.113883.3.464.1004.1530'
valueset "HEDIS; Frailty Encounter": '2.16.840.1.113883.3.464.1004.1530'
valueset "HEDIS; Frailty Symptom": '2.16.840.1.113883.3.464.1004.1530'
valueset "HEDIS; Advanced Illness": '2.16.840.1.113883.3.464.1004.1465'
valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; Nonacute Inpatient": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; Nonacute Inpatient Stay": '2.16.840.1.113883.3.464.1004.1398'
valueset "HEDIS; Acute Inpatient": '2.16.840.1.113883.3.464.1004.1810'

// NCQA medication list value sets

valueset "NCQA; Dementia Medications"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Qualifying Exclusion Age":
AgeInYearsAt(end of "Measurement Period") >= 66

define "Hospice":
  ["Intervention, Performed": "HEDIS; Hospice"]

define "Visit":
  ["Encounter, Performed": "HEDIS; Outpatient"]
  union ["Encounter, Performed": "HEDIS; Observation"]
  union ["Encounter, Performed": "HEDIS; ED"]
  union ((["Encounter, Performed": "HEDIS; Nonacute Inpatient"])NonacuteIP
    with (["Encounter, Performed": "HEDIS; Nonacute Inpatient Stay"])NonacuteIPFlag
    such that NonacuteIP.claim_id = NonacuteIPFlag.claim_id)
  union ((["Encounter, Performed": "HEDIS; InpatientStay"])Inpatient
    with (["Encounter, Performed": "HEDIS; Nonacute Inpatient Stay"])NonacuteIPFlag
    such that Inpatient.claim_id = NonacuteIPFlag.claim_id)

define "Visit with Advanced Illness":
  "Visit" ExcludeQualVisit
    where exists (ExcludeQualVisit.diagnoses Diagnosis
      where Diagnosis.code in "HEDIS; Advanced Illness"
      )
       and ExcludeQualVisit.relevantPeriod starts 2 years or less before end of "Measurement Period"

define "Advanced Illness Exists":
  "Qualifying Exclusion Age"
    and (Count("Visit with Advanced Illness")>=2
      or exists(["Encounter, Performed": "HEDIS; Acute Inpatient"] E
        with ["Diagnosis": "HEDIS; Advanced Illness"] D
        such that D.prevalencePeriod starts during E.relevantPeriod)
      or exists(["Medication, Dispensed": "NCQA; Dementia Medications"] M
        where M.relevantPeriod starts during "Measurement Period"))

define "Frailty Diagnosis or Symptoms":
  ((["Diagnosis": "HEDIS; Frailty Diagnosis"]
  union ["Diagnosis": "HEDIS; Frailty Symptom"])FrailDxSx
    where FrailDxSx.prevalencePeriod overlaps "Measurement Period")

define "Frailty Encounter":
  ["Encounter, Performed": "HEDIS; Frailty Encounter"]FrailEnc
    where FrailEnc.relevantPeriod overlaps "Measurement Period"

define "Frailty Device":
  ((["Device, Applied": "HEDIS; Frailty Device"]
  union ["Device, Order": "HEDIS; Frailty Device"]
  union ["Device, Recommended": "HEDIS; Frailty Device"])FrailDevice
    where FrailDevice.relevantPeriod overlaps "Measurement Period"
    or FrailDevice.authorDatetime during "Measurement Period")

define "Frailty":
  "Frailty Diagnosis or Symptoms"
  union "Frailty Encounter"
  union "Frailty Device"

/* POPULATIONS */

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 51
  and AgeInYearsAt(end of "Measurement Period") < 76
  and not exists("Hospice" I
    where I.relevantPeriod starts during "Measurement Period")

define "Denominator Exclusion: Colectomy or Cancer":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Diagnosis": "HEDIS; Colorectal Cancer"] D
    where D.prevalencePeriod starts before end of "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; Colorectal Cancer"] P
    where P.relevantPeriod starts before end of "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; Total Colectomy"] P
    where P.relevantPeriod starts before end of "Measurement Period")
  or exists(["Procedure, Performed": "MIPS; History of Total Colectomy or Colorectal Cancer"] P
    where P.relevantPeriod starts before end of "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; History of Total Colectomy"] P
    where P.relevantPeriod starts before end of "Measurement Period")
  or exists(["Diagnosis": "HEDIS; History of Total Colectomy"] D
    where D.prevalencePeriod starts before end of "Measurement Period")


define "Denominator Exclusion: Frailty or Advanced Illness":
  /*
   * config_link_id: exclusion_2
   */

  "Advanced Illness Exists"
    and exists("Frailty")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists(["Procedure, Performed": "HEDIS; Colonoscopy"] P where P.relevantPeriod starts 10 years or less before end of "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; Flexible Sigmoidoscopy"] P where P.relevantPeriod starts 5 years or less before end of "Measurement Period")
  or exists(["Laboratory Test, Performed": "HEDIS; FOBT Lab Test"] FOBTLab where FOBTLab.relevantPeriod during "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; FOBT Lab Test"] FOBTLab where FOBTLab.relevantPeriod during "Measurement Period")
  or exists(["Laboratory Test, Performed": "HEDIS; FOBT Test Result or Finding"] FOBTLabResult where FOBTLabResult.resultDateTime during "Measurement Period")
  or exists(["Laboratory Test, Performed": "HEDIS; FIT-DNA Lab Test"] FITLab where FITLab.relevantDateTime 3 years or less before end of "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; FIT-DNA Lab Test"] FITLab where FitLab.relevantPeriod 3 years or less before end of "Measurement Period")
  or exists(["Laboratory Test, Performed": "HEDIS; FIT-DNA Test Result or Finding"] FITLabResult where FITLabResult.resultDateTime 3 years or less before end of "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; CT Colonography"] L where L.relevantPeriod starts 5 years or less before end of "Measurement Period")
  or exists(["Procedure, Performed": "MIPS; Performance Met: 3017F"] P where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion: Colectomy or Cancer"
  and not "Denominator Exclusion: Frailty or Advanced Illness"
  and not "Numerator Performance Met"
