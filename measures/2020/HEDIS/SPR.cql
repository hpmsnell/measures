library HEDIS_SPR_2020

/*
 *
 * Source: HEDIS
 * ID: SPR
 * Year: 2020
 * Version: 1
 * Author: Patrick Clark
 *
  */

using ADM v1

	include "../shared/hedis_shared"  called HedisShared

// HEDIS value sets

valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; INPATIENT_STAY": '2.16.840.1.113883.3.464.1004.1395'
valueset "HEDIS; ACUTE_INPATIENT": '2.16.840.1.113883.3.464.1004.1810'
valueset "HEDIS; NONACUTE_INPATIENT_STAY": '2.16.840.1.113883.3.464.1004.1398'
valueset "HEDIS; COPD": '2.16.840.1.113883.3.464.1004.1053'
valueset "HEDIS; EMPHYSEMA": '2.16.840.1.113883.3.464.1004.1091'
valueset "HEDIS; CHRONIC_BRONCHITIS": '2.16.840.1.113883.3.464.1004.1061'
valueset "HEDIS; SPIROMETRY": '2.16.840.1.113883.3.464.1004.1239'
valueset "HEDIS; ONLINE_ASSESSMENTS": '2.16.840.1.113883.3.464.1004.1446'
valueset "HEDIS; TELEHEALTH_MODIFIER": '2.16.840.1.113883.3.464.1004.1445'
valueset "HEDIS; TELEHEALTH_POS": '2.16.840.1.113883.3.464.1004.1460'
valueset "HEDIS; TELEPHONE_VISITS": '2.16.840.1.113883.3.464.1004.1246'

parameter "Measurement Period" Interval<DateTime>

context Patient

/* Populations */

define "Initial Population":
	AgeInYearsAt(end of "Measurement Period") >= 42

define "Denominator":
// Even per 2020 specifications "42 years or older as of December 31 of the measurement year"
	"Initial Population"
  and "COPD During Index Period Exists"
  and not "First COPD During Index Period Has Prior Diagnosis"

define "Exclusion: Hospice":
	   /*
	   * Option ID: exclusion_required_hospice
	   */
	   exists("Hospice During Period"("Measurement Period"))

define "Numerator Performance Met":
  /*
   * Option ID: performance_met
   */
  exists("First COPD During Index Period" FirstIndex
    with ["Clinical Activity": "HEDIS; SPIROMETRY"] Spirometry
     such that Spirometry.authorDate starts 730 days or less before FirstIndex.start_date
			or Spirometry.authorDate starts 180 days after FirstIndex.start_date)


define "Numerator Performance Not Met":
  /*
   * Option ID: performance_not_met
   */
  not "Numerator Performance Met"

// Definitions

define "Outpatient Encounter":
  (["Clinical Activity": "HEDIS; OUTPATIENT"]
  union ["Clinical Activity": "HEDIS; OBSERVATION"]
  union ["Clinical Activity": "HEDIS; ED"]
	union ["Clinical Activity": "HEDIS; ONLINE_ASSESSMENTS"]
	union ["Clinical Activity": "HEDIS; TELEPHONE_VISITS"])Encounter
		where not Encounter.place_of_service in "HEDIS; TELEHEALTH_POS"
			and not Encounter.code_modifier in "HEDIS; TELEHEALTH_MODIFIER"
			and not ["Clinical Activity": "HEDIS; INPATIENT_STAY"] InptStay
					where Encounter.end_date 1 day or less before InptStay.start_date
			and not ["Clinical Activity": "HEDIS; INPATIENT_STAY"] InptStay2
					where InptStay2.claim_id = Encounter.claim_id
