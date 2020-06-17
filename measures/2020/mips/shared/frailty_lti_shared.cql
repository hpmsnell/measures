library frailty_lti_shared version '1'

/*
 *
 * Source: MIPS
 * ID:
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; LTI"
valueset "MIPS; Frailty and Dementia Medication"
valueset "MIPS; Frailty and Advanced Illness"

// VSAC value sets

valueset "VSAC; Acute Inpatient": '2.16.840.1.113883.3.464.1003.101.12.1083'
valueset "VSAC; Advanced Illness": '2.16.840.1.113883.3.464.1003.110.12.1082'
valueset "VSAC; Care Services in Long-Term Residential Facility": '2.16.840.1.113883.3.464.1003.101.12.1014'
valueset "VSAC; Dementia Medications": '2.16.840.1.113883.3.464.1003.196.12.1510'
valueset "VSAC; Diabetes": '2.16.840.1.113883.3.464.1003.103.12.1001'
valueset "VSAC; Encounter Inpatient": '2.16.840.1.113883.3.666.5.307'
valueset "VSAC; Frailty Diagnosis": '2.16.840.1.113883.3.464.1003.113.12.1074'
valueset "VSAC; Frailty Encounter": '2.16.840.1.113883.3.464.1003.101.12.1088'
valueset "VSAC; Nonacute Inpatient": '2.16.840.1.113883.3.464.1003.101.12.1084'
valueset "VSAC; Nursing Facility Visit": '2.16.840.1.113883.3.464.1003.101.12.1012'
valueset "VSAC; Observation": '2.16.840.1.113883.3.464.1003.101.12.1086'
valueset "VSAC; Outpatient": '2.16.840.1.113883.3.464.1003.101.12.1087'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Frailty/LTI Exclusion Exists":
  "Frailty/LTI Exclusion Quality Data Code Exists"
  or (
    AgeInYearsAt(start of "Measurement Period") >= 65
    and (
      "Has Spent More Than 90 Days in Long Term Care"
      or (
        "Has Criteria Indicating Frailty"
        and ( Count("Outpatient Encounters with Advanced Illness")>= 2
          or exists( "Inpatient Encounter with Advanced Illness" )
          or exists( "Dementia Medications In Year Before or During Measurement Period")
        )
      )
    )

define "Frailty/LTI Exclusion Quality Data Code Exists":
  exists((["Procedure, Performed": "MIPS; LTI"]
  union ["Procedure, Performed": "MIPS; Frailty and Dementia Medication"]
  union ["Procedure, Performed": "MIPS; Frailty and Advanced Illness"]) FrailtyLTI
    where FrailtyLTI.relevantPeriod starts during "Measurement Period")

define "Has Spent More Than 90 Days in Long Term Care":
  "Days Spent in Long Term Care During Measurement Period" > 90

define "Days Spent in Long Term Care During Measurement Period":
  CumulativeDays("Long Term Care Periods During Measurement Period")

define "Long Term Care Periods During Measurement Period":
  ( ["Encounter, Performed": "VSAC; Care Services in Long-Term Residential Facility"]
  	union ["Encounter, Performed": "VSAC; Nursing Facility Visit"] ) LongTermFacilityEncounter
  	where LongTermFacilityEncounter.relevantPeriod overlaps "Measurement Period"
  	return LongTermFacilityEncounter.relevantPeriod
  		intersect "Measurement Period"

define "Has Criteria Indicating Frailty";
  exists(["Diagnosis": "VSAC; Frailty Diagnosis"] FrailtyDiagnosis
    where FrailtyDiagnosis.prevalencePeriod starts during "Measurement Period"
  )
  or exists (["Encounter, Performed": "VSAC; Frailty Encounter"] FrailtyEncounter
    where FrailtyEncounter.relevantPeriod overlaps "Measurement Period"
  )

define "Outpatient Encounters with Advanced Illness":
  (["Encounter, Performed": "VSAC; Outpatient"]
  union ["Encounter, Performed": "VSAC; Observation"]
  union ["Encounter, Performed": "VSAC; ED"]
  union ["Encounter, Performed": "VSAC; Nonacute Inpatient"]) OutpatientEncounter
    where OutpatientEncounter.relevantPeriod starts 2 years or less before end of "Measurement Period"
    with ["Diagnosis": "VSAC; Advanced Illness"] AdvancedIllness
      such that AdvancedIllness.prevalencePeriod starts during OutpatientEncounter.relevantPeriod


define "Inpatient Encounter with Advanced Illness":
  ["Encounter, Performed": "VSAC; Acute Inpatient"] InpatientEncounter
    where InpatientEncounter.relevantPeriod starts 2 years or less before end of "Measurement Period"
    with ["Diagnosis": "VSAC; Advanced Illness"] AdvancedIllness
      such that AdvancedIllness.prevalencePeriod starts during InpatientEncounter.relevantPeriod

define "Dementia Medications In Year Before or During Measurement Period":
  ["Medication, Prescribed": "VSAC; Dementia Medications"] DementiaMed
    where DementiaMed.relevantPeriod during Interval[start of "Measurement Period" - 1 year, end of "Measurement Period"]

define CumulativeDays(Intervals List<Interval<DateTime>>):
    Sum((collapse Intervals)CollapsedInterval
    		return all duration in days of CollapsedInterval
    )
