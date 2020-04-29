library hedis_shared version '1'

/*
 *
 * Source: HEDIS
 * ID:
 * Year: 2020
 * Version: 1
 * Author: Eric Whitley
 *
  */

/*
Supports:
  - Hospice
  - SNP: Enrolled in an Institutional SNP (I-SNP)
  - LTI: Living long-term in an institution
  - Frailty (general without age qualification)
  - Advanced Illness
*/

using QDM

valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; Nonacute Inpatient": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; Acute Inpatient": '2.16.840.1.113883.3.464.1004.1017'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'

valueset "HEDIS; Inpatient Stay": '2.16.840.1.113883.3.464.1004.1395'
valueset "HEDIS; Nonacute Inpatient Stay": '2.16.840.1.113883.3.464.1004.1398'

valueset "HEDIS; Hospice Encounter": '2.16.840.1.113883.3.464.1004.1761'
valueset "HEDIS; Hospice Intervention": '2.16.840.1.113883.3.464.1004.1762'
valueset "HEDIS; Well-Care": '2.16.840.1.113883.3.464.1004.1262'
valueset "HEDIS; Telehealth POS": '2.16.840.1.113883.3.464.1004.1460'
valueset "HEDIS; Telehealth Modifier": '2.16.840.1.113883.3.464.1004.1445'
valueset "HEDIS; Advanced Illness": '2.16.840.1.113883.3.464.1004.1465'

valueset "NCQA; Dementia Medications": '' //FIXME: add OID

valueset "HEDIS; Frailty Device": '2.16.840.1.113883.3.464.1004.1530'
valueset "HEDIS; Frailty Diagnosis": '2.16.840.1.113883.3.464.1004.1531'
valueset "HEDIS; Frailty Encounter": '2.16.840.1.113883.3.464.1004.1532'
valueset "HEDIS; Frailty Symptom": '2.16.840.1.113883.3.464.1004.1533'

valueset "Able; MMDF LTI": ''
valueset "Able; MMDF Hospice": ''

parameter "Measurement Period" Interval<DateTime>

context Patient

/*--------------------------------------------------
HOSPICE
----------------------------------------------------*/
define "Hospice":
  (["Intervention, Performed": "HEDIS; Hospice Intervention"]
  union ["Intervention, Performed": "Able; MMDF Hospice"]
  union ["Encounter, Performed": "HEDIS; Hospice Encounter"]) Hospice
  where Hospice.placeOfService != '81'

define function "Hospice During Period"(Period Interval<DateTime>):
  exists(
    "Hospice" H
      where H.relevantPeriod starts during Period
  )

/*--------------------------------------------------
SNP
–	Enrolled in an Institutional SNP (I-SNP)
----------------------------------------------------*/
define "SNP"(Period Interval<DateTime>):
  exists
    ["Payer": "ALL PAYERS"] payer //ALL payers, don't restrict by value set
    where
      payer.value = 'SN2'
      and payer.startDate <= end of Period
      and (
          payer.endDate >= start of Period
          or payer.endDate is null
        )

/*--------------------------------------------------
LTI
–	Living long-term in an institution ... as identified by the LTI flag in the Monthly Membership Detail Data File.
  Use the run date of the file to determine if a member had an LTI flag (during requested period)
----------------------------------------------------*/
define function "LTI During Period"(Period Interval<DateTime>):
  exists(
    ["Intervention, Performed": "Able; MMDF LTI"] LTI
      where LTI.relevantPeriod starts during Period
  )


/*--------------------------------------------------
FRAILTY
----------------------------------------------------*/

define function "Frailty: Diagnosis or Symptoms During Period"(Period Interval<DateTime>):
  ((["Diagnosis": "HEDIS; Frailty Diagnosis"]
  union ["Diagnosis": "HEDIS; Frailty Symptom"])FrailDxSx
    where FrailDxSx.prevalencePeriod starts during Period)
      and FrailDxSx.supplemental = false
      and FrailDxSx.placeOfService != '81'


define function "Frailty: Encounter During Period"(Period Interval<DateTime>):
  ["Encounter, Performed": "HEDIS; Frailty Encounter"]FrailEnc
    where FrailEnc.relevantPeriod starts during Period
      and FrailEnc.supplemental = false
      and FrailEnc.placeOfService != '81'

define function "Frailty: Device During Period"(Period Interval<DateTime>):
  (["Device, Applied": "HEDIS; Frailty Device"]
  union ["Device, Order": "HEDIS; Frailty Device"]
  union ["Device, Recommended": "HEDIS; Frailty Device"])FrailDevice
    where FrailDevice.relevantPeriod starts during Period
      and FrailDevice.supplemental = false
      and FrailDevice.placeOfService != '81'

