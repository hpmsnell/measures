library HEDIS_SPR_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: SPR
 * Year: 2020
 * Version: 1
 * Author: Chana West
 *
  */

using QDM

	include "../shared/hedis_shared" version '1' called HedisShared

// HEDIS value sets

valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; Inpatient Stay": '2.16.840.1.113883.3.464.1004.1395'
valueset "HEDIS; Acute Inpatient": '2.16.840.1.113883.3.464.1004.1810'
valueset "HEDIS; Nonacute Inpatient Stay": '2.16.840.1.113883.3.464.1004.1398'
valueset "HEDIS; COPD": '2.16.840.1.113883.3.464.1004.1053'
valueset "HEDIS; Emphysema": '2.16.840.1.113883.3.464.1004.1091'
valueset "HEDIS; Chronic Bronchitis": '2.16.840.1.113883.3.464.1004.1061'
valueset "HEDIS; Spirometry": '2.16.840.1.113883.3.464.1004.1239'
valueset "HEDIS; Hospice Encounter": '2.16.840.1.113883.3.464.1004.1761'
valueset "HEDIS; Hospice Intervention": '2.16.840.1.113883.3.464.1004.1762'
valueset "HEDIS; Online Assessments": '2.16.840.1.113883.3.464.1004.1446'
valueset "HEDIS; Telehealth Modifier": '2.16.840.1.113883.3.464.1004.1445'
valueset "HEDIS; Telehealth POS": '2.16.840.1.113883.3.464.1004.1460'
valueset "HEDIS; Telephone Visits": '2.16.840.1.113883.3.464.1004.1246'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Outpatient Encounter":
  (["Encounter, Performed": "HEDIS; Outpatient"]
  union ["Encounter, Performed": "HEDIS; Observation"]
  union ["Encounter, Performed": "HEDIS; ED"])Enc
		where not Enc.placeOfService in "HEDIS; Telehealth POS"
			and not Enc.code.modifier in "HEDIS; Telehealth Modifier"
			and not ["Encounter, Performed": "HEDIS; Inpatient Stay"] InptStay
					where Enc.relevantPeriod ends 1 hour or less before start of InptStay.relevantPeriod
// Do not include telehealth AND Do not include outpatient, ED or observation visits that result in an inpatient stay
// While specifications do not include timing reference, used 1hr window because it's both clinically relevant and standard across other eCQMs in CMS programs
// If there is a way to otherwise technically discern when ED or Observation encounters become inpatient encounters, then please do modify

define "Acute Inpatient Encounter":
["Encounter, Performed": "HEDIS; Inpatient Stay"] InptStay
	without ["Encounter, Performed": "HEDIS; Nonacute Inpatient Stay"] NonacuteInptStay
		such that NonacuteInptStay.relevantPeriod starts during InptStay.relevantPeriod

define "Qualifying Encounter":
	"Outpatient Encounter"
	union "Acute Inpatient Encounter"

define "COPD":
  ["Diagnosis": "HEDIS; COPD"]
  union ["Diagnosis": "HEDIS; Emphysema"]
  union ["Diagnosis": "HEDIS; Chronic Bronchitis"]

define "Encounter With COPD":
//Specifications want both acute inpatient encounters with ANY diagnosis of COPD and those with COPD on the discharge claim

	"Qualifying Encounter" QualEnc
    with "COPD" D
      such that D.prevalencePeriod starts during QualEnc.relevantPeriod
			and D.claimID = QualEnc.claimID

define "COPD During Index Period":
//A 12-month window that begins on July 1 of the year prior to the measurement year and ends on June 30 of the measurement year

	"Encounter With COPD" COPDEnc
    where COPDEnc.relevantPeriod starts 6 months or less before start of "Measurement Period"
			or COPDEnc.relevantPeriod starts 6 months or less after start of "Measurement Period"

define "COPD During Index Period Exists":
  exists("COPD During Index Period")

define "First COPD During Index Period":
  First("Encounter With COPD" E
    sort by E.relevantPeriod asc)

define "Negative Diagnosis Outpatient Encounter":
//with or without a telehealth modifier

	(["Encounter, Performed": "HEDIS; Outpatient"]
	union ["Encounter, Performed": "HEDIS; Observation"]
	union ["Encounter, Performed": "HEDIS; ED"]
	union ["Encounter, Performed": "HEDIS; Telephone Visits"]
	union ["Encounter, Performed": "HEDIS; Online Assessments"])Enc
		without ["Encounter, Performed": "HEDIS; Inpatient Stay"] InptStay
			such that Enc.relevantPeriod ends 1 hour or less before start of InptStay.relevantPeriod

define "Negative Diagnosis Qualifying Encounters":
	"Negative Diagnosis Outpatient Encounter"
	union "Acute Inpatient Encounter"

define "Negative Diagnosis Encounter with COPD":
	"Negative Diagnosis Qualifying Encounters" NegQualEnc
		with "COPD" Dx
			such that Dx.prevalencePeriod starts during NegQualEnc.relevantPeriod
			and Dx.claimID = NegQualEnc.claimID

define "First COPD During Index Period Has Prior Diagnosis":
  exists("First COPD During Index Period") E1
    with "Negative Diagnosis Encounter With COPD" E2
      such that E2.relevantPeriod starts 730 days or less before start of E1.relevantPeriod

/* Populations */

define "Exclusion: Hospice":
	   /*
	   * config_link_id: exclusion_required_hospice
	   */
	   exists("Hospice During Period"("Measurement Period"))

define "Denominator":
// Even per 2019 specifications "42 years or older as of December 31 of the measurement year"

  AgeInYearsAt(end of "Measurement Period") >= 42
  and "COPD During Index Period Exists"
  and not "First COPD During Index Period Has Prior Diagnosis"

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
   exists("First COPD During Index Period" FirstIndex
     with ["Assessment, Performed": "HEDIS; Spirometry"] Spirometry
       such that Spirometry.authorDateTime starts 730 days or less before start of FirstIndex.relevantPeriod
			 or Spirometry.authorDateTime starts 180 days after start of FirstIndex.relevantPeriod)


define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
