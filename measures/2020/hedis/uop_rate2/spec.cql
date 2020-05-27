library HEDIS_UOP_RATE2_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: UOP Rate 2
 * Year: 2020
 * Version: 1
 * Author: Chana West
 *
  */

using QDM

	include "../shared/hedis_shared" version '1' called HedisShared

// HEDIS value sets

valueset "HEDIS; Hospice Encounter": '2.16.840.1.113883.3.464.1004.1761'
valueset "HEDIS; Hospice Intervention": '2.16.840.1.113883.3.464.1004.1762'

// NCQA medication list value sets

valueset "NCQA; Buprenorphine Medications"
valueset "NCQA; Butorphanol Medications"
valueset "NCQA; Acetaminophen Butalbital Caffeine Codeine Medications"
valueset "NCQA; Acetaminophen Codeine Medications"
valueset "NCQA; Aspirin Butalbital Caffeine Codeine Medications"
valueset "NCQA; Aspirin Carisoprodol Codeine Medications"
valueset "NCQA; Codeine Sulfate Medications"
valueset "NCQA; Acetaminophen Caffeine Dihydrocodeine Medications"
valueset "NCQA; Aspirin Caffeine Dihydrocodeine Medications"
valueset "NCQA; Fentanyl Medications"
valueset "NCQA; Acetaminophen Hydrocodone Medications"
valueset "NCQA; Hydrocodone Medications"
valueset "NCQA; Hydrocodone Ibuprofen Medications"
valueset "NCQA; Hydromorphone Medications"
valueset "NCQA; Levorphanol Medications"
valueset "NCQA; Meperidine Medications"
valueset "NCQA; Meperidine Promethazine Medications"
valueset "NCQA; Methadone Medications"
valueset "NCQA; Morphine Medications"
valueset "NCQA; Morphine Naltrexone Medications"
valueset "NCQA; Belladonna Opium Medications"
valueset "NCQA; Opium Medications"
valueset "NCQA; Acetaminophen Oxycodone Medications"
valueset "NCQA; Aspirin Oxycodone Medications"
valueset "NCQA; Ibuprofen Oxycodone Medications"
valueset "NCQA; Oxycodone Medications"
valueset "NCQA; Oxymorphone Medications"
valueset "NCQA; Naloxone Pentazocine Medications"
valueset "NCQA; Tapentadol Medications"
valueset "NCQA; Acetaminophen Tramadol Medications"
valueset "NCQA; Tramadol Medications"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Opioid Medication in Measurement Period":
  (["Medication, Dispensed": "NCQA; Buprenorphine Medications"]
  union ["Medication, Dispensed": "NCQA; Butorphanol Medications"]
  union ["Medication, Dispensed": "NCQA; Acetaminophen Butalbital Caffeine Codeine Medications"]
  union ["Medication, Dispensed": "NCQA; Aspirin Butalbital Caffeine Codeine Medications"]
  union ["Medication, Dispensed": "NCQA; Aspirin Carisoprodol Codeine Medications"]
  union ["Medication, Dispensed": "NCQA; Codeine Sulfate Medications"]
  union ["Medication, Dispensed": "NCQA; Acetaminophen Caffeine Dihydrocodeine Medications"]
  union ["Medication, Dispensed": "NCQA; Aspirin Caffeine Dihydrocodeine Medications"]
  union ["Medication, Dispensed": "NCQA; Fentanyl Medications"]
  union ["Medication, Dispensed": "NCQA; Acetaminophen Hydrocodone Medications"]
  union ["Medication, Dispensed": "NCQA; Hydrocodone Medications"]
  union ["Medication, Dispensed": "NCQA; Hydrocodone Ibuprofen Medications"]
  union ["Medication, Dispensed": "NCQA; Hydromorphone Medications"]
  union ["Medication, Dispensed": "NCQA; Levorphanol Medications"]
  union ["Medication, Dispensed": "NCQA; Meperidine Medications"]
  union ["Medication, Dispensed": "NCQA; Meperidine Promethazine Medications"]
  union ["Medication, Dispensed": "NCQA; Methadone Medications"]
  union ["Medication, Dispensed": "NCQA; Morphine Medications"]
  union ["Medication, Dispensed": "NCQA; Morphine Naltrexone Medications"]
  union ["Medication, Dispensed": "NCQA; Belladonna Opium Medications"]
  union ["Medication, Dispensed": "NCQA; Opium Medications"]
  union ["Medication, Dispensed": "NCQA; Acetaminophen Oxycodone Medications"]
  union ["Medication, Dispensed": "NCQA; Aspirin Oxycodone Medications"]
  union ["Medication, Dispensed": "NCQA; Ibuprofen Oxycodone Medications"]
  union ["Medication, Dispensed": "NCQA; Oxycodone Medications"]
  union ["Medication, Dispensed": "NCQA; Oxymorphone Medications"]
  union ["Medication, Dispensed": "NCQA; Naloxone Pentazocine Medications"]
  union ["Medication, Dispensed": "NCQA; Tapentadol Medications"]
  union ["Medication, Dispensed": "NCQA; Acetaminophen Tramadol Medications"]
  union ["Medication, Dispensed": "NCQA; Tramadol Medications"]) OpioidMeds
    where OpioidMeds.relevantPeriod starts during "Measurement Period"