/*
  At least one claim/encounter for frailty (Frailty Device Value Set; Frailty Diagnosis Value Set; Frailty Encounter Value Set; Frailty Symptom Value Set)
  during specified period
*/
define function "Frailty: Claim During Period"(Period Interval<DateTime>) returns Boolean:
    exists "Frailty: Diagnosis or Symptoms During Period"(Period)
    or exists "Frailty: Encounter During Period"(Period)
    or exists "Frailty: Device During Period"(Period)



/*--------------------------------------------------
ADVANCED ILLNESS
--------------------------------------------------*/

/*
–	outpatient visits (Outpatient Value Set), observation visits (Observation Value Set),
- ED visits (ED Value Set),
- nonacute inpatient encounters (Nonacute Inpatient Value Set)
- or nonacute inpatient discharges (instructions below)
... with an advanced illness diagnosis (Advanced Illness Value Set)...

To identify a nonacute inpatient discharge:
1.	Identify all acute and nonacute inpatient stays (Inpatient Stay Value Set).
2.	Confirm the stay was for nonacute care based on the presence of a nonacute code (Nonacute Inpatient Stay Value Set) on the claim.
3.	Identify the discharge date for the stay.
----------------------------------------------------*/
define function "Advanced Illness: Visit During Period"(Period Interval<DateTime>):
    ("Advanced Illness: Visit During Period - Outpatient, Obs, ED, Non-Acute Inpatient Encounters"(Period))Visits
    union ("Advanced Illness: Non-Acute Inpatient DISCHARGE During Period"(Period))Visits

/*
most visits - EXCLUDING non-acute inpatient DISCHARGES
–	outpatient visits (Outpatient Value Set), observation visits (Observation Value Set),
- ED visits (ED Value Set),
- nonacute inpatient encounters (Nonacute Inpatient Value Set)
... with an advanced illness diagnosis (Advanced Illness Value Set)...
*/
define function "Advanced Illness: Visit During Period - Outpatient, Obs, ED, Non-Acute Inpatient Encounters"(Period Interval<DateTime>):
    //outpatient visits (Outpatient Value Set)
    //observation visits (Observation Value Set)
    //ED visits (ED Value Set)
    //nonacute inpatient encounters (Nonacute Inpatient Value Set)
    (["Encounter, Performed": "HEDIS; Outpatient"]
      union ["Encounter, Performed": "HEDIS; Observation"]
      union ["Encounter, Performed": "HEDIS; ED"]
      union ["Encounter, Performed": "HEDIS; Nonacute Inpatient"]
    ) QualifyingEncounters
      with ["Diagnosis": "HEDIS; Advanced Illness"] D
        such that D.claimId = QualifyingEncounters.claimId
        or (
          end of QualifyingEncounters.relevantPeriod != null
          and start of D.prevalencePeriod during QualifyingEncounters.relevantPeriod
        )
        or (
          QualifyingEncounters.stopDate = null
          and start of D.prevalencePeriod same day as start of QualifyingEncounters.relevantPeriod
        )
      where QualifyingEncounters.relevantPeriod starts during Period
        and Diagnosis.supplemental = false
        and Diagnosis.placeOfService != '81'
        and QualifyingEncounters.supplemental = false
        and QualifyingEncounters.placeOfService != '81'

/*
To identify a nonacute inpatient discharge:
1.	Identify all acute and nonacute inpatient stays (Inpatient Stay Value Set).
2.	Confirm the stay was for nonacute care based on the presence of a nonacute code (Nonacute Inpatient Stay Value Set) on the claim.
3.	Identify the discharge date for the stay.
*/
define function "Advanced Illness: Non-Acute Inpatient DISCHARGE During Period"(Period Interval<DateTime>):
  (
    //nonacute inpatient discharges
    ((["Encounter, Performed": "HEDIS; Inpatient Stay"])Inpatient
      with (["Encounter, Performed": "HEDIS; Nonacute Inpatient Stay"])NonacuteIPFlag
        such that Inpatient.claimId = NonacuteIPFlag.claimId
          where Inpatient.dischargeDate during Period //NOTE: we're filtering by DISCHARGE DATE here
          and Inpatient.placeOfService != '81'
      )
  ) QualifyingEncounters
  with ["Diagnosis": "HEDIS; Advanced Illness"] D
    such that D.claimId = QualifyingEncounters.claimId
    or (
      end of QualifyingEncounters.relevantPeriod != null
      and start of D.prevalencePeriod during QualifyingEncounters.relevantPeriod
    )
    or (
      QualifyingEncounters.stopDate = null
      and start of D.prevalencePeriod same day as start of QualifyingEncounters.relevantPeriod
    )
  where Diagnosis.supplemental = false
    and Diagnosis.placeOfService != '81'
    and QualifyingEncounters.supplemental = false
    and QualifyingEncounters.placeOfService != '81'

