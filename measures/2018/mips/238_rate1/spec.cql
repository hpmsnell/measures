library MIPS_238Rate2_2017 version '1'

/*
 * Source: MIPS
 * ID: 238 Rate 2
 * Year: 2018
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 238 Encounter"
valueset "MIPS; Hospice Service"
valueset "MIPS; Performance Met: G9365"
valueset "MIPS; Performance Not Met: G9366"

// VSAC value sets

valueset "VSAC; Palliative Care": 'urn:oid:2.16.840.1.113883.3.600.1.1579'
valueset "VSAC; High Risk Medications for the Elderly": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1253'
valueset "VSAC; High-Risk Medications With Days Supply Criteria": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1254'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 238 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 65
      and E.signingProvider.hasMeasureMembership = true

define "Hospice":
  ["Intervention, Performed": "MIPS; MIPS Hospice Service"]
  union ["Intervention, Performed": "VSAC; Palliative Care"]

define "Order For High Risk Medication":
	["Medication, Order": "VSAC; High Risk Medications for the Elderly"] HighRiskMedicationOrder
		where HighRiskMedicationOrder.authorDatetime during "Measurement Period"

define "High Risk Medications With Prolonged Duration":
	["Medication, Order": "VSAC; High-Risk Medications With Days Supply Criteria"] HighRiskMedicationOrder
		where duration in days of HighRiskMedicationOrder.relevantPeriod >= 90
			and end of "Measurement Period" - start of HighRiskMedicationOrder.relevantPeriod >= 90

/* Populations */

define "Denominator":
	exists("Denominator Encounter")

define "Denominator Exclusion":
  exists("Hospice" E
    where E.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: G9365":
	exists ( "Order For High Risk Medication" )
	or exists ( "High Risk Medications With Prolonged Duration" )
  or exists(["Procedure, Performed": "MIPS; Performance Met: G9365"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: G9366":
	not "Denominator Exclusion"
  and not "Numerator Performance Met: G9365"