define "Multiple Different Opioids Same Day - Longest Supply Date":
//If multiple prescriptions for different medications are dispensed on the same day, calculate the number of days covered by an opioid medication using the prescriptions with the longest days supply.
  from
  "Opioid Medication in Measurement Period" OpMed1,
  "Opioid Medication in Measurement Period" OpMed2
    where OpMed1.code != OpMed2.code
    and OpMed1.relevantPeriod starts same day as start of OpMed2.relevantPeriod
    and OpMed1.relevantPeriod ends 1 day or more after end of OpMed2.relevantPeriod
  return OpMed1.relevantPeriod
          intersect "Measurement Period"

define "Multiple Different Opioids Same Day - Overlapping Supply":
//For multiple different prescriptions dispensed on different days with overlapping days supply, count each day in the measurement year only once toward the denominator
//distinct is intended to eliminate duplicate days in measurement period
  distinct (from
        "Opioid Medication in Measurement Period" OpMed1,
        "Opioid Medication in Measurement Period" OpMed2
        where OpMed1.code != OpMed2.code
          and OpMed1.relevantPeriod overlaps OpMed2.relevantPeriod
        return all Interval[OpMed1.relevantPeriod, OpMed1.relevantPeriod]
    )

define "Same Opioids - Overlapping Supply":
//If multiple prescriptions for the same medication are dispensed on the same day or different days with overlapping days supply, sum the days supply and use the total to calculate the number of days covered by an opioid medication.
  from
  "Opioid Medication in Measurement Period" OpMed1,
  "Opioid Medication in Measurement Period" OpMed2
    where OpMed1.code ~ OpMed2.code
    and OpMed1.relevantPeriod overlaps OpMed2.relevantPeriod
  return all Interval[OpMed1.relevantPeriod, OpMed1.relevantPeriod]

define "Non-overlapping Opioids":
// Identifies all intervals of opioid medications, associated with the measurement period
  collapse ( "Opioid Medication in Measurement Period" OpioidPeriod
      return OpioidPeriod.relevantPeriod
      )

define "Opioids Dispensed Relevant Periods":
    "Multiple Different Opioids Same Day - Longest Supply Date"
    and "Multiple Different Opioids Same Day - Overlapping Supply"
    and "Same Opioids - Overlapping Supply"
    and "Non-overlapping Opioids"

define "Cumulative Medication Duration Greater than or Equal to 15 days"
//CMD = Sum of each calculated interval returned based on relevantPeriods in "Opioids Dispensed Relevant Periods"
  "Cumulative Medication Duration"("Opioids Dispensed Relevant Periods")>= 15

/* Populations */

define "Exclusion: Hospice":
   /*
   * config_link_id: exclusion_required_hospice
   */
   exists("Hospice During Period"("Measurement Period"))

define "Denominator":
  AgeInYearsAt(start of "Measurement Period") >= 18
  and "Cumulative Medication Duration Greater than or Equal to 15 days"

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists("Opioid" M1
    with "Opioid" M2
      such that M2.pharmacyNPI != M1.pharmacyNPI
    with "Opioid" M3
      such that M3.pharmacyNPI != M1.pharmacyNPI
        and M3.pharmacyNPI != M2.pharmacyNPI
    with "Opioid" M4
      such that M4.pharmacyNPI != M1.pharmacyNPI
        and M4.pharmacyNPI != M2.pharmacyNPI
        and M4.pharmacyNPI != M3.pharmacyNPI)

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
