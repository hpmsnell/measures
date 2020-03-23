library hedis_shared version '1'

/*
 *
 * Source: HEDIS
 * ID:
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

/*
Supports:
  - Hospice
  - Frailty (general without age qualification)

To do:
  - LTI
*/

using QDM

valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; Nonacute Inpatient": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; Acute Inpatient": '2.16.840.1.113883.3.464.1004.1017'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'

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

valueset "Ab;e; LTI": ''

parameter "Measurement Period" Interval<DateTime>

context Patient

/*--------------------------------------------------
HOSPICE
----------------------------------------------------*/
define "Hospice":
  ["Intervention, Performed": "HEDIS; Hospice Intervention"]
  union ["Encounter, Performed": "HEDIS; Hospice Encounter"]


/*--------------------------------------------------
SNP
–	Enrolled in an Institutional SNP (I-SNP)
----------------------------------------------------*/
//TODO: implement SNP


/*--------------------------------------------------
LTI
–	Living long-term in an institution ... as identified by the LTI flag in the Monthly Membership Detail Data File.
  Use the run date of the file to determine if a member had an LTI flag (during requested period)
----------------------------------------------------*/
//TODO: implement LTI


/*--------------------------------------------------
ADVANCED ILLNESS
----------------------------------------------------*/
define "Advanced Illness Visit":
  ["Encounter, Performed": "HEDIS; Outpatient"]
  union ["Encounter, Performed": "HEDIS; Observation"]
  union ["Encounter, Performed": "HEDIS; ED"]
  union ["Encounter, Performed": "HEDIS; Nonacute Inpatient"]

define function "Advanced Illness Visit with Advanced Illness"(Period Interval<DateTime>):
  "Visit" E
     with ["Diagnosis": "HEDIS; Advanced Illness"] D
      such that D.prevalencePeriod starts during E.relevantPeriod
        where E.relevantPeriod starts during Period

define function "Advanced Illness Exists During Period"(Period Interval<DateTime>) returns Boolean:
   exists(
      "Advanced Illness Visit with Advanced Illness"(Period) E1
      with "Advanced Illness Visit with Advanced Illness"(Period) E2
        such that E1.relevantPeriod starts after E2.relevantPeriod
  )
  or exists(
    ["Encounter, Performed": "HEDIS; Acute Inpatient"] E
    with ["Diagnosis": "HEDIS; Advanced Illness"] D
      such that D.prevalencePeriod starts during E.relevantPeriod
  )
  or exists(
    ["Medication, Dispensed": "NCQA; Dementia Medications"] M
    where M.relevantPeriod starts during Period
  )

/*--------------------------------------------------
FRAILTY
----------------------------------------------------*/
//TODO: implement FRAILTY

//Frailty Device, Diagnosis, Encounter, Symptom
define "Frailty Device, Diagnosis, Encounter, Symptom":
  ["Diagnosis": "HEDIS; Frailty Device"] D
  union ["Diagnosis": "HEDIS; Frailty Diagnosis"] D2
  union ["Procedure, Performed": "HEDIS; Frailty Encounter"] D3
  union ["Procedure, Performed": "HEDIS; Frailty Symptom"] D4

define function "Frailty Device, Diagnosis, Encounter, Symptom During Period"(Period Interval<DateTime>) returns Boolean:
  exists (
    "Frailty Device, Diagnosis, Encounter, Symptom" D
      where D.prevalencePeriod starts during Period
      or D.relevantPeriod starts during Period
    )