/*
–	At least one acute inpatient encounter (Acute Inpatient Value Set)
  with an advanced illness diagnosis (Advanced Illness Value Set).
*/
define function "Advanced Illness: Acute Inpatient Encounter During Period"(Period Interval<DateTime>):
  ["Encounter, Performed": "HEDIS; Acute Inpatient"] QualifyingEncounters
  with ["Diagnosis": "HEDIS; Advanced Illness"] D
    such that D.claimId = QualifyingEncounters.claimId
    or (
      end of QualifyingEncounters.relevantPeriod != null
      and start of D.prevalencePeriod during QualifyingEncounters.relevantPeriod
    )
    or (
      QualifyingEncounters.stopDate = null
      and start of D.prevalencePeriod same day as start of QualifyingEncounters.relevantPeriod
    )
  where
    Diagnosis.supplemental = false
    and Diagnosis.placeOfService != '81'
    and QualifyingEncounters.supplemental = false
    and QualifyingEncounters.relevantPeriod starts during Period
    and QualifyingEncounters.placeOfService != '81'

/*
//–	Acute inpatient DISCHARGE with an advanced illness diagnosis (Advanced Illness Value Set)
–	At least one acute inpatient discharge with an advanced illness diagnosis (Advanced Illness Value Set).
To identify an acute inpatient discharge:
1.	Identify all acute and nonacute inpatient stays (Inpatient Stay Value Set).
2.	Exclude nonacute inpatient stays (Nonacute Inpatient Stay Value Set).
3.	Identify the discharge date for the stay.
*/
define function "Advanced Illness: Acute Inpatient DISCHARGE During Period"(Period Interval<DateTime>):
  ["Encounter, Performed": "HEDIS; Inpatient Stay"] QualifyingEncounters
  with ["Diagnosis": "HEDIS; Advanced Illness"] D
    such that D.claimId = QualifyingEncounters.claimId
    or (
      end of QualifyingEncounters.relevantPeriod != null
      and start of D.prevalencePeriod during QualifyingEncounters.relevantPeriod
    )
    or (
      QualifyingEncounters.stopDate = null
      and start of D.prevalencePeriod same day as start of QualifyingEncounters.relevantPeriod
    )
  where
    Diagnosis.supplemental = false
    and Diagnosis.placeOfService != '81'
    and QualifyingEncounters.supplemental = false
    and QualifyingEncounters.dischargeDate during Period
    and QualifyingEncounters.placeOfService != '81'
    and not exists (
      //There will be secondary non-acute inpatient Encounters
      //we have find ONLY the encounters where there is NOT
      //a related non-acute stay on the same claim
      ["Encounter, Performed": "HEDIS; Nonacute Inpatient Stay"] Nonacute
      such that QualifyingEncounters.claimId = Nonacute.claimId
    )

/*
–	At least two outpatient visits ...
  on different dates of service, with an advanced illness diagnosis
*/
define function "Advanced Illness: Count of Distinct Visit Dates During Period"(Period Interval<DateTime>): //returns Integer:
  Count(distinct((((
       "Advanced Illness: Visit During Period"(Period)
  ).relevantPeriod) start) date))

// A dispensed dementia medication (Dementia Medications List).
define function "Advanced Illness: Dementia Medication During Period"(Period Interval<DateTime>):
  ["Medication, Dispensed": "NCQA; Dementia Medications"] M
  where M.relevantPeriod starts during Period
    and M.supplemental = false

define function "Advanced Illness"(Period Interval<DateTime>) returns Boolean:
    // At least two outpatient visits...
    ("Advanced Illness: Count of Distinct Visit Dates During Period"(Period)) >= 2
    // At least one acute inpatient ENCOUNTER (Acute Inpatient Value Set) with an advanced illness diagnosis (Advanced Illness Value Set).
    or exists("Advanced Illness: Acute Inpatient Encounter During Period"(Period))
    //At least one acute inpatient DISCHARGE with an advanced illness diagnosis (Advanced Illness Value Set).
    or exists ("Advanced Illness: Acute Inpatient DISCHARGE During Period"(Period))
    // A dispensed dementia medication (Dementia Medications List).
    or exists("Advanced Illness: Dementia Medication During Period"(Period))
