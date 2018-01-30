library MIPS_192_2017 version '1'

/*
 * Source: MIPS
 * ID: 192
 * Year: 2017
 * Version: 1
 * Written By: Steve Daniels
 * Reviewed By: Rachel Katz
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 192 Encounter"
valueset "MIPS; MIPS 192 Encounter Modifier"
valueset "MIPS; Performance Met: G8627"
valueset "MIPS; Performance Not Met: G8628"
valueset "VSAC; Use of Systemic Sympathetic alpha-1a Antagonist Medication for Treatment of Prostatic Hypertrophy"

// VSAC Value Sets

valueset "VSAC; Acute and Subacute Iridocyclitis": '2.16.840.1.113883.3.526.3.1241'
valueset "VSAC; Adhesions and Disruptions of Iris and Ciliary Body": '2.16.840.1.113883.3.526.3.1405'
valueset "VSAC; Anomalies of Pupillary Function": '2.16.840.1.113883.3.526.3.1406'
valueset "VSAC; Aphakia and Other Disorders of Lens": '2.16.840.1.113883.3.526.3.1407'
valueset "VSAC; Burn Confined to Eye and Adnexa": '2.16.840.1.113883.3.526.3.1409'
valueset "VSAC; Cataract Secondary to Ocular Disorders": '2.16.840.1.113883.3.526.3.1410'
valueset "VSAC; Cataract, Congenital": '2.16.840.1.113883.3.526.3.1412'
valueset "VSAC; Cataract, Mature or Hypermature": '2.16.840.1.113883.3.526.3.1413'
valueset "VSAC; Cataract, Posterior Polar": '2.16.840.1.113883.3.526.3.1414'
valueset "VSAC; Central Corneal Ulcer": '2.16.840.1.113883.3.526.3.1428'
valueset "VSAC; Certain Types of Iridocyclitis": '2.16.840.1.113883.3.526.3.1415'
valueset "VSAC; Chronic Iridocyclitis": '2.16.840.1.113883.3.526.3.1416'
valueset "VSAC; Cloudy Cornea": '2.16.840.1.113883.3.526.3.1417'
valueset "VSAC; Corneal Edema": '2.16.840.1.113883.3.526.3.1418'
valueset "VSAC; Corneal Opacity and Other Disorders of Cornea": '2.16.840.1.113883.3.526.3.1419'
valueset "VSAC; Cysts of Iris, Ciliary Body, and Anterior Chamber": '2.16.840.1.113883.3.526.3.1420'
valueset "VSAC; Enophthalmos": '2.16.840.1.113883.3.526.3.1421'
valueset "VSAC; Glaucoma": '2.16.840.1.113883.3.526.3.1423'
valueset "VSAC; Hereditary Corneal Dystrophies": '2.16.840.1.113883.3.526.3.1424'
valueset "VSAC; High Hyperopia": '2.16.840.1.113883.3.526.3.1425'
valueset "VSAC; Hypotony of Eye": '2.16.840.1.113883.3.526.3.1426'
valueset "VSAC; Injury to Optic Nerve and Pathways": '2.16.840.1.113883.3.526.3.1427'
valueset "VSAC; Open Wound of Eyeball": '2.16.840.1.113883.3.526.3.1430'
valueset "VSAC; Pathologic Myopia": '2.16.840.1.113883.3.526.3.1432'
valueset "VSAC; Posterior Lenticonus": '2.16.840.1.113883.3.526.3.1433'
valueset "VSAC; Pseudoexfoliation Syndrome": '2.16.840.1.113883.3.526.3.1435'
valueset "VSAC; Retrolental Fibroplasias": '2.16.840.1.113883.3.526.3.1438'
valueset "VSAC; Senile Cataract": '2.16.840.1.113883.3.526.3.1441'
valueset "VSAC; Traumatic Cataract": '2.16.840.1.113883.3.526.3.1443'
valueset "VSAC; Uveitis": '2.16.840.1.113883.3.526.3.1444'
valueset "VSAC; Vascular Disorders of Iris and Ciliary Body": '2.16.840.1.113883.3.526.3.1445'
valueset "VSAC; Use of Systemic Sympathetic alpha-1a Antagonist Medication for Treatment of Prostatic Hypertrophy": '2.16.840.1.113883.3.526.3.1442'
valueset "VSAC; Aspiration and Injection Procedures": '2.16.840.1.113883.3.526.3.1408'
valueset "VSAC; Excision of Adhesions": '2.16.840.1.113883.3.526.3.1422'
valueset "VSAC; Lens Procedure": '2.16.840.1.113883.3.526.3.1429'
valueset "VSAC; Prior Pars Plana Vitrectomy": '2.16.840.1.113883.3.526.3.1434'
valueset "VSAC; Removal Procedures": '2.16.840.1.113883.3.526.3.1436'
valueset "VSAC; Retinal Repair Procedures": '2.16.840.1.113883.3.526.3.1437'
valueset "VSAC; Revision Procedures": '2.16.840.1.113883.3.526.3.1439'
valueset "VSAC; Scleral Procedures": '2.16.840.1.113883.3.526.3.1440'
valueset "VSAC; Vitreous Procedures": '2.16.840.1.113883.3.526.3.1447'

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Cataract Surgery":
  ["Encounter, Performed": "MIPS; MIPS 192 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt >= 18
      and not E.code.modifier in "MIPS; MIPS 192 Encounter Modifier"
      and E.signingProvider.hasMeasureMembership = true
    without "Complications" P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Excluded Diagnoses":
  ["Diagnosis": "VSAC; Acute and Subacute Iridocyclitis"]
  union ["Diagnosis": "VSAC; Adhesions and Disruptions of Iris and Ciliary Body"]
  union ["Diagnosis": "VSAC; Anomalies of Pupillary Function"]
  union ["Diagnosis": "VSAC; Aphakia and Other Disorders of Lens"]
  union ["Diagnosis": "VSAC; Burn Confined to Eye and Adnexa"]
  union ["Diagnosis": "VSAC; Cataract Secondary to Ocular Disorders"]
  union ["Diagnosis": "VSAC; Cataract, Congenital"]
  union ["Diagnosis": "VSAC; Cataract, Mature or Hypermature"]
  union ["Diagnosis": "VSAC; Cataract, Posterior Polar"]
  union ["Diagnosis": "VSAC; Central Corneal Ulcer"]
  union ["Diagnosis": "VSAC; Certain Types of Iridocyclitis"]
  union ["Diagnosis": "VSAC; Chronic Iridocyclitis"]
  union ["Diagnosis": "VSAC; Cloudy Cornea"]
  union ["Diagnosis": "VSAC; Corneal Edema"]
  union ["Diagnosis": "VSAC; Corneal Opacity and Other Disorders of Cornea"]
  union ["Diagnosis": "VSAC; Cysts of Iris, Ciliary Body, and Anterior Chamber"]
  union ["Diagnosis": "VSAC; Enophthalmos"]
  union ["Diagnosis": "VSAC; Glaucoma"]
  union ["Diagnosis": "VSAC; Hereditary Corneal Dystrophies"]
  union ["Diagnosis": "VSAC; High Hyperopia"]
  union ["Diagnosis": "VSAC; Hypotony of Eye"]
  union ["Diagnosis": "VSAC; Injury to Optic Nerve and Pathways"]
  union ["Diagnosis": "VSAC; Open Wound of Eyeball"]
  union ["Diagnosis": "VSAC; Pathologic Myopia"]
  union ["Diagnosis": "VSAC; Posterior Lenticonus"]
  union ["Diagnosis": "VSAC; Pseudoexfoliation Syndrome"]
  union ["Diagnosis": "VSAC; Retrolental Fibroplasias"]
  union ["Diagnosis": "VSAC; Senile Cataract"]
  union ["Diagnosis": "VSAC; Traumatic Cataract"]
  union ["Diagnosis": "VSAC; Uveitis"]
  union ["Diagnosis": "VSAC; Vascular Disorders of Iris and Ciliary Body"]

define "Complications":
  ["Procedure, Performed": "VSAC; Removal Procedures"]
  union ["Procedure, Performed": "VSAC; Excision of Adhesions"]
  union ["Procedure, Performed": "VSAC; Aspiration and Injection Procedures"]
  union ["Procedure, Performed": "VSAC; Lens Procedure"]
  union ["Procedure, Performed": "VSAC; Vitreous Procedures"]
  union ["Procedure, Performed": "VSAC; Retinal Repair Procedures"]
  union ["Procedure, Performed": "VSAC; Scleral Procedures"]
  union ["Procedure, Performed": "VSAC; Revision Procedures"]

define "Denominator":
  "Cataract Surgery"

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
  exists("Excluded Diagnoses" D
    with "Cataract Surgery" E
      where D.prevalencePeriod overlaps E.relevantPeriod)
  or exists(["Medication": "VSAC; Use of Systemic Sympathetic alpha-1a Antagonist Medication for Treatment of Prostatic Hypertrophy"] M
    with "Cataract Surgery" E
      where M.relevantPeriod overlaps E.relevantPeriod)
  or exists(["Procedure, Performed": "MIPS; Use of Systemic Sympathetic alpha-1a Antagonist Medication for Treatment of Prostatic Hypertrophy"] P
    where P.relevantPeriod starts during "Denominator Period")

define "Numerator Performance Met: G8627":
  /*
   * config_link_id: G8627
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8627"] P
    with "Cataract Surgery" E
      where P.relevantPeriod starts 30 days or less after end of E.relevantPeriod
  or exists("Complications" P
    with "Cataract Surgery" E
      where P.relevantPeriod starts 30 days or less after end of E.relevantPeriod)

define "Numerator Performance Not Met: G8628":
  /*
   * config_link_id: 4175F-8P
   */
   not "Denominator Exclusion"
   and not "Numerator Performance Met: G8627"