// Do not include telehealth AND Do not include outpatient, ED or observation visits that result in an inpatient stay
// While specifications do not include timing reference for ED/Obs resulting in inpatient stay, NCQA inquiry resulted in the following response: "Per General Guideline 45, when an outpatient, ED or observation visit and an inpatient stay are billed on separate claims, the visit results in an inpatient stay when the outpatient/ED/observation date of service occurs on the day prior to the admission date or any time during the admission (admission date through discharge date). We also create a scenario where an ED/outpatient/observation and an inpatient are billed on the same claim with the same ClaimID. We expect this to be treated as one logical claim where the ED/outpatient/observation resulted in an inpatient stay - there must be an Inpatient Stay Value Set code."

define "Acute Inpatient Encounter":
	(["Clinical Activity": "HEDIS; INPATIENT_STAY"]) InptStay
		without "Nonacute Inpatient Visit")

define "Nonacute Inpatient Visit":
	exists(["Clinical Activity": "HEDIS; INPATIENT_STAY"] Inpatient
		with ["Clinical Activity": "HEDIS; NONACUTE_INPATIENT_STAY"] Nonacute
			such that Inpatient.claim_id = Nonacute.claim_id
		where Inpatient.admissionDate during "Measurement Period"
			and Inpatient.place_of_service != 81
			and Nonacute.place_of_service != 81
		)

define "Qualifying Encounter":
	"Outpatient Encounter"
	union "Acute Inpatient Encounter"

define "COPD":
  ["Diagnosis": "HEDIS; COPD"]
  union ["Diagnosis": "HEDIS; EMPHYSEMA"]
  union ["Diagnosis": "HEDIS; CHRONIC_BRONCHITIS"]

define "Encounter With COPD":
//Specifications want both acute inpatient encounters with ANY diagnosis of COPD and those with COPD on the discharge claim

	"Qualifying Encounter" QualEnc
    with "COPD" DiagnosisCOPD
      such that DiagnosisCOPD.start_date during Interval[QualEnc.start_date, QualEnc.end_date]
			and DiagnosisCOPD.claim_id = QualEnc.claim_id

define "COPD During Index Period":
//A 12-month window that begins on July 1 of the year prior to the measurement year and ends on June 30 of the measurement year

	"Encounter With COPD" COPDEnc
    where COPDEnc.start_date 6 months or less before start of "Measurement Period"
			or COPDEnc.start_date 6 months or less after start of "Measurement Period"

define "COPD During Index Period Exists":
  exists("COPD During Index Period")

define "First COPD During Index Period":
  First("Encounter With COPD" E
    sort by E.start_date asc)

define "Negative Diagnosis Outpatient Encounter":
//with or without a telehealth modifier

	(["Clinical Activity": "HEDIS; OUTPATIENT"]
	union ["Clinical Activity": "HEDIS; OBSERVATION"]
	union ["Clinical Activity": "HEDIS; ED"]
	union ["Clinical Activity": "HEDIS; TELEPHONE_VISITS"]
	union ["Clinical Activity": "HEDIS; ONLINE_ASSESSMENTS"])Encounter
		without ["Clinical Activity": "HEDIS; INPATIENT_STAY"] InptStay
			such that Encounter.end_date 1 day or less before InptStay.start_date
		without ["Clinical Activity": "HEDIS; INPATIENT_STAY"] InptStay2
			such that InptStay2.claim_id = Encounter.claim_id

define "Negative Diagnosis Qualifying Encounters":
	"Negative Diagnosis Outpatient Encounter"
	union "Acute Inpatient Encounter"

define "Negative Diagnosis Encounter with COPD":
	"Negative Diagnosis Qualifying Encounters" NegQualEnc
		with "COPD" DiagnosisCOPD
			such that DiagnosisCOPD.start_date during Interval[NegQualEnc.start_date, NegQualEnc.end_date]
			and DiagnosisCOPD.claim_id = NegQualEnc.claim_id

define "First COPD During Index Period Has Prior Diagnosis":
  exists("First COPD During Index Period") FirstCOPD
    with "Negative Diagnosis Encounter With COPD" NegDiagCOPDEncounter
      such that NegDiagCOPDEncounter.start_date 730 days or less before FirstCOPD.start_date
