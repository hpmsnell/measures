library MIPS_006_2017 version '1'

/*
 * Source: MIPS
 * ID: 006
 * Year: 2017
 * Version: 1
 */

using QDM

// Able custom value sets

valueset "Able; Patient Refusal"
valueset "Able; System Reason"

valueset "MIPS; MIPS 006 Encounter"
valueset "MIPS; CAD Diagnosis"
valueset "MIPS; Denominator Exception: 4086F-1P"
valueset "MIPS; Denominator Exception: 4086F-2P"
valueset "MIPS; Denominator Exception: 4086F-3P"
valueset "MIPS; Performance Met: 4086F"
valueset "MIPS; Performance Not Met: 4086F-8P"
valueset "MIPS; Telehealth Modifier"

// Value Sets from VSAC

valueset "VSAC; Aspirin and Other Antiplatelet Agents": '2.16.840.1.113883.6.88'
valueset "VSAC; Medical Reason": '2.16.840.1.113883.6.96'
valueset "VSAC; Thrombocytopenia Diagnosis": '2.16.840.1.113883.6.96'
valueset "VSAC; Patient Reason Refused": '2.16.840.1.113883.3.600.1.1503'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator":
  AgeInYearsAt(start of "Measurement Period") >= 18 and exists([Diagnosis, Code "Diagnosis of Diabates"] D
    where D.prevalencePeriod overlaps "Measurement Period")
  and exists([Encounter, Performed: "MIPS; 006 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period")
//and not exists([Encounter, performed (Includes?): "MIPS; Telemedicine Modifier"] E)
    and d E.signingProvider.pqrsProvider = true

define "Numerator Performance Met: 4086F":
  /*
   * config_link_id: 4086
   */
   exists ([Medication, Active: "VSAC; Aspirin and Other Antiplatelet Agents"]) M
    where M.relevantPeriod starts before end of "Measurement Period")

//Exception 1: patient is excepted from the denominator if the presence of drug allergy or intolerance is documented
define "Denominator Exception 1: 4086F-1P":
/*
 * config_link_id: denominator_exception_1
 */
  exists ([Medication, Active: 416098002 in "VSAC; Medical Reason"] M
    where M.relevantPeriod starts before end of "Measurement Period")
  or exists ([Medication, Active: 59037007 in "VSAC; Medical Reason"] M
    where M.relevantPeriod starts before end of "Measurement Period")

//Exception 2: patient is excepted because of the presence of another Thienopyridine agent or Warfarin therapy
define "Denominator Exception 2: 4086F-1P"
 /*
  * config_link_id: denominator_exception_2
  */
  exists([Medication, Active: "VSAC; Aspirin and Other Antiplatelet Agents"] M
    where M.relevantPeriod starts before end of "Measurement Period")

//Exception 3: patient is excepted because of a pre-existing bleeding disorder (thrombocytopenia)
define "Denominator Exception 3: 4086F-1P"
 /*
  * config_link_id: denominator_exception_3
  */
  exists([Diagnosis, Active: "VSAC; Thrombocytopenia Diagnosis"]
    where M.relevantPeriod starts before end of "Measurement Period")

//Exception 4: patient declined treatment with aspirin or clopidogrel
define "Denominator Exception 4: 4086F-2P"
/*
* config_link_id: denominator_exception_4
*/
  exists([Patient, refusal: '105480006' in "VSAC; Patient Reason Refused"] P
    where P.revelvantPeriod starts before end of "Measurement Period")
  or exists([Patient, refusal: "MIPS; MIPS 006 Patient Refusal"]
    where P.revelvantPeriod starts before end of "Measurement Period")

//Exception 5: documentation of system reason for not prescribing aspirin or clopidogrel (e.g., lack of drug availablility or other reasons attributable to the health care system)
define "Denominator Exception 5: 4086F-3P"
  /*
  * config_link_id: denominator_exception_5
  */
  or exists([Medication, not administered "MIPS; MIPS 006 System Reason:"]
    where P.revelvantPeriod starts before end of "Measurement Period")

//Numerator Performance Not Met for reasons not otherwise specified
define "Numerator Performance Not Met: 4086-8P":
  /*
   * config_link_id: numerator_performance_not_met
   */

  not "Numerator Performance Met: 4086F"
