library MIPS_191_2017 version '1'

/*
 * Source: MIPS
 * ID: 191
 * Year: 2017
 * Version: 1
 * Written By: Steve Daniels
 * Reviewed By: Rachel Katz
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 191 Encounter"
valueset "MIPS; MIPS 191 Encounter Modifier"
valueset "MIPS; Performance Met: 4175F"
valueset "MIPS; Performance Not Met: 4175F-8P"

// VSAC Value Sets

valueset "VSAC; Acute and Subacute Iridocyclitis": '2.16.840.1.113883.3.526.3.1241'
valueset "VSAC; Amblyopia": '2.16.840.1.113883.3.526.3.1448'
valueset "VSAC; Burn Confined to Eye and Adnexa": '2.16.840.1.113883.3.526.3.1409'
valueset "VSAC; Cataract Secondary to Ocular Disorders": '2.16.840.1.113883.3.526.3.1410'
valueset "VSAC; Central Corneal Ulcer": '2.16.840.1.113883.3.526.3.1428'
valueset "VSAC; Certain Types of Iridocyclitis": '2.16.840.1.113883.3.526.3.1415'
valueset "VSAC; Chorioretinal Scars": '2.16.840.1.113883.3.526.3.1449'
valueset "VSAC; Choroidal Degenerations": '2.16.840.1.113883.3.526.3.1450'
valueset "VSAC; Choroidal Detachment": '2.16.840.1.113883.3.526.3.1451'
valueset "VSAC; Choroidal Hemorrhage and Rupture": '2.16.840.1.113883.3.526.3.1452'
valueset "VSAC; Chronic Iridocyclitis": '2.16.840.1.113883.3.526.3.1416'
valueset "VSAC; Cloudy Cornea": '2.16.840.1.113883.3.526.3.1417'
valueset "VSAC; Corneal Edema": '2.16.840.1.113883.3.526.3.1418'
valueset "VSAC; Corneal Opacity and Other Disorders of Cornea": '2.16.840.1.113883.3.526.3.1419'
valueset "VSAC; Degeneration of Macula and Posterior Pole": '2.16.840.1.113883.3.526.3.1454'
valueset "VSAC; Diabetic Macular Edema": '2.16.840.1.113883.3.526.3.1455'
valueset "VSAC; Diabetic Retinopathy": '2.16.840.1.113883.3.526.3.327'
valueset "VSAC; Disorders of Optic Chiasm": '2.16.840.1.113883.3.526.3.1457'
valueset "VSAC; Disorders of Visual Cortex": '2.16.840.1.113883.3.526.3.1458'
valueset "VSAC; Disseminated Chorioretinitis and Disseminated Retinochoroiditis": '2.16.840.1.113883.3.526.3.1459'
valueset "VSAC; Focal Chorioretinitis and Focal Retinochoroiditis": '2.16.840.1.113883.3.526.3.1460'
valueset "VSAC; Glaucoma": '2.16.840.1.113883.3.526.3.1423'
valueset "VSAC; Glaucoma Associated with Congenital Anomalies, Dystrophies, and Systemic Syndromes": '2.16.840.1.113883.3.526.3.1461'
valueset "VSAC; Hereditary Choroidal Dystrophies": '2.16.840.1.113883.3.526.3.1462'
valueset "VSAC; Hereditary Corneal Dystrophies": '2.16.840.1.113883.3.526.3.1424'
valueset "VSAC; Hereditary Retinal Dystrophies": '2.16.840.1.113883.3.526.3.1463'
valueset "VSAC; Injury to Optic Nerve and Pathways": '2.16.840.1.113883.3.526.3.1427'
valueset "VSAC; Moderate or Severe Impairment, Better Eye, Profound Impairment Lesser Eye": '2.16.840.1.113883.3.526.3.1464'
valueset "VSAC; Nystagmus and Other Irregular Eye Movements": '2.16.840.1.113883.3.526.3.1465'
valueset "VSAC; Open Wound of Eyeball": '2.16.840.1.113883.3.526.3.1430'
valueset "VSAC; Optic Atrophy": '2.16.840.1.113883.3.526.3.1466'
valueset "VSAC; Optic Neuritis": '2.16.840.1.113883.3.526.3.1467'
valueset "VSAC; Other and Unspecified Forms of Chorioretinitis and Retinochoroiditis": '2.16.840.1.113883.3.526.3.1468'
valueset "VSAC; Other Background Retinopathy and Retinal Vascular Changes": '2.16.840.1.113883.3.526.3.1469'
valueset "VSAC; Other Corneal Deformities": '2.16.840.1.113883.3.526.3.1470'
valueset "VSAC; Other Disorders of Optic Nerve": '2.16.840.1.113883.3.526.3.1471'
valueset "VSAC; Other Disorders of Sclera": '2.16.840.1.113883.3.526.3.1472'
valueset "VSAC; Other Endophthalmitis": '2.16.840.1.113883.3.526.3.1473'
valueset "VSAC; Other Proliferative Retinopathy": '2.16.840.1.113883.3.526.3.1480'
valueset "VSAC; Other Retinal Disorders": '2.16.840.1.113883.3.526.3.1474'
valueset "VSAC; Pathologic Myopia": '2.16.840.1.113883.3.526.3.1432'
valueset "VSAC; Prior Penetrating Keratoplasty": '2.16.840.1.113883.3.526.3.1475'
valueset "VSAC; Profound Impairment, Both Eyes": '2.16.840.1.113883.3.526.3.1476'
valueset "VSAC; Purulent Endophthalmitis": '2.16.840.1.113883.3.526.3.1477'
valueset "VSAC; Retinal Detachment with Retinal Defect": '2.16.840.1.113883.3.526.3.1478'
valueset "VSAC; Retinal Vascular Occlusion": '2.16.840.1.113883.3.526.3.1479'
valueset "VSAC; Scleritis and Episcleritis": '2.16.840.1.113883.3.526.3.1481'
valueset "VSAC; Separation of Retinal Layers": '2.16.840.1.113883.3.526.3.1482'
valueset "VSAC; Uveitis": '2.16.840.1.113883.3.526.3.1444'
valueset "VSAC; Visual Field Defects": '2.16.840.1.113883.3.526.3.1446'
valueset "VSAC; Visual Acuity 20/40 or Better": '2.16.840.1.113883.3.526.3.1483'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Cataract Surgery":
  ["Encounter, Performed": "MIPS; MIPS 191 Encounter"] E
    where E.relevantPeriod starts during Interval[start of "Measurement Period", 3 months before end "Measurement Period"]
      AgeInYearsAt >= 18
      and not E.code.modifier in "MIPS; MIPS 191 Encounter Modifier"
      and E.signingProvider.hasMeasureMembership = true

define "Excluded Diagnoses":
  ["Diagnosis": "VSAC; Acute and Subacute Iridocyclitis"]
  union ["Diagnosis": "VSAC; Amblyopia"]
  union ["Diagnosis": "VSAC; Burn Confined to Eye and Adnexa"]
  union ["Diagnosis": "VSAC; Cataract Secondary to Ocular Disorders"]
  union ["Diagnosis": "VSAC; Central Corneal Ulcer"]
  union ["Diagnosis": "VSAC; Certain Types of Iridocyclitis"]
  union ["Diagnosis": "VSAC; Chorioretinal Scars"]
  union ["Diagnosis": "VSAC; Choroidal Degenerations"]
  union ["Diagnosis": "VSAC; Choroidal Detachment"]
  union ["Diagnosis": "VSAC; Choroidal Hemorrhage and Rupture"]
  union ["Diagnosis": "VSAC; Chronic Iridocyclitis"]
  union ["Diagnosis": "VSAC; Cloudy Cornea"]
  union ["Diagnosis": "VSAC; Corneal Edema"]
  union ["Diagnosis": "VSAC; Corneal Opacity and Other Disorders of Cornea"]
  union ["Diagnosis": "VSAC; Degeneration of Macula and Posterior Pole"]
  union ["Diagnosis": "VSAC; Diabetic Macular Edema"]
  union ["Diagnosis": "VSAC; Diabetic Retinopathy"]
  union ["Diagnosis": "VSAC; Disorders of Optic Chiasm"]
  union ["Diagnosis": "VSAC; Disorders of Visual Cortex"]
  union ["Diagnosis": "VSAC; Disseminated Chorioretinitis and Disseminated Retinochoroiditis"]
  union ["Diagnosis": "VSAC; Focal Chorioretinitis and Focal Retinochoroiditis"]
  union ["Diagnosis": "VSAC; Glaucoma"]
  union ["Diagnosis": "VSAC; Glaucoma Associated with Congenital Anomalies, Dystrophies, and Systemic Syndromes"]
  union ["Diagnosis": "VSAC; Hereditary Choroidal Dystrophies"]
  union ["Diagnosis": "VSAC; Hereditary Corneal Dystrophies"]
  union ["Diagnosis": "VSAC; Hereditary Retinal Dystrophies"]
  union ["Diagnosis": "VSAC; Injury to Optic Nerve and Pathways"]
  union ["Diagnosis": "VSAC; Moderate or Severe Impairment, Better Eye, Profound Impairment Lesser Eye"]
  union ["Diagnosis": "VSAC; Nystagmus and Other Irregular Eye Movements"]
  union ["Diagnosis": "VSAC; Nystagmus and Other Irregular Eye Movements"]
  union ["Diagnosis": "VSAC; Open Wound of Eyeball"]
  union ["Diagnosis": "VSAC; Optic Atrophy"]
  union ["Diagnosis": "VSAC; Optic Neuritis"]
  union ["Diagnosis": "VSAC; Other and Unspecified Forms of Chorioretinitis and Retinochoroiditis"]
  union ["Diagnosis": "VSAC; Other Background Retinopathy and Retinal Vascular Changes"]
  union ["Diagnosis": "VSAC; Other Corneal Deformities"]
  union ["Diagnosis": "VSAC; Other Disorders of Optic Nerve"]
  union ["Diagnosis": "VSAC; Other Disorders of Sclera"]
  union ["Diagnosis": "VSAC; Other Endophthalmitis"]
  union ["Diagnosis": "VSAC; Other Proliferative Retinopathy"]
  union ["Diagnosis": "VSAC; Other Retinal Disorders"]
  union ["Diagnosis": "VSAC; Pathologic Myopia"]
  union ["Diagnosis": "VSAC; Prior Penetrating Keratoplasty"]
  union ["Diagnosis": "VSAC; Profound Impairment, Both Eyes"]
  union ["Diagnosis": "VSAC; Purulent Endophthalmitis"]
  union ["Diagnosis": "VSAC; Retinal Detachment with Retinal Defect"]
  union ["Diagnosis": "VSAC; Retinal Vascular Occlusion"]
  union ["Diagnosis": "VSAC; Scleritis and Episcleritis"]
  union ["Diagnosis": "VSAC; Separation of Retinal Layers"]
  union ["Diagnosis": "VSAC; Uveitis"]
  union ["Diagnosis": "VSAC; Visual Field Defects"]

define "Denominator":
  "Cataract Surgery"

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
  exists("Excluded Diagnoses" D
    with "Cataract Surgery" E
      where D.prevalencePeriod overlaps E.relevantPeriod)

define "Numerator Performance Met: 4175F":
  /*
   * config_link_id: 4175F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 4175F"] P
    with "Cataract Surgery" E
      where D.prevalencePeriod starts 90 days or less after end of E.relevantPeriod)
  or exists(["Diagnosis": "VSAC; Visual Acuity 20/40 or Better"] D //Confirm data format
    with "Cataract Surgery" E
      where D.prevalencePeriod starts 90 days or less after end of E.relevantPeriod)

define "Numerator Performance Not Met: 4175F-8P":
  /*
   * config_link_id: 4175F-8P
   */
   not "Denominator Exclusion"
   and not "Numerator Performance Met: 4175F"
